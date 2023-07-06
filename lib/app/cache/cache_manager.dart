import 'dart:async';
import 'dart:convert';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/app_feature_operator.dart';
import 'package:cartoonizer/app/cache/img_summary_cache.dart';
import 'package:cartoonizer/app/cache/photo_source_operator.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/utils/array_util.dart';
import 'package:common_utils/common_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'image_scale_operator.dart';

class CacheManager extends BaseManager {
  static const keyHasIntroductionPageShowed = "HAS_INTRODUCTION_PAGE_SHOWED";
  static const keyRecentStyleMorph = "recent_style_morph_file";
  static const keyRecentEffects = "recent_effect_file";
  static const keyRecentTxt2img = "recent_ai_ground_file";
  static const keyRecentAIDraw = "recent_ai_draw_file";
  static const keyRecentAIColoring = "recent_ai_coloring_file";
  static const keyRecentMetaverse = "recent_metaverse_file";
  static const keyLastVideoAdsShowTime = "LAST_ADS_SHOW_TIME";
  static const keyLoginCookie = "login_cookie";
  static const keyCurrentUser = "user_info";
  static const keyAiServer = "ai_servers";
  static const keyAdConfig = "ad_config";
  static const limitRule = "limit_rule";
  static const keyCacheInput = "cache_input";
  static const keyLastTabAttached = "last_tab_attached";
  static const keyLastEffectTabAttached = "last_effect_tab_attached";
  static const _rateConfig = 'rate_config';
  static const effectLastRandomTime = 'effect_last_random_time';
  static const effectAllData = 'effect_config_data';
  static const scaleCacheData = 'scaleCacheData';
  static const nsfwOpen = 'nsfw_open';
  static const imageUploadHistory = 'image_upload_history';
  static const imageCropHistory = 'image_crop_history';
  static const pushToken = 'push_token';
  static const imageScaled = 'image_scaled';
  static const photoSourceFace = 'photo_sources_face';
  static const photoSourceOther = 'photo_sources_other';
  static const avatarHistory = 'avatar_history';
  static const lastCreateAvatar = 'last_create_avatar';
  static const lastAlbum = 'last_album';
  static const preLoginAction = 'pre_login_action';
  static const preSignupAction = 'pre_signup_action';
  static const prePaymentAction = 'pre_payment_action';
  static const txt2imgStyles = 'ai_ground_styles';
  static const lastFeedback = 'last_feed_back';
  static const lastAppFeature = 'last_app_feature';
  static const lastShownFeatureSign = 'last_shown_feature_sign';
  static const cacheDiscoveryListEntity = 'discovery_list_entity';
  static const lastRefLink = 'last_ref_link';
  static const cacheImageSummary = 'image_summary';
  static const commentList = 'commentList';
  static const platformConnections = 'platform_connections';
  static const viewPreviewOpen = 'video_preview_open';
  static const backgroundPickHistory = 'backgroundPickHistory';
  static const backgroundTabIndexHistory= 'backgroundTabIndexHistory';

  late SharedPreferences _sharedPreferences;
  late StorageOperator _storageOperator;
  late ImageScaleOperator _imageScaleOperator;
  late PhotoSourceOperator _photoSourceOperator;
  late AppFeatureOperator _featureOperator;
  late ImgSummaryCache _imgSummaryCache;

  StorageOperator get storageOperator => _storageOperator;

  ImageScaleOperator get imageScaleOperator => _imageScaleOperator;

  PhotoSourceOperator get photoSourceOperator => _photoSourceOperator;

  AppFeatureOperator get featureOperator => _featureOperator;

  ImgSummaryCache get imgSummaryCache => _imgSummaryCache;

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
    _featureOperator = AppFeatureOperator(cacheManager: this);
    _imgSummaryCache = ImgSummaryCache(cacheManager: this);
    _imgSummaryCache.init();
  }

  List<String> keys(String partKey) {
    return _sharedPreferences
        .getKeys()
        .toList()
        .filter(
          (t) => t.contains(partKey),
        )
        .toList();
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
      LogUtil.d('get cache ${key} failed: ${e}');
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
