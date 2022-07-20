import 'package:flutter/cupertino.dart';

abstract class AdsHolder {
  bool _adsReady = false;

  bool get adsReady => _adsReady;

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
  Widget? buildAdWidget();
}

abstract class PageAdsHolder extends AdsHolder {
  show();
}
