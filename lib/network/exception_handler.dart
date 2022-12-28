import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
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
            if (AppContext.context != null) {
              CommonExtension().showToast(S.of(AppContext.context!).commonFailedToast);
            } else {
              CommonExtension().showToast("Oops failed!");
            }
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
        if (AppContext.context != null) {
          CommonExtension().showToast(S.of(AppContext.context!).commonFailedToast);
        } else {
          CommonExtension().showToast("Oops failed!");
        }
      } else if (data is Map) {
        var ctoast;
        if (AppContext.context != null) {
          ctoast = S.of(AppContext.context!).commonFailedToast;
        } else {
          ctoast = "Oops failed!";
        }
        CommonExtension().showToast(data['message'] ?? ctoast);
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
