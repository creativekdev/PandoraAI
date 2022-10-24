import 'dart:convert';
import 'dart:io';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/rate_notice_operator.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:common_utils/common_utils.dart';

class ChoosePhotoScreenController extends GetxController {
  CacheManager cacheManager = AppDelegate.instance.getManager();
  Map<String, UploadRecordEntity> _imageUploadCache = {};

  @override
  void onInit() async {
    super.onInit();
    Map jsonString = cacheManager.getJson(CacheManager.imageUploadHistory) ?? {};
    jsonString.forEach((key, value) {
      var uploadRecordEntity = UploadRecordEntity.fromJson(json.decode(value));
      _imageUploadCache[key] = uploadRecordEntity;
    });
  }

  String? checkUploadHistory({required String fileName}) {
    var key = EncryptUtil.encodeMd5(fileName);
    var cache = _imageUploadCache[key];
    if (cache != null) {
      var duration = DateTime.now().millisecondsSinceEpoch - cache.createDt;
      if (duration < 6 * 24 * hour) {
        return cache.url;
      }
    }
    return null;
  }

  saveUploadHistory({
    required String fileName,
    required String url,
  }) {
    var key = EncryptUtil.encodeMd5(url);
    var cache = _imageUploadCache[key] ?? UploadRecordEntity();
    cache.url = url;
    cache.fileName = fileName;
    cache.createDt = DateTime.now().millisecondsSinceEpoch;
    _imageUploadCache[key] = cache;
    Map<String, String> map = {};
    _imageUploadCache.forEach((key, value) {
      map[key] = json.encode(value.toJson());
    });
    cacheManager.setJson(CacheManager.imageUploadHistory, map);
  }

  final isPhotoSelect = false.obs;

  changeIsPhotoSelect(bool value) => isPhotoSelect.value = value;

  final isVideo = false.obs;

  changeIsVideo(bool value) => isVideo.value = value;

  final isPhotoDone = false.obs;

  changeIsPhotoDone(bool value) => isPhotoDone.value = value;

  final isChecked = false.obs;

  changeIsChecked(bool value) => isChecked.value = value;

  final isLoading = false.obs;

  changeIsLoading(bool value) => isLoading.value = value;

  // @deprecated
  // final lastSelectedIndex = 0.obs;
  // setLastSelectedIndex(int i) => lastSelectedIndex.value = i;
  //
  // @deprecated
  // final lastItemIndex = 0.obs;
  // setLastItemIndex(int i) => lastItemIndex.value = i;
  //
  // @deprecated
  // final lastItemIndex1 = 0.obs;
  // setLastItemIndex1(int i) => lastItemIndex1.value = i;

  final Rx<File?> image = (null as File?).obs;

  updateImageFile(dynamic lFile) => image.value = lFile;

  final videoUrl = "".obs;

  updateVideoUrl(String str) => videoUrl.value = str;

  final imageUrl = "".obs;

  updateImageUrl(String str) => imageUrl.value = str;
}
