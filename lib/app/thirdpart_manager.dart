import 'package:cartoonizer/app/app.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';

class ThirdpartManager extends BaseManager {
  @override
  Future<void> onCreate() async {
    super.onCreate();
    LogUtil.init(tag: 'Cartoonizer', isDebug: !kReleaseMode);
  }
}
