import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/dialog.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:dio/dio.dart';
import 'package:dio/src/dio_error.dart';
import 'package:flutter/foundation.dart';

///
/// @Author: wangyu
/// @Date: 2022/5/31
///
class ExceptionHandler {
  onError(Exception e, {bool toastOnFailed = true}) {
    if (toastOnFailed) {
      if (e is DioError) {
        if (e.type == DioErrorType.other) {
          if (kReleaseMode) {
            CommonExtension().showToast(StringConstant.commonFailedToast);
          } else {
            CommonExtension().showToast(e.toString());
          }
        } else {
          CommonExtension().showToast(e.toString());
        }
      } else {
        CommonExtension().showToast(e.toString());
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
      var data = e.response!.data;
      if (data == null) {
        CommonExtension().showToast(StringConstant.commonFailedToast);
      } else if (data is Map) {
        CommonExtension().showToast(data['message'] ?? StringConstant.commonFailedToast);
      } else {
        CommonExtension().showToast(data.toString());
      }
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
