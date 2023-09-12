import 'package:cartoonizer/widgets/admob/ads_cache.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';

abstract class AdsHolder {
  late String key;
  AdsCache cache = AdsCache.instance;
  bool _adsReady = false;

  bool get adsReady => _adsReady;

  AdsHolder({String? key}) {
    this.key = key ??= EncryptUtil.encodeMd5('${DateTime.now().millisecondsSinceEpoch}');
  }

  initHolder();

  onReady() {
    _adsReady = true;
  }

  onReset() {
    _adsReady = false;
  }

  onDispose();
}

abstract class WidgetAdsHolder extends AdsHolder {
  WidgetAdsHolder({String? key}) : super(key: key);

  Widget? buildAdWidget();
}

abstract class PageAdsHolder extends AdsHolder {
  PageAdsHolder({String? key}) : super(key: key);

  show();
}
