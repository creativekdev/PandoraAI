import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/utils/string_ex.dart';
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
            CommonExtension().showToast("Oops failed!".intl);
          } else {
            CommonExtension().showToast(e.toString().intl);
          }
        } else {
          CommonExtension().showToast(e.toString().intl);
        }
      } else {
        CommonExtension().showToast(e.toString().intl);
      }
    }
  }

  onReqError(String msg, {bool toastOnFailed = true}) {
    if (toastOnFailed) {
      CommonExtension().showToast(msg.intl);
    }
  }

  onDioError(DioError e, {bool toastOnFailed = true}) {
    var statusCode = e.response?.statusCode ?? -1;
    if (e.response == null) {
      // onError(e);
    } else if (statusCode == 401) {
      onTokenExpired(statusCode, e.response?.statusMessage);
    } else if (statusCode >= 402 && statusCode < 600) {
      if (e.response != null) {
        CartoonizerApi().logError(
            reqMethod: e.requestOptions.method,
            api: '${e.requestOptions.baseUrl}${e.requestOptions.path}${e.requestOptions.generateParams()}',
            errorMessage: e.response!.data.toString(),
            headers: e.requestOptions.generateHeaders(),
            statusCode: e.response!.statusCode ?? 0);
      }
    } else {
      if (toastOnFailed) {
        var data = e.response!.data;
        if (data == null) {
          CommonExtension().showToast("Oops failed!".intl);
        } else if (data is Map) {
          CommonExtension().showToast((data['message'] ?? "Oops failed!").toString().intl);
        } else {
          CommonExtension().showToast(data.toString().intl);
        }
      }
    }
  }

  onTokenExpired(
    int? statusCode,
    String? statusMessage, {
    bool toastOnFailed = true,
  }) {
    var userManager = AppDelegate.instance.getManager<UserManager>();
    if (toastOnFailed) {
      if (!userManager.isNeedLogin) {
        CommonExtension().showToast('Authorization expired, please login again');
      }
    }
    userManager.logout();
  }
}
