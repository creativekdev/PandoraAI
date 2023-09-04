import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:dio/dio.dart';

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

  Future<String?> upload({required File file, bool cache = true, ProgressCallback? onSendProgress, bool matting = false}) async {
    var key = await md5File(file);
    var cacheUrl = _getCachedUrl(key);
    if (cacheUrl != null) {
      return cacheUrl;
    }
    var uploadFile;
    if (file.path.isImageFile) {
      EffectManager effectManager = AppDelegate().getManager();
      int imageSize;
      if (matting) {
        imageSize = effectManager.data?.mattingMaxl ?? 512;
      } else {
        imageSize = effectManager.data?.imageMaxl ?? 512;
      }
      uploadFile = await imageCompressAndGetFile(file, imageSize: imageSize);
    } else {
      uploadFile = file;
    }
    var url = await api.uploadToS3(uploadFile, true, onSendProgress: onSendProgress);
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
