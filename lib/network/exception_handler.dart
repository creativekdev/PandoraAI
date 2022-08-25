import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/dialog.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:dio/src/dio_error.dart';
import 'package:flutter/foundation.dart';

///
/// @Author: wangyu
/// @Date: 2022/5/31
///
class ExceptionHandler {
  onError(Exception e, {bool toastOnFailed = true}) {
    if (toastOnFailed) {
      if (!kReleaseMode) {
        CommonExtension().showToast(e.toString());
      } else {
        CommonExtension().showToast(StringConstant.commonFailedToast);
      }
    }
  }

  onReqError(String msg, {bool toastOnFailed = true}) {
    if (toastOnFailed) {
      CommonExtension().showToast(msg);
    }
  }

  onDioError(DioError e) {
    if (e.response == null) {
      onError(e);
    } else if (e.response?.statusCode == 401) {
      onTokenExpired(e.response?.statusCode, e.response?.statusMessage);
    } else {
      CommonExtension().showToast(e.response!.data['message']);
    }
  }

  onTokenExpired(
    int? statusCode,
    String? statusMessage,
  ) {
    CommonExtension().showToast('Authorization expired, please login again');
    AppDelegate.instance.getManager<UserManager>().logout();
  }
}
