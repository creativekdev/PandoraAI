import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/admob/splash_ads_holder.dart';
import 'package:cartoonizer/Widgets/refresh/headers.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:common_utils/common_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  void _onAppStateChanged(AppState appState) {
    print('New AppState state: $appState');
    if (appState == AppState.foreground) {
      adsHolder.show();
      appBackground = false;
    } else if (appState == AppState.background) {
      appBackground = true;
    }
  }
}
