import 'dart:io';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/enums/ad_type.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/payment/PurchaseScreen.dart';
import 'package:cartoonizer/widgets/admob/ads_holder.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../views/payment/StripeSubscriptionScreen.dart';

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

  SplashAdsHolder({required this.maxCacheDuration, required this.shownDuration}) : super();

  @override
  initHolder() {
    if (!isShowAdsNew(type: AdType.splash)) {
      return;
    }
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
          print('AppOpenId loaded: ${ad.responseInfo?.responseId}');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
          isLoadingAd = false;
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
    if (!isShowAdsNew(type: AdType.splash)) {
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
        if (!AppDelegate.instance.getManager<UserManager>().isNeedLogin) {
          if (isShowAdsNew(type: AdType.splash)) {
            delay(() {
              if (Platform.isIOS) {
                Get.to(PurchaseScreen());
              } else {
                Get.to(StripeSubscriptionScreen());
              }
            }, milliseconds: 500);
          }
        }
      },
    );
    _appOpenAd!.show();
    _lastShownTime = DateTime.now();
  }
}
