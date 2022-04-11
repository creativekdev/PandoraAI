import 'package:flutter/foundation.dart';

abstract class BaseConfig {
  String host = '';
  String get apiHost;
}

class DevelopmentConfig implements BaseConfig {
  // localhost
  // String host = 'http://localhost:8090';

  // android emulator
  // String host = 'http://10.0.2.2:8090';

  // real phone
  // String host = 'http://192.168.31.126:8090';
  String host = 'https://socialbook.io';

  String get apiHost => '$host/api';
}

class ProductionConfig implements BaseConfig {
  String host = 'https://socialbook.io';
  String get apiHost => '$host/api';
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
