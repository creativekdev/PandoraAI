import 'package:get/get.dart';

///
/// @Author: wangyu
/// @Date: 2022/5/31
///
class ExceptionHandler {
  onError(Exception e, {bool toastOnFailed = true}) {
    if (toastOnFailed) {
      Get.snackbar("Error", e.toString());
    }
  }

  onReqError(String msg, {bool toastOnFailed = true}) {
    if (toastOnFailed) {
      Get.snackbar("Error", msg);
    }
  }
}
