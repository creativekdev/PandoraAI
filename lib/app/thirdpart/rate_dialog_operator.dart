import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:flutter/material.dart';

class RateDialogOperator {
  final CacheManager cacheManager;

  bool _needShow = false;

  RateDialogOperator(this.cacheManager);

  init() {
    _refreshRateState();
  }

  reset() {
    _refreshRateState();
  }

  _refreshRateState() {
    
  }

  Future<bool> autoShow(BuildContext context) async {
    if (!_needShow) {
      return false;
    }

    return true;
  }
}
