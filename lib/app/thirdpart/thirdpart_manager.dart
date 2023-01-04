import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/admob/splash_ads_holder.dart';
import 'package:cartoonizer/Widgets/refresh/headers.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ThirdpartManager extends BaseManager {
  bool _appBackground = false;
  late SplashAdsHolder adsHolder;

  set appBackground(bool value) {
    if (_appBackground != value) {
      _appBackground = value;
      EventBusHelper().eventBus.fire(OnAppStateChangeEvent());
    }
  }

  bool get appBackground => _appBackground;

  @override
  Future<void> onCreate() async {
    super.onCreate();
    adsHolder = SplashAdsHolder(maxCacheDuration: Duration(minutes: 5), shownDuration: Duration(minutes: 10));
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) => _onAppStateChanged(state));
    LogUtil.init(tag: 'Cartoonizer', isDebug: !kReleaseMode);
    EasyRefresh.defaultHeader = AppClassicalHeader(infoColor: ColorConstant.White);
    EasyRefresh.defaultFooter = ClassicalFooter(textColor: ColorConstant.White, infoColor: ColorConstant.White);
  }

  initRefresh(Locale? result) {
    if (result?.languageCode == 'zh') {
      EasyRefresh.defaultFooter = ClassicalFooter(
        textColor: ColorConstant.White,
        infoColor: ColorConstant.White,
        loadedText: '加载完成',
        loadFailedText: '加载失败',
        noMoreText: '没有更多了',
        infoText: '上次更新 %T',
      );
    } else {
      EasyRefresh.defaultFooter = ClassicalFooter(
        textColor: ColorConstant.White,
        infoColor: ColorConstant.White,
        loadedText: 'Load completed',
        loadFailedText: 'Load failed',
        noMoreText: 'No more',
        infoText: 'Update at %T',
      );
    }
  }

  void _onAppStateChanged(AppState appState) {
    if (appState == AppState.foreground) {
      adsHolder.show();
      appBackground = false;
    } else if (appState == AppState.background) {
      appBackground = true;
    }
  }

  String getLocaleString(BuildContext context, String str) {
    switch (str.toLowerCase()) {
      case 'recent':
        return S.of(context).recent;
      case 'get inspired':
        return S.of(context).get_inspired;
      case 'facetoon':
        return S.of(context).face_toon;
      case 'effects':
        return S.of(context).effects;
      case 'january':
        return S.of(context).january;
      case 'february':
        return S.of(context).february;
      case 'march':
        return S.of(context).march;
      case 'april':
        return S.of(context).april;
      case 'may':
        return S.of(context).may;
      case 'june':
        return S.of(context).june;
      case 'july':
        return S.of(context).july;
      case 'august':
        return S.of(context).august;
      case 'september':
        return S.of(context).september;
      case 'october':
        return S.of(context).october;
      case 'november':
        return S.of(context).november;
      case 'december':
        return S.of(context).december;
      default:
        return str;
    }
  }
}
