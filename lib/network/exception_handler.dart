import 'package:cartoonizer/Common/Extension.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

///
/// @Author: wangyu
/// @Date: 2022/5/31
///
class ExceptionHandler {
  onError(Exception e, {bool toastOnFailed = true}) {
    if (toastOnFailed) {
      if(!kReleaseMode) {
        CommonExtension().showToast(e.toString());
      } else {
        CommonExtension().showToast("Oops Failed!");
      }
    }
  }

  onReqError(String msg, {bool toastOnFailed = true}) {
    if (toastOnFailed) {
      CommonExtension().showToast(msg);
    }
  }
}
