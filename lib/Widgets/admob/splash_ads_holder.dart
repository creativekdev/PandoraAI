import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/admob/ads_holder.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/PurchaseScreen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../views/StripeSubscriptionScreen.dart';

class SplashAdsHolder extends PageAdsHolder {
  /// 广告重载间隔
  late Duration maxCacheDuration;

  /// 广告展示间隔
  late Duration shownDuration;

  DateTime? _appOpenLoadTime;
  DateTime? _lastShownTime;

  AppOpenAd? _appOpenAd;

  bool _isShowingAd = false;
  bool _isLoadingAd = false;
  bool ignore = false;

  bool get isLoadingAd => _isLoadingAd;

  set isLoadingAd(bool value) {
    if (_isLoadingAd != value) {
      _isLoadingAd = value;
      EventBusHelper().eventBus.fire(OnSplashAdLoadingChangeEvent());
    }
  }

  SplashAdsHolder({required this.maxCacheDuration, required this.shownDuration});

  @override
  initHolder() {
    loadAd();
  }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  @override
  onDispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }

  loadAd() {
    if (isLoadingAd) {
      return;
    }
    isLoadingAd = true;
    AppOpenAd.load(
      adUnitId: AdMobConfig.SPLASH_AD_ID,
      orientation: AppOpenAd.orientationPortrait,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('$ad loaded');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
          isLoadingAd = false;
          var mediationAdapterClassName = _appOpenAd?.responseInfo?.mediationAdapterClassName;
          if (!TextUtil.isEmpty(mediationAdapterClassName)) {
            logEvent(Events.admob_source_data, eventValues: {
              'id': _appOpenAd?.responseInfo?.responseId,
              'mediationClassName': mediationAdapterClassName,
            });
          }
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
          isLoadingAd = false;
        },
      ),
    );
  }

  @override
  show() {
    showIfAvailable();
  }

  showIfAvailable({Function? callback}) {
    if (ignore) {
      return;
    }
    if (!isShowAdsNew()) {
      return;
    }
    if (!isAdAvailable) {
      print('Tried to show ad before available.');
      loadAd();
      callback?.call();
      return;
    }
    if (_isShowingAd) {
      print('Tried to show ad while already showing an ad.');
      callback?.call();
      return;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      print('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAd();
      callback?.call();
      return;
    }
    if (_lastShownTime != null && DateTime.now().subtract(shownDuration).isAfter(_lastShownTime!)) {
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        callback?.call();
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        callback?.call();
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
        if (isShowAdsNew()) {
          delay(() {
            if (Platform.isIOS) {
              Get.to(PurchaseScreen());
            } else {
              Get.to(StripeSubscriptionScreen());
            }
          }, milliseconds: 100);
        }
      },
    );
    _appOpenAd!.show();
    _lastShownTime = DateTime.now();
  }
}
