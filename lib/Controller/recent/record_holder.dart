import 'dart:io';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/views/ai/drawable/widget/drawable.dart';

abstract class RecordHolder<T> {
  CacheManager _cacheManager = AppDelegate().getManager();

  Future<bool> saveToCache(List<T> data);

  Future<List<T>> loadFromCache();

  Future<bool> record(List<T> source, T data, {bool toCache = true});
}

class MetaverseHolder extends RecordHolder<RecentMetaverseEntity> {
  @override
  Future<List<RecentMetaverseEntity>> loadFromCache() async {
    List<RecentMetaverseEntity> result = [];
    try {
      var json = _cacheManager.getJson(CacheManager.keyRecentMetaverse);
      result = (json as List<dynamic>).map((e) => RecentMetaverseEntity.fromJson(e)).toList();
      result.forEach((element) {
        element.filePath = element.filePath.filter((t) => File(t).existsSync());
      });
    } catch (e) {}
    return result;
  }

  @override
  Future<bool> record(List<RecentMetaverseEntity> source, RecentMetaverseEntity data, {bool toCache = true}) async {
    var pick = source.pick((e) => e.originalPath == data.originalPath);
    if (pick != null) {
      pick.updateDt = data.updateDt;
      pick.filePath.insertAll(0, data.filePath);
    } else {
      source.insert(0, data);
    }
    if (toCache) {
      await saveToCache(source);
    }
    return true;
  }

  @override
  Future<bool> saveToCache(List<RecentMetaverseEntity> data) async {
    return await _cacheManager.setJson(
      CacheManager.keyRecentMetaverse,
      data.map((e) => e.toJson()).toList(),
    );
  }
}

class EffectRecordHolder extends RecordHolder<RecentEffectModel> {
  @override
  Future<List<RecentEffectModel>> loadFromCache() async {
    List<RecentEffectModel> result = [];
    try {
      var json = _cacheManager.getJson(CacheManager.keyRecentEffects);
      result = (json as List<dynamic>).map((e) => RecentEffectModel.fromJson(e)).toList();
    } catch (e) {}
    return result;
  }

  @override
  Future<bool> record(List<RecentEffectModel> source, RecentEffectModel data, {bool toCache = true}) async {
    var pick = source.pick((e) => e.originalPath == data.originalPath);
    if (pick != null) {
      pick.updateDt = data.updateDt;
      pick.itemList.insertAll(0, data.itemList);
    } else {
      source.insert(0, data);
    }
    if (toCache) {
      await saveToCache(source);
    }
    return true;
  }

  @override
  Future<bool> saveToCache(List<RecentEffectModel> data) async {
    return await _cacheManager.setJson(
      CacheManager.keyRecentEffects,
      data.map((e) => e.toJson()).toList(),
    );
  }
}

class StyleMorphRecordHolder extends RecordHolder<RecentStyleMorphModel> {
  @override
  Future<List<RecentStyleMorphModel>> loadFromCache() async {
    List<RecentStyleMorphModel> result = [];
    try {
      var json = _cacheManager.getJson(CacheManager.keyRecentStyleMorph);
      result = (json as List<dynamic>).map((e) => RecentStyleMorphModel.fromJson(e)).toList();
    } catch (e) {}
    return result;
  }

  @override
  Future<bool> record(List<RecentStyleMorphModel> source, RecentStyleMorphModel data, {bool toCache = true}) async {
    var pick = source.pick((e) => e.originalPath == data.originalPath);
    if (pick != null) {
      pick.updateDt = data.updateDt;
      var old = pick.itemList.pick((t) => t.key == data.itemList.first.key);
      if (old != null) {
        pick.itemList.remove(old);
      }
      pick.itemList.insertAll(0, data.itemList);
    } else {
      source.insert(0, data);
    }
    if (toCache) {
      await saveToCache(source);
    }
    return true;
  }

  @override
  Future<bool> saveToCache(List<RecentStyleMorphModel> data) async {
    return await _cacheManager.setJson(
      CacheManager.keyRecentStyleMorph,
      data.map((e) => e.toJson()).toList(),
    );
  }
}

class Txt2imgRecordHolder extends RecordHolder<RecentGroundEntity> {
  @override
  Future<List<RecentGroundEntity>> loadFromCache() async {
    List<RecentGroundEntity> result = [];
    try {
      var json = _cacheManager.getJson(CacheManager.keyRecentTxt2img);
      result = (json as List<dynamic>).map((e) => RecentGroundEntity.fromJson(e)).toList();
      result = await result.filterSync((t) async {
        if (File(t.filePath ?? '').existsSync()) {
          return true;
        }
        return false;
      });
    } catch (e) {}
    return result;
  }

  @override
  Future<bool> record(List<RecentGroundEntity> source, RecentGroundEntity data, {bool toCache = true}) async {
    source.insert(0, data);
    if (toCache) {
      await saveToCache(source);
    }
    return true;
  }

  @override
  Future<bool> saveToCache(List<RecentGroundEntity> data) async {
    return await _cacheManager.setJson(
      CacheManager.keyRecentAIDraw,
      data.map((e) => e.toJson()).toList(),
    );
  }
}

class AIDrawRecordHolder extends RecordHolder<DrawableRecord> {
  @override
  Future<List<DrawableRecord>> loadFromCache() async {
    List<DrawableRecord> result = [];
    try {
      var json = _cacheManager.getJson(CacheManager.keyRecentAIDraw);
      result = (json as List<dynamic>).map((e) => DrawableRecord.fromJson(e)).toList();
      result = await result.filterSync((t) async {
        t.resultPaths = await t.resultPaths.filterSync((p) async {
          if (File(p).existsSync()) {
            return true;
          } else {
            return false;
          }
        });
        if (t.resultPaths.isEmpty) {
          return false;
        } else {
          return true;
        }
      });
    } catch (e) {}
    return result;
  }

  @override
  Future<bool> record(List<DrawableRecord> source, DrawableRecord data, {bool toCache = true}) async {
    source.insert(0, data);
    if (toCache) {
      await saveToCache(source);
    }
    return true;
  }

  @override
  Future<bool> saveToCache(List<DrawableRecord> data) async {
    return await _cacheManager.setJson(
      CacheManager.keyRecentAIDraw,
      data.map((e) => e.toJson()).toList(),
    );
  }
}
