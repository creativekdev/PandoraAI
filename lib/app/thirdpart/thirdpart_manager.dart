import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/refresh/headers.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'rate_dialog_operator.dart';

class ThirdpartManager extends BaseManager {
  bool _appBackground = false;
  late RateDialogOperator rateDialogOperator;

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
    LogUtil.init(tag: 'Cartoonizer', isDebug: !kReleaseMode);
    EasyRefresh.defaultHeader = AppClassicalHeader(infoColor: ColorConstant.White);
    EasyRefresh.defaultFooter = ClassicalFooter(textColor: ColorConstant.White, infoColor: ColorConstant.White);
  }

  @override
  Future<void> onAllManagerCreate() async {
    super.onAllManagerCreate();
    rateDialogOperator = RateDialogOperator(AppDelegate.instance.getManager<CacheManager>());
    rateDialogOperator.init();
  }
}
