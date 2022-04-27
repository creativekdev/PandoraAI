import 'dart:io';
import 'package:flutter/foundation.dart';

// ANDROID_CHANNEL -> 单独发布的时候，需要指定一个 channel
// flutter run --dart-define=ANDROID_CHANNEL=apk
const String ANDROID_CHANNEL = String.fromEnvironment('ANDROID_CHANNEL', defaultValue: '');
const String IOS_LINK = 'https://apps.apple.com/us/app/socialbook-cartoonizer/id1604123460';
const String ANDROID_LINK = 'https://play.google.com/store/apps/details?id=io.socialbook.cartoonizer';

abstract class BaseConfig {
  String host = '';
  String aiHost = '';
  String get apiHost;
  String stripePublishableKey = '';
}

class DevelopmentConfig implements BaseConfig {
  // localhost
  // String host = 'http://localhost:8090';
  // String aiHost = 'http://localhost:3000';

  // android emulator
  // String host = 'http://10.0.2.2:8090';
  // String aiHost = 'http://10.0.2.2:3000';

  // real phone
  String host = 'http://192.168.31.126:8090';
  String aiHost = 'http://192.168.31.126:3000';

  // io
  // String host = 'https://socialbook.io';
  // String aiHost = 'https://ai.socialbook.io';

  String get apiHost => '$host/api';
  String stripePublishableKey = 'pk_test_UsnDHZEjE4QwOJxl0J7Jk2Os';
}

class ProductionConfig implements BaseConfig {
  String host = 'https://socialbook.io';
  String aiHost = 'https://ai.socialbook.io';
  String get apiHost => '$host/api';
  String stripePublishableKey = 'pk_live_Rhji9hzPepvF00Mfh7GpWyeE';
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

  static String getStoreLink() {
    if (Platform.isIOS) {
      return IOS_LINK;
    } else {
      return ANDROID_LINK;
    }
  }
}
