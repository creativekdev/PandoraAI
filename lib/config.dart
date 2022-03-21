import 'package:flutter/foundation.dart';

abstract class BaseConfig {
  String host = '';
  String get apiHost;
}

class DevelopmentConfig implements BaseConfig {
  String host = '192.168.31.126';
  String get apiHost => 'http://$host:8090/api';
}

class ProductionConfig implements BaseConfig {
  String host = 'socialbook.io';
  String get apiHost => 'https://$host/api';
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
}
