import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:photo_manager/photo_manager.dart';

class AvatarAiController extends GetxController {
  final String name;
  final String style;
  List<AssetEntity> imageList = [];
  List<AssetEntity> badList = [];
  List<String> compressedList = [];
  List<String> uploadedList = [];
  int minSize = 5;
  int maxSize = 8;
  CacheManager cacheManager = AppDelegate.instance.getManager();
  AvatarAiManager aiManager = AppDelegate.instance.getManager();
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
    minSize = aiManager.config?.data.minImageCount ?? 5;
    maxSize = aiManager.config?.data.maxImageCount ?? 8;
  }

  @override
  void dispose() {
    api.unbind();
    imageList.clear();
    clear();
    super.dispose();
  }

  bool isHuman() => style == 'man' || style == 'woman';

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
    var minCount = minSize - imageList.length;
    if (minCount < 0) {
      isLoading = false;
      update();
      return false;
    }
    var photos = await PickAlbumScreen.pickImage(
      context,
      count: maxSize,
      minCount: minCount,
      selectedList: imageList,
      badList: badList,
      switchAlbum: true,
    );
    if (photos == null) {
      isLoading = false;
      update();
      return false;
    }
    List<AssetEntity> goodList = [];
    List<AssetEntity> badImages = [];
    if (isHuman()) {
      for (var medium in photos) {
        var file = await medium.file;
        if (file == null) {
          continue;
        }
        if ((file.path).toUpperCase().contains('.HEIC')) {
          File? sourceFile = await heicToImage(medium);
          if (sourceFile == null) {
            continue;
          }
          file = await imageCompressAndGetFile(sourceFile, imageSize: 1024);
        }
        var inputImage = InputImage.fromFile(file);
        FaceDetector detector = FaceDetector(options: FaceDetectorOptions());
        var list = await detector.processImage(inputImage);
        await detector.close();
        if (list.isEmpty || list.length > 1) {
          badImages.add(medium);
        } else {
          var face = list.first;
          var imageInfo = await SyncFileImage(file: file).getImage();
          if (faceRatio(Size(imageInfo.image.width.toDouble(), imageInfo.image.height.toDouble()), Size(face.boundingBox.width, face.boundingBox.height)) >
              (aiManager.config?.data.faceCheckRatio ?? 36)) {
            badImages.add(medium);
          } else {
            goodList.add(medium);
          }
          // if (face.boundingBox.width * 6 > imageInfo.image.width) {
          //   goodList.add(medium);
          // } else {
          //   badImages.add(medium);
          // }
        }
      }
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
    Events.avatarSelectOk(photoCount: goodList.length);
    return photos.isNotEmpty;
  }

  Future<bool> compressAndUpload() async {
    stop = false;
    for (int i = compressedList.length; i < imageList.length; i++) {
      if (stop) {
        return false;
      }
      var media = imageList[i];
      File? originalFile = await media.file;
      if (originalFile == null) {
        continue;
      }
      File file;
      if (Platform.isIOS) {
        if ((originalFile.path).toUpperCase().contains('.HEIC')) {
          File? sourceFile = await heicToImage(media);
          if (sourceFile == null) {
            continue;
          }
          file = await imageCompressAndGetFile(sourceFile, imageSize: 512);
        } else {
          var list = await media.thumbnailDataWithSize(ThumbnailSize(512, 512), quality: 100);
          file = await imageCompressByte(Uint8List.fromList(list!), cacheManager.storageOperator.tempDir.path + EncryptUtil.encodeMd5(originalFile.path) + ".png");
        }
      } else {
        file = await imageCompress(originalFile, cacheManager.storageOperator.tempDir.path + EncryptUtil.encodeMd5(originalFile.path) + ".png");
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
    return true;
  }

  void stopUpload() {
    stop = true;
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
    Events.avatarUploadSuccess();
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
