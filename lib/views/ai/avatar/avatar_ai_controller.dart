import 'dart:convert';
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

  @override
  void onInit() {
    super.onInit();
    api = CartoonizerApi().bindController(this);
  }

  @override
  void dispose() {
    api.unbind();
    super.dispose();
  }

  String get pickPhotosText {
    return 'Select $minSize-$maxSize selfies';
  }

  Future<void> pickImageFromCamera() async {
    imageList.addAll(await ImagesPicker.openCamera(
          pickType: PickType.image,
        ) ??
        []);
    if (imageList.length > maxSize) {
      imageList = imageList.sublist(0, maxSize);
    }
    update();
  }

  Future<void> pickImageFromGallery() async {
    imageList.addAll(await ImagesPicker.pick(pickType: PickType.image, gif: false, count: maxSize - imageList.length) ?? []);
    if (imageList.length > maxSize) {
      imageList = imageList.sublist(0, maxSize);
    }
    update();
  }

  Future<bool> compressAndUpload() async {
    compressedList.clear();
    uploadedList.clear();
    stop = false;
    for (var media in imageList) {
      if (stop) {
        return false;
      }
      File file = await imageCompress(File(media.path), cacheManager.storageOperator.tempDir.path + EncryptUtil.encodeMd5(media.path) + ".jpg");
      if (stop) {
        return false;
      }
      compressedList.add(file);
      update();
    }
    for (var file in compressedList) {
      if (stop) {
        return false;
      }
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
    return true;
  }

  void stopUpload() {
    stop = true;
  }

  Future<BaseEntity?> submit() async {
    isLoading = true;
    update();
    var baseEntity = await api.submitAvatarAi(params: {
      'files': json.encode(uploadedList.map((e) => e.imageUrl).toList()),
    });
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
