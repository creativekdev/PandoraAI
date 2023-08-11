import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class UploadImageController1 extends GetxController {
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late StorageOperator storageOperator;
  List<UploadRecordEntity> imageUploadCache = [];

  final imageUrl = "".obs;

  updateImageUrl(String str) => imageUrl.value = str;

  UploadImageController1() {
    storageOperator = cacheManager.storageOperator;
    loadImageUploadCache();
  }

  @override
  void onInit() {
    super.onInit();
    // storageOperator = cacheManager.storageOperator;
    // loadImageUploadCache();
  }

  Future<void> loadImageUploadCache() async {
    imageUploadCache.clear();
    dynamic jsonString = cacheManager.getJson(CacheManager.imageUploadHistory) ?? [];
    if (jsonString is List) {
      jsonString.forEach((value) async {
        var uploadRecordEntity = UploadRecordEntity.fromJson(json.decode(value));
        if (File(uploadRecordEntity.fileName).existsSync()) {
          uploadRecordEntity.checked = false;
          if (!imageUploadCache.exist((t) => t.key == uploadRecordEntity.key)) {
            imageUploadCache.add(uploadRecordEntity);
          }
        }
      });
    }
  }

  saveUploadHistory({
    required String key,
    required File file,
    required String url,
  }) async {
    var cache = imageUploadCache.pick((t) => t.key == key);
    if (cache != null) {
      cache.url = url;
      cache.fileName = file.path;
      cache.createDt = DateTime.now().millisecondsSinceEpoch;
      imageUploadCache.remove(cache);
    } else {
      cache = UploadRecordEntity();
      cache.key = key;
      cache.url = url;
      cache.fileName = file.path;
      cache.createDt = DateTime.now().millisecondsSinceEpoch;
    }
    imageUploadCache.insert(0, cache);
    _saveUploadCacheMap();
    update();
  }

  void _saveUploadCacheMap() {
    List<String> cache = imageUploadCache.map((e) => jsonEncode(e.toJson())).toList();
    cacheManager.setJson(CacheManager.imageUploadHistory, cache);
  }

  Future<bool> needUpload(File? imageFile) async {
    if (imageFile == null) {
      return true;
    }
    var key = await md5File(imageFile);
    return needUploadByKey(key);
  }

  bool needUploadByKey(String key) {
    var cacheFile = imageUploadCache.pick((t) => t.key == key);
    if (cacheFile != null && !cacheFile.urlExpired()) {
      updateImageUrl(cacheFile.url);
      return false;
    }
    return true;
  }

  Future<void> deleteUploadData(File? imageFile, {String? key}) async {
    if (imageFile == null && key == null) {
      return;
    }
    if (imageFile != null) {
      if (key == null) {
        key = await md5File(imageFile);
      }
    }
    var cacheFile = imageUploadCache.pick((t) => t.key == key);
    if (cacheFile != null) {
      imageUploadCache.remove(cacheFile);
      _saveUploadCacheMap();
      updateImageUrl('');
    }
  }

  Future<bool> uploadCompressedImage(File? imageFile, {String? key, bool cache = true}) async {
    if (imageFile == null) {
      return false;
    }
    if (key == null) {
      key = await md5File(imageFile);
    }
    var cacheFile = imageUploadCache.pick((t) => t.key == key);
    if (cacheFile != null && !cacheFile.urlExpired()) {
      updateImageUrl(cacheFile.url);
      return true;
    }
    if (imageFile.path.toLowerCase().endsWith('heic')) {
      imageFile = await heicFileToImage(imageFile);
    }
    if (imageFile == null) {
      return false;
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
    var url = await AppApi().getPresignedUrl(params);
    if (url == null) {
      return false;
    }
    var baseEntity = await Uploader().uploadFile(url, imageFile, c_type);
    if (baseEntity != null) {
      var imageUrl = url.split("?")[0];
      updateImageUrl(imageUrl);
      if (cache) {
        saveUploadHistory(key: key, file: newFile ?? imageFile, url: imageUrl);
      }
      return true;
    }
    return false;
  }

  Future<void> updateCachedId(File? imageFile, String cachedId) async {
    if (imageFile == null) {
      return;
    }
    var key = await md5File(imageFile);
    var cacheFile = imageUploadCache.pick((t) => t.key == key);
    if (cacheFile != null) {
      cacheFile.cachedId = cachedId;
      _saveUploadCacheMap();
    }
  }

  Future<String?> getCachedId(File? imageFile) async {
    if (imageFile == null) {
      return null;
    }
    var key = await md5File(imageFile);
    return getCachedIdByKey(key);
  }

  Future<String?> getCachedIdByKey(String key) async {
    var cacheFile = imageUploadCache.pick((t) => t.key == key);
    if (cacheFile != null) {
      return cacheFile.cachedId;
    }
    return null;
  }

  deleteAllCheckedPhotos() {
    imageUploadCache = imageUploadCache.filter((t) => !t.checked);
    _saveUploadCacheMap();
  }
}

class UploadImageController extends GetxController {
  CacheManager cacheManager = AppDelegate().getManager();
  List<UploadRecordEntity> uploadCache = [];
  late AppApi api;

  Map<String, Rx<String>> _urlList = {};

  Rx<String> imageUrl(File file) {
    var target = _urlList[file.path];
    if (target != null) {
      return target;
    } else {
      target = ''.obs;
      _urlList[file.path] = target;
      return target;
    }
  }

  @override
  void onInit() {
    super.onInit();
    api = AppApi().bindController(this);
    _loadImageUploadCache();
  }

  Future<void> _loadImageUploadCache() async {
    uploadCache.clear();
    dynamic jsonString = cacheManager.getJson(CacheManager.imageUploadHistory) ?? [];
    if (jsonString is List) {
      jsonString.forEach((value) async {
        var uploadRecordEntity = UploadRecordEntity.fromJson(json.decode(value));
        if (File(uploadRecordEntity.fileName).existsSync()) {
          uploadRecordEntity.checked = false;
          if (!uploadCache.exist((t) => t.key == uploadRecordEntity.key)) {
            uploadCache.add(uploadRecordEntity);
            _urlList[uploadRecordEntity.originFileName] = uploadRecordEntity.url.obs;
          }
        }
      });
    }
  }

  _saveUploadHistory({
    required String key,
    required File file,
    required String url,
    required File originalFile,
  }) async {
    var cache = uploadCache.pick((t) => t.key == key);
    if (cache != null) {
      cache.url = url;
      cache.originFileName = originalFile.path;
      cache.fileName = file.path;
      cache.createDt = DateTime.now().millisecondsSinceEpoch;
      uploadCache.remove(cache);
    } else {
      cache = UploadRecordEntity();
      cache.originFileName = originalFile.path;
      cache.key = key;
      cache.url = url;
      cache.fileName = file.path;
      cache.createDt = DateTime.now().millisecondsSinceEpoch;
    }
    uploadCache.insert(0, cache);
    _saveUploadCacheMap();
    update();
  }

  void _saveUploadCacheMap() {
    List<String> cache = uploadCache.map((e) => jsonEncode(e.toJson())).toList();
    cacheManager.setJson(CacheManager.imageUploadHistory, cache);
  }

  String? _getCachedUrl(String key) {
    var cacheFile = uploadCache.pick((t) => t.key == key);
    if (cacheFile != null && !cacheFile.urlExpired()) {
      return cacheFile.url;
    }
    return null;
  }

  Future<String?> upload({required File file, bool cache = true, ProgressCallback? onSendProgress}) async {
    var key = await md5File(file);
    var cacheUrl = _getCachedUrl(key);
    if (cacheUrl != null) {
      return cacheUrl;
    }
    var uploadFile;
    if (file.path.isImageFile) {
      EffectManager effectManager = AppDelegate().getManager();
      var imageSize = effectManager.data?.imageMaxl ?? 512;
      uploadFile = await imageCompressAndGetFile(file, imageSize: imageSize);
    } else {
      uploadFile = file;
    }
    var url = await api.uploadToS3(file, true, onSendProgress: onSendProgress);
    if (url != null) {
      Rx<String> target;
      if (_urlList[file.path] == null) {
        target = url.obs;
        _urlList[file.path] = target;
      } else {
        target = _urlList[file.path]!;
        target.value = url;
      }
      if (cache) {
        _saveUploadHistory(key: key, file: uploadFile, url: url, originalFile: file);
      }
      return url;
    }
    return null;
  }

  Future<void> updateCachedId(File? imageFile, String cachedId) async {
    if (imageFile == null) {
      return;
    }
    var key = await md5File(imageFile);
    var cacheFile = uploadCache.pick((t) => t.key == key);
    if (cacheFile != null) {
      cacheFile.cachedId = cachedId;
      _saveUploadCacheMap();
    }
  }

  Future<String?> getCachedId(File? file) async {
    if (file == null) {
      return null;
    }
    var key = await md5File(file);
    return getCachedIdByKey(key);
  }

  Future<String?> getCachedIdByKey(String key) async {
    var cacheFile = uploadCache.pick((t) => t.key == key);
    if (cacheFile != null) {
      return cacheFile.cachedId;
    }
    return null;
  }

  deleteAllCheckedPhotos() {
    uploadCache = uploadCache.filter((t) => !t.checked);
    _saveUploadCacheMap();
  }

  Future<void> deleteUploadData(File file) async {
    _urlList[file.path]?.value = '';
    String key = await md5File(file);
    var cacheFile = uploadCache.pick((t) => t.key == key);
    if (cacheFile != null) {
      uploadCache.remove(cacheFile);
      var file = File(cacheFile.fileName);
      if (file.existsSync()) {
        file.deleteSync();
      }
      _saveUploadCacheMap();
    }
  }
}
