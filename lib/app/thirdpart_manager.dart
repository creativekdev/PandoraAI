import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class ThirdpartManager extends BaseManager {
  @override
  Future<void> onCreate() async {
    super.onCreate();
    LogUtil.init(tag: 'Cartoonizer', isDebug: !kReleaseMode);
    // EasyRefresh.defaultHeader = ClassicalHeader(textColor: ColorConstant.White, infoColor: ColorConstant.White);
    EasyRefresh.defaultFooter = ClassicalFooter(textColor: ColorConstant.White, infoColor: ColorConstant.White);
    EasyRefresh.defaultHeader = MaterialHeader();
  }
}
