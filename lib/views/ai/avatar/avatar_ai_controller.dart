import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:images_picker/images_picker.dart';

class AvatarAiController extends GetxController {
  final String name;
  final String style;
  List<Media> imageList = [];
  List<File> compressedList = [];
  List<UploadFile> uploadedList = [];
  int minSize = 15;
  int maxSize = 20;
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
    compressedList.clear();
    uploadedList.clear();
    super.dispose();
  }

  String get pickPhotosText {
    return 'Select $minSize-$maxSize selfies';
  }

  Future<bool> pickImageFromCamera() async {
    var photos = await ImagesPicker.openCamera(
          pickType: PickType.image,
        ) ??
        [];
    imageList.addAll(photos);
    if (imageList.length > maxSize) {
      imageList = imageList.sublist(0, maxSize);
    }
    update();
    return photos.isNotEmpty;
  }

  Future<bool> pickImageFromGallery() async {
    var photos = await ImagesPicker.pick(pickType: PickType.image, gif: false, count: maxSize - imageList.length) ?? [];
    imageList.addAll(photos);
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
      File file = await imageCompress(File(media.path), cacheManager.storageOperator.tempDir.path + EncryptUtil.encodeMd5(media.path) + ".jpg");
      if (stop) {
        return false;
      }
      compressedList.add(file);
      update();
    }
    for (int i = uploadedList.length; i < compressedList.length; i++) {
      if (stop) {
        return false;
      }
      var file = compressedList[i];
      var url = await api.uploadImageToS3(file, true);
      if (stop) {
        return false;
      }
      if (url == null) {
        return false;
      }
      uploadedList.add(UploadFile(imageUrl: url, file: file));
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
      'train_images': uploadedList.map((e) => e.imageUrl).toList().join(','),
    });
    if (baseEntity != null) {
      uploadedList.clear();
      compressedList.clear();
    }
    isLoading = false;
    update();
    return baseEntity;
  }
}

class UploadFile {
  String imageUrl;
  File file;

  UploadFile({required this.imageUrl, required this.file});
}
