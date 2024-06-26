import 'dart:io';

import 'package:flutter/foundation.dart';

// ANDROID_CHANNEL -> 单独发布的时候，需要指定一个 channel
// flutter run --dart-define=ANDROID_CHANNEL=apk
const String ANDROID_CHANNEL = String.fromEnvironment('ANDROID_CHANNEL', defaultValue: '');
const String IOS_APP_ID = '1604123460';
const String IOS_LINK = 'https://apps.apple.com/us/app/socialbook-cartoonizer/id$IOS_APP_ID';
const String ANDROID_STORE_ID = 'io.socialbook.cartoonizer';
const String ANDROID_LINK = 'https://play.google.com/store/apps/details?id=$ANDROID_STORE_ID';
const String APP_NAME = 'ppm';
const String KOCHAVA_ANDROID_ID = 'koprofilepicmaker-cartoon-photo-2wd2';
const String KOCHAVA_IOS_ID = 'koprofilepicmaker-cartoon-photo-9i4q';
const String PLATFORM_CHANNEL = 'io.socialbook/cartoonizer';
const String APP_TITLE = 'Pandora AI';
const String REF_CODE_LINK = 'pai://pandora.ai?rf=';
const String ALIPAY_SCHEML_ANDROID = 'alipays://';
const String ALIPAY_SCHEML_IOS = 'alipay://';
const String USER_PRIVACY = "https://socialbook.io/privacy/cartoonizer";
const String TERM_AND_USE = "https://socialbook.io/terms";
const String HELP_URL = "https://socialbook.io/help/";
const String APP_HASH_VALUE = "qCO0coA8g8D";

class AdMobConfig {
  static bool _debug = false;

  static String get BANNER_AD_ID => _debug
      ? 'ca-app-pub-3940256099942544/6300978111' // 测试用卡片广告id
      : (Platform.isIOS ? 'ca-app-pub-8401689731796078/8652267983' : 'ca-app-pub-8401689731796078/5848358283');

  static String get INTERSTITIAL_AD_ID => _debug
      ? 'ca-app-pub-3940256099942544/8691691433' // 测试用全屏广告id;
      : (Platform.isIOS ? 'ca-app-pub-8401689731796078/4681233383' : 'ca-app-pub-8401689731796078/2693627626');

  static String get DISCOVERY_AD_ID => _debug
      ? 'ca-app-pub-3940256099942544/6300978111' // 测试用发现页广告id
      : (Platform.isIOS ? 'ca-app-pub-8401689731796078/6102802285' : 'ca-app-pub-8401689731796078/9945860280');

  static String get PROCESSING_AD_ID => _debug
      ? 'ca-app-pub-3940256099942544/6300978111' // 测试用转换进度广告id
      : (Platform.isIOS ? 'ca-app-pub-8401689731796078/9839371890' : 'ca-app-pub-8401689731796078/3676454072');

  static String get REWARD_PROCESSING_AD_ID => _debug
      ? 'ca-app-pub-3940256099942544/5354046379' // 测试用激励广告id
      : (Platform.isIOS ? 'ca-app-pub-8401689731796078/9280521582' : 'ca-app-pub-8401689731796078/4291918781');

  static String get SPLASH_AD_ID => _debug
      ? 'ca-app-pub-3940256099942544/3419835294' // 测试开屏广告id
      : (Platform.isIOS ? 'ca-app-pub-8401689731796078/5951671113' : 'ca-app-pub-8401689731796078/2274729104');

  static String get INSPIRED_BANNER_AD1_ID => _debug
      ? 'ca-app-pub-3940256099942544/6300978111' // 测试用卡片广告id
      : (Platform.isIOS ? 'ca-app-pub-8401689731796078/5614223173' : 'ca-app-pub-8401689731796078/9297483160');

  static String get INSPIRED_BANNER_AD2_ID => _debug
      ? 'ca-app-pub-3940256099942544/6300978111' // 测试用卡片广告id
      : (Platform.isIOS ? 'ca-app-pub-8401689731796078/6529571798' : 'ca-app-pub-8401689731796078/6161018086');
}

abstract class BaseConfig {
  late String host;
  late String aiHost;

  String get apiHost;

  late String stripePublishableKey;
  late String appsflyerKey;
  late String text2imageHost;
  late String metagramSocket;
  late String metagramSocketSchema;
  late int metagramSocketPort;

  String get successUrl;

  String get cancelUrl;

// appsflyer config
// {"ios":{"id":id1604123460, devKey:"yUFpSbmg7YDETaZ5CQ2HkA", prodKey:"af_prod_key"}}
// {"android":{"id":io.socialbook.cartoonizer, devKey:"yUFpSbmg7YDETaZ5CQ2HkA", prodKey:"af_prod_key"}}
}

class DevelopmentConfig implements BaseConfig {
  // localhost
  // String host = 'http://localhost:8090';
  // String aiHost = 'http://localhost:3000';

  // android emulator
  // String host = 'http://10.0.2.2:8090';
  // String aiHost = 'http://10.0.2.2:3000';

  // real phone
  // String host = 'http://192.168.31.126:8090';
  // String aiHost = 'http://192.168.31.126:3000';

  // io
  String host = 'https://socialbook.io';
  String aiHost = 'https://ai.socialbook.io';

  String get apiHost => '$host/api';
  String stripePublishableKey = 'pk_test_UsnDHZEjE4QwOJxl0J7Jk2Os';
  String appsflyerKey = "yUFpSbmg7YDETaZ5CQ2HkA";
  String text2imageHost = "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/sd";
  String metagramSocket = 'io.socialbook.io';
  String metagramSocketSchema = 'https';
  int metagramSocketPort = 443;

  String get successUrl => "$host/pay_success_screen";

  String get cancelUrl => "$host/pay_cancel_screen";
}

class ProductionConfig implements BaseConfig {
  String host = 'https://socialbook.io';
  String aiHost = 'https://ai.socialbook.io';

  String get apiHost => '$host/api';
  String stripePublishableKey = 'pk_live_Rhji9hzPepvF00Mfh7GpWyeE';
  String appsflyerKey = "yUFpSbmg7YDETaZ5CQ2HkA";
  String text2imageHost = "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/sd";
  String metagramSocket = 'io.socialbook.io';
  String metagramSocketSchema = 'https';
  int metagramSocketPort = 443;

  String get successUrl => "$host/pay_success_screen";

  String get cancelUrl => "$host/pay_cancel_screen";
}

class Config {
  Config._init();

  static BaseConfig? _instance;

  static BaseConfig get instance {
    _instance ??= _getConfig();
    return _instance!;
  }

  static BaseConfig _getConfig() {
    if (kReleaseMode) {
      return ProductionConfig();
    } else {
      return DevelopmentConfig();
    }
  }

  static String getAppLink() {
    return 'https://allsha.re/a/pandoraai';
  }

  static String getStoreLink({bool toRate = false}) {
    if (Platform.isIOS) {
      return toRate ? IOS_LINK + "?action=write-review" : IOS_LINK;
    } else {
      return toRate ? ANDROID_LINK + "&reviewId=0" : ANDROID_LINK;
    }
  }
}
