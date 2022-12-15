import 'dart:async';
import 'dart:convert';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/photo_source_operator.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'image_scale_operator.dart';

class CacheManager extends BaseManager {
  static const keyHasIntroductionPageShowed = "HAS_INTRODUCTION_PAGE_SHOWED";
  static const keyRecentEffects = "RECENT_EFFECTS";
  static const keyLastVideoAdsShowTime = "LAST_ADS_SHOW_TIME";
  static const keyLoginCookie = "login_cookie";
  static const keyCurrentUser = "user_info";
  static const keyAiServer = "ai_servers";
  static const keyCacheInput = "cache_input";
  static const keyLastTabAttached = "last_tab_attached";
  static const keyLastEffectTabAttached = "last_effect_tab_attached";
  static const _rateConfig = 'rate_config';
  static const effectLastRandomTime = 'effect_last_random_time';
  static const effectAllData = 'effect_all_data';
  static const scaleCacheData = 'scaleCacheData';
  static const nsfwOpen = 'nsfw_open';
  static const imageUploadHistory = 'image_upload_history';
  static const imageCropHistory = 'image_crop_history';
  static const pushToken = 'push_token';
  static const imageScaled = 'image_scaled';
  static const photoSourceFace = 'photo_source_face';
  static const photoSourceOther = 'photo_source_other';
  static const avatarHistory = 'avatar_history';

  late SharedPreferences _sharedPreferences;
  late StorageOperator _storageOperator;
  late ImageScaleOperator _imageScaleOperator;
  late PhotoSourceOperator _photoSourceOperator;

  StorageOperator get storageOperator => _storageOperator;

  ImageScaleOperator get imageScaleOperator => _imageScaleOperator;

  PhotoSourceOperator get photoSourceOperator => _photoSourceOperator;

  @override
  Future<void> onCreate() async {
    await super.onCreate();
    _sharedPreferences = await SharedPreferences.getInstance();
    _storageOperator = StorageOperator();
    _storageOperator.initializeDir();
    _imageScaleOperator = ImageScaleOperator(cacheManager: this);
    _imageScaleOperator.loadCache();
    _photoSourceOperator = PhotoSourceOperator(cacheManager: this);
    _photoSourceOperator.init();
  }

  String rateConfigKey() {
    return _rateConfig;
  }

  String getString(String key) {
    return _sharedPreferences.getString(key) ?? '';
  }

  Future<bool> setString(String key, String? value) async {
    if (value == null) {
      return _sharedPreferences.remove(key);
    } else {
      return _sharedPreferences.setString(key, value);
    }
  }

  bool getBool(String key) {
    return _sharedPreferences.getBool(key) ?? false;
  }

  Future<bool> setBool(String key, bool? value) async {
    if (value == null) {
      return _sharedPreferences.remove(key);
    } else {
      return _sharedPreferences.setBool(key, value);
    }
  }

  int getInt(String key) {
    return _sharedPreferences.getInt(key) ?? 0;
  }

  Future<bool> setInt(String key, int? value) async {
    if (value == null) {
      return _sharedPreferences.remove(key);
    } else {
      return _sharedPreferences.setInt(key, value);
    }
  }

  dynamic getJson(String key) {
    var string = getString(key);
    try {
      return jsonDecode(string);
    } on FormatException catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> setJson(String key, dynamic json) async {
    if (json == null) {
      return _sharedPreferences.remove(key);
    }
    return _sharedPreferences.setString(key, jsonEncode(json));
  }

  clear() {
    _sharedPreferences.clear();
  }
}
