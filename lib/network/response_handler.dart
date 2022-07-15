import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

import 'base_requester.dart';

///
/// @Author: wangyu
/// @Date: 2022/5/31
///
class ResponseHandler {
  State? state;
  GetxController? controller;
  BaseManager? manager;

  Child bindState<Child extends BaseRequester>(State state) {
    this.state = state;
    return this as Child;
  }

  Child bindController<Child extends BaseRequester>(GetxController controller) {
    this.controller = controller;
    return this as Child;
  }

  Child bindManager<Child extends BaseRequester>(BaseManager manager) {
    this.manager = manager;
    return this as Child;
  }

  Child unbind<Child extends BaseRequester>() {
    this.state = null;
    this.controller = null;
    this.manager = null;
    return this as Child;
  }

  ///intercept http response
  ///go forward while holder is active.
  ///such as State is mounted or GetxController is not close
  bool interceptResponse(dio.Response response) {
    if (state != null) {
      if (!state!.mounted) {
        // current state is unmounted, stop forward.
        return false;
      }
    }
    if (controller != null) {
      if (controller!.isClosed) {
        // current controller is closed, go on.
        return false;
      }
    }
    if (manager != null) {
      if (!manager!.mounted) {
        // current manager is unmounted, stop forward.
        return false;
      }
    }
    return true;
  }

  /// pre handle response. like cookie, token, etc...
  onPreHandleResult(dio.Response response) {
    LogUtil.v('response-headers: ${response.headers.toString()}');
    var headers = response.headers.map;
    if (headers.containsKey("set-cookie")) {
      var cookie = headers['set-cookie'] ?? [];
      if (cookie.isNotEmpty) {
        for (var element in cookie) {
          var keyValues = element.split(';');
          for (var value in keyValues) {
            if (value.startsWith('sb.connect.sid')) {
              AppDelegate.instance.getManager<UserManager>().sid = value.split('=')[1];
              break;
            }
          }
        }
      }
    }
  }
}
