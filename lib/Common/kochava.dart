
import 'dart:io';

import 'package:cartoonizer/config.dart';
import 'package:kochava_tracker/kochava_tracker.dart';

class KoChaVa {
  factory KoChaVa() => _getInstance();

  static KoChaVa get instance => _getInstance();
  static KoChaVa? _instance;


  KoChaVa._internal();

  static KoChaVa _getInstance() {
    if (_instance == null) {
      _instance = new KoChaVa._internal();
    }
    return _instance!;
  }

  init() {
    if(Platform.isAndroid) {
      KochavaTracker.instance.registerAndroidAppGuid(KOCHAVA_ANDROID_ID);
    } else if(Platform.isIOS) {
      KochavaTracker.instance.registerIosAppGuid(KOCHAVA_IOS_ID);
    }
    KochavaTracker.instance.start();
  }

}