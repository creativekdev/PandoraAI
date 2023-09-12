import 'dart:io';

import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/admob/splash_ads_holder.dart';
import 'package:cartoonizer/widgets/refresh/headers.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:worker_manager/worker_manager.dart';

class ThirdpartManager extends BaseManager {
  bool _appBackground = false;
  late SplashAdsHolder adsHolder;

  set appBackground(bool value) {
    if (_appBackground != value) {
      _appBackground = value;
      EventBusHelper().eventBus.fire(OnAppStateChangeEvent(data: value));
    }
  }

  bool get appBackground => _appBackground;
  late StreamSubscription onPayStatusListen;

  @override
  Future<void> onCreate() async {
    super.onCreate();
    adsHolder = SplashAdsHolder(maxCacheDuration: Duration(minutes: 5), shownDuration: Duration(minutes: 10));
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) => _onAppStateChanged(state));
    LogUtil.init(tag: 'Cartoonizer', isDebug: !kReleaseMode, maxLen: 256);
    EasyRefresh.defaultHeader = AppClassicalHeader(infoColor: ColorConstant.White);
    EasyRefresh.defaultFooter = ClassicalFooter(textColor: ColorConstant.White, infoColor: ColorConstant.White, enableHapticFeedback: false);
    onPayStatusListen = EventBusHelper().eventBus.on<OnPaySuccessEvent>().listen((event) {
      var string = AppDelegate.instance.getManager<CacheManager>().getString(CacheManager.prePaymentAction);
      if (!TextUtil.isEmpty(string)) {
        Events.paySuccess(source: string);
      }
    });
    Connectivity().onConnectivityChanged.listen((event) {
      EventBusHelper().eventBus.fire(OnNetworkStateChangeEvent(data: event));
    });
    Executor().warmUp(isolatesCount: 2);
  }

  @override
  Future<void> onDestroy() async {
    await super.onDestroy();
    onPayStatusListen.cancel();
    Executor().dispose();
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
      if (Platform.isAndroid) {
        judgeInvitationCode();
      }
      AppDelegate.instance.getManager<UserManager>().refreshUser();
      adsHolder.show();
      appBackground = false;
    } else if (appState == AppState.background) {
      appBackground = true;
    }
  }
}
