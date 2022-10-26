import 'dart:convert';
import 'dart:io';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/user/rate_notice_operator.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:path/path.dart' as path;

class ChoosePhotoScreenController extends GetxController {
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late StorageOperator storageOperator;
  Map<String, UploadRecordEntity> imageUploadCache = {};

  @override
  void onInit() async {
    super.onInit();
    storageOperator = cacheManager.storageOperator;
    Map jsonString = cacheManager.getJson(CacheManager.imageUploadHistory) ?? {};
    jsonString.forEach((key, value) {
      var uploadRecordEntity = UploadRecordEntity.fromJson(json.decode(value));
      if (File(uploadRecordEntity.fileName).existsSync()) {
        imageUploadCache[key] = uploadRecordEntity;
      }
    });
  }

  saveUploadHistory({
    required String key,
    required File file,
    required String url,
  }) async {
    var cache = imageUploadCache[key] ?? UploadRecordEntity();
    cache.url = url;
    cache.fileName = file.path;
    cache.createDt = DateTime.now().millisecondsSinceEpoch;
    imageUploadCache[key] = cache;
    _saveUploadCacheMap();
  }

  void _saveUploadCacheMap() {
    Map<String, String> map = {};
    imageUploadCache.forEach((key, value) {
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

  Future<bool> uploadCompressedImage() async {
    if (image.value == null) {
      return false;
    }
    var imageFile = image.value as File;
    var key = await md5File(imageFile);
    var cacheFile = imageUploadCache[key];
    if (cacheFile != null && !cacheFile.urlExpired()) {
      updateImageUrl(cacheFile.url);
      return true;
    }
    String f_name = path.basename(imageFile.path);
    var newPath = "${storageOperator.recentDir.path}/$f_name";
    File? newFile;
    if (newPath != imageFile.path) {
      await imageFile.copy(newPath);
      newFile = File(newPath);
      if (!newFile.existsSync()) {
        return false;
      }
    }
    String b_name = "free-socialbook";
    var fileType = f_name.substring(f_name.lastIndexOf(".") + 1);
    if (TextUtil.isEmpty(fileType)) {
      fileType = '*';
    }
    String c_type = "image/${fileType}";
    final params = {
      "bucket": b_name,
      "file_name": f_name,
      "content_type": c_type,
    };
    var url = await CartoonizerApi().getPresignedUrl(params);
    if (url == null) {
      return false;
    }
    var baseEntity = await Uploader().uploadFile(url, imageFile, c_type);
    if (baseEntity != null) {
      var imageUrl = url.split("?")[0];
      updateImageUrl(imageUrl);
      saveUploadHistory(key: key, file: newFile ?? imageFile, url: imageUrl);
      return true;
    }
    return false;
  }

  Future<void> updateCachedId(String cachedId) async {
    if (image.value == null) {
      return;
    }
    var imageFile = image.value as File;
    var key = await md5File(imageFile);
    var cacheFile = imageUploadCache[key];
    if (cacheFile != null) {
      cacheFile.cachedId = cachedId;
    }
    _saveUploadCacheMap();
  }

  Future<String?> getCachedId() async {
    if (image.value == null) {
      return null;
    }
    var imageFile = image.value as File;
    var key = await md5File(imageFile);
    var cacheFile = imageUploadCache[key];
    if (cacheFile != null) {
      return cacheFile.cachedId;
    }
    return null;
  }
}
