import 'package:flutter/cupertino.dart';

abstract class AdsHolder {
  bool _adsReady = false;

  bool get adsReady => _adsReady;

  @protected
  initHolder();

  onReady() {
    _adsReady = true;
  }

  onReset(){
    _adsReady = false;
  }

  @protected
  onDispose();

  Widget? buildAdWidget();
}
