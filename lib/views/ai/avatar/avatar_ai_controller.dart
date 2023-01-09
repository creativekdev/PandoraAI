import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:photo_gallery/photo_gallery.dart';

class AvatarAiController extends GetxController {
  final String name;
  final String style;
  List<Medium> imageList = [];
  List<Medium> badList = [];
  List<String> compressedList = [];
  List<String> uploadedList = [];
  int minSize = 15;
  int maxSize = 30;
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late CartoonizerApi api;
  bool isLoading = false;

  bool get hasChosen => imageList.isNotEmpty;
  bool stop = false;

  AvatarAiController({
    required this.name,
    required this.style,
  });

  @override
  void onInit() {
    super.onInit();
    api = CartoonizerApi().bindController(this);
  }

  @override
  void dispose() {
    api.unbind();
    imageList.clear();
    clear();
    super.dispose();
  }

  String pickPhotosText(BuildContext context) {
    return '${S.of(context).select} $minSize-$maxSize ${S.of(context).selfies}';
  }

  // Future<bool> pickImageFromCamera() async {
  //   var photos = await ImagesPicker.openCamera(
  //         pickType: PickType.image,
  //       ) ??
  //       [];
  //   imageList.addAll(photos);
  //   if (imageList.length > maxSize) {
  //     imageList = imageList.sublist(0, maxSize);
  //   }
  //   update();
  //   return photos.isNotEmpty;
  // }

  Future<bool> pickImageFromGallery(BuildContext context) async {
    isLoading = true;
    update();
    var photos = await PickAlbumScreen.pickImage(
      context,
      count: maxSize,
      selectedList: imageList,
      badList: badList,
    );
    if (photos == null) {
      isLoading = false;
      update();
      return false;
    }
    List<Medium> goodList = [];
    List<Medium> badImages = [];
    if (style == 'man' || style == 'woman') {
      FaceDetector detector = FaceDetector(options: FaceDetectorOptions());
      for (var medium in photos) {
        var file = await medium.getFile();
        var inputImage = InputImage.fromFile(file);
        var list = await detector.processImage(inputImage);
        if (list.isEmpty || list.length > 1) {
          badImages.add(medium);
        } else {
          var face = list.first;
          var imageInfo = await SyncFileImage(file: file).getImage();
          if (face.boundingBox.width * 6 > imageInfo.image.width) {
            goodList.add(medium);
          } else {
            badImages.add(medium);
          }
        }
      }
      detector.close();
    } else {
      goodList = photos;
    }
    imageList = goodList;
    badImages.forEach((element) {
      if (!badList.exist((t) => t.id == element.id)) {
        badList.add(element);
      }
    });
    if (imageList.length > maxSize) {
      imageList = imageList.sublist(0, maxSize);
    }
    isLoading = false;
    update();
    return photos.isNotEmpty;
  }

  Future<bool> compressAndUpload() async {
    stop = false;
    for (int i = compressedList.length; i < imageList.length; i++) {
      if (stop) {
        return false;
      }
      var media = imageList[i];
      File file;
      if (Platform.isIOS) {
        if ((media.filename ?? '').toUpperCase().contains('.HEIC')) {
          var sourceFile = await media.getFile();
          file = await imageCompress(
            sourceFile,
            cacheManager.storageOperator.tempDir.path + EncryptUtil.encodeMd5(sourceFile.path) + ".png",
            format: CompressFormat.heic,
          );
        } else {
          var list = await media.getThumbnail(width: 512, height: 512, highQuality: true);
          file = await imageCompressByte(Uint8List.fromList(list), cacheManager.storageOperator.tempDir.path + EncryptUtil.encodeMd5(media.filename!) + ".png");
        }
      } else {
        var sourceFile = await media.getFile();
        file = await imageCompress(sourceFile, cacheManager.storageOperator.tempDir.path + EncryptUtil.encodeMd5(sourceFile.path) + ".png");
      }
      if (stop) {
        return false;
      }
      compressedList.add(file.path);
      update();
    }
    for (int i = uploadedList.length; i < compressedList.length; i++) {
      if (stop) {
        return false;
      }
      var filePath = compressedList[i];
      var url = await api.uploadImageToS3(File(filePath), true);
      if (stop) {
        return false;
      }
      if (url == null) {
        return false;
      }
      uploadedList.add(url);
      update();
    }
    logEvent(Events.avatar_submit_photos);
    return true;
  }

  void stopUpload() {
    stop = true;
    logEvent(Events.avatar_cancel_submit_photos);
  }

  Future<BaseEntity?> submit() async {
    isLoading = true;
    update();
    var baseEntity = await api.submitAvatarAi(params: {
      'name': name,
      'role': style,
      'train_images': uploadedList.map((e) => e).toList().join(','),
    });
    if (baseEntity != null) {
      clear();
    }
    isLoading = false;
    update();
    await AppDelegate.instance.getManager<UserManager>().refreshUser();
    return baseEntity;
  }

  clear() {
    uploadedList.clear();
    compressedList.forEach((element) {
      var file = File(element);
      if (file.existsSync()) {
        file.delete();
      }
    });
    compressedList.clear();
  }
}
