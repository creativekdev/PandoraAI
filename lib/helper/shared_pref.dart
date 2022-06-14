import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const keyHasIntroductionPageShowed = "HAS_INTRODUCTION_PAGE_SHOWED";
  static const keyRecentEffects = "RECENT_EFFECTS";
  static const keyLastVideoAdsShowTime = "LAST_ADS_SHOW_TIME";

  static Future<String> getString(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(key) ?? '';
  }

  static Future<void> setString(String key, String value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(key, value);
  }

  static Future<bool> getBool(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(key) ?? false;
  }

  static Future<void> setBool(String key, bool value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }

  static Future<bool> setInt(String key, int value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setInt(key, value);
  }

  static Future<int> getInt(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt(key) ?? 0;
  }
}
