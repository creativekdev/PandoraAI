import 'dart:convert';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  late SharedPreferences _sharedPreferences;
  late StorageOperator _storageOperator;

  StorageOperator get storageOperator => _storageOperator;

  @override
  Future<void> onCreate() async {
    await super.onCreate();
    _sharedPreferences = await SharedPreferences.getInstance();
    _storageOperator = StorageOperator();
    _storageOperator.initializeDir();
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
