import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:photo_gallery/photo_gallery.dart';

class AvatarAiController extends GetxController {
  final String name;
  final String style;
  List<Medium> imageList = [];
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

  String get pickPhotosText {
    return 'Select $minSize-$maxSize selfies';
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
    var photos = await PickAlbumScreen.pickImage(
      context,
      count: maxSize,
      selectedList: imageList,
    );
    if (photos == null) {
      return false;
    }
    imageList = photos;
    if (imageList.length > maxSize) {
      imageList = imageList.sublist(0, maxSize);
    }
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
      var sourceFile = await media.getFile();
      File file = await imageCompress(sourceFile, cacheManager.storageOperator.tempDir.path + EncryptUtil.encodeMd5(sourceFile.path) + ".jpg");
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
