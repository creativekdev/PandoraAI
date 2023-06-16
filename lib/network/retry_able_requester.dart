import 'dart:async';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/widget_extensions.dart';
import 'package:cartoonizer/common/ThemeConstant.dart';
import 'package:cartoonizer/generated/l10n.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/utils/screen_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

typedef _ReqAction = Future<BaseEntity?> Function();

abstract class RetryAbleRequester extends BaseRequester {
  RetryAbleRequester({required super.client});

  Future<BaseEntity?> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    bool toastOnFailed = true,
    ProgressCallback? onReceiveProgress,
    bool preHandleRequest = true,
    bool needRetry = true,
    bool canClickRetry = false,
    Function(Response? response)? onFailed,
  }) async {
    Completer<BaseEntity?> completer = Completer();
    _ReqAction? action;
    action = () async {
      return await doGet(
        path,
        headers: headers,
        params: params,
        toastOnFailed: toastOnFailed,
        onReceiveProgress: onReceiveProgress,
        preHandleRequest: preHandleRequest,
        needRetry: needRetry,
        onFailed: (response) {
          if (needRetry) {
            _onFailedCall(response, canClickRetry).then((value) {
              if (value ?? false) {
                _executeReq(action, completer);
              } else {
                onFailed?.call(response);
                completer.complete(null);
              }
            });
          } else {
            onFailed?.call(response);
            completer.complete(null);
          }
        },
      );
    };
    _executeReq(action, completer);
    return completer.future;
  }

  Future<BaseEntity?> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    bool isFormData = false,
    bool toastOnFailed = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool preHandleRequest = true,
    bool needRetry = true,
    bool canClickRetry = false,
    Function(Response? response)? onFailed,
  }) async {
    Completer<BaseEntity?> completer = Completer();
    _ReqAction? action;
    action = () async {
      return await doPost(
        path,
        headers: headers,
        params: params,
        isFormData: isFormData,
        toastOnFailed: toastOnFailed,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        preHandleRequest: preHandleRequest,
        needRetry: needRetry,
        onFailed: (response) {
          if (needRetry) {
            _onFailedCall(response, canClickRetry).then((value) {
              if (value ?? false) {
                _executeReq(action, completer);
              } else {
                onFailed?.call(response);
                completer.complete(null);
              }
            });
          } else {
            onFailed?.call(response);
            completer.complete(null);
          }
        },
      );
    };
    _executeReq(action, completer);
    return completer.future;
  }

  Future<BaseEntity?> put(
    String path,
    data, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    bool toastOnFailed = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool preHandleRequest = true,
    Options? options,
    bool needRetry = true,
    bool canClickRetry = false,
    Function(Response? response)? onFailed,
  }) async {
    Completer<BaseEntity?> completer = Completer();
    _ReqAction? action;
    action = () async {
      return await doPut(
        path,
        data,
        headers: headers,
        params: params,
        toastOnFailed: toastOnFailed,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        preHandleRequest: preHandleRequest,
        options: options,
        needRetry: needRetry,
        onFailed: (response) {
          if (needRetry) {
            _onFailedCall(response, canClickRetry).then((value) {
              if (value ?? false) {
                _executeReq(action, completer);
              } else {
                onFailed?.call(response);
                completer.complete(null);
              }
            });
          } else {
            onFailed?.call(response);
            completer.complete(null);
          }
        },
      );
    };
    _executeReq(action, completer);
    return completer.future;
  }

  Future<BaseEntity?> delete(
    String path, {
    data,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    bool toastOnFailed = true,
    bool preHandleRequest = true,
    bool needRetry = true,
    bool canClickRetry = false,
    Function(Response? response)? onFailed,
  }) async {
    Completer<BaseEntity?> completer = Completer();
    _ReqAction? action;
    action = () async {
      return await doDelete(
        path,
        data: data,
        headers: headers,
        params: params,
        toastOnFailed: toastOnFailed,
        preHandleRequest: preHandleRequest,
        needRetry: needRetry,
        onFailed: (response) {
          if (needRetry) {
            _onFailedCall(response, canClickRetry).then((value) {
              if (value ?? false) {
                _executeReq(action, completer);
              } else {
                onFailed?.call(response);
                completer.complete(null);
              }
            });
          } else {
            onFailed?.call(response);
            completer.complete(null);
          }
        },
      );
    };
    _executeReq(action, completer);
    return completer.future;
  }

  _executeReq(_ReqAction? action, Completer<BaseEntity?> completer) {
    action?.call().then((value) {
      if (value != null) {
        completer.complete(value);
      }
    });
  }

  Future<bool?> _onFailedCall(
    Response? response,
    bool canClickRetry,
  ) async {
    Completer<bool?> completer = Completer();
    var statusCode = response?.statusCode ?? -1;
    if (response == null) {
      StreamSubscription? resultListen;
      resultListen = EventBusHelper().eventBus.on<OnRetryDialogResultEvent>().listen((event) {
        if (!completer.isCompleted) {
          completer.complete(event.data);
        }
        resultListen?.cancel();
      });
      _RetryDialogHolder.show(canClickRetry, true);
      return completer.future;
    } else if (statusCode >= 500 && statusCode < 600) {
      StreamSubscription? resultListen;
      resultListen = EventBusHelper().eventBus.on<OnRetryDialogResultEvent>().listen((event) {
        if (!completer.isCompleted) {
          completer.complete(event.data);
        }
        resultListen?.cancel();
      });
      _RetryDialogHolder.show(canClickRetry, false);
      return completer.future;
    } else {
      return false;
    }
  }
}

class _RetryDialogHolder {
  static bool _shown = false;

  static show(bool canClickRetry, bool isNetError) {
    if (_shown) {
      return;
    }
    _shown = true;
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (c) => _RetryDialog(
        canClickRetry: canClickRetry,
        isNetError: isNetError,
      ),
    ).then((value) {
      EventBusHelper().eventBus.fire(OnRetryDialogResultEvent(data: value ?? false));
      _shown = false;
    });
  }
}

class _RetryDialog extends StatelessWidget {
  bool canClickRetry;
  bool isNetError;

  _RetryDialog({
    Key? key,
    required this.canClickRetry,
    required this.isNetError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: $(40)),
        Image.asset(
          isNetError ? Images.ic_net_error_icon : Images.ic_server_error_icon,
          width: $(100),
        ),
        SizedBox(height: $(23)),
        Text(
          isNetError ? S.of(context).server_exception : S.of(context).server_exception,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: $(17)),
        ),
        SizedBox(height: $(8)),
        Text(
          isNetError ? S.of(context).server_exception_desc : S.of(context).server_exception_desc,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: $(13)),
          textAlign: TextAlign.center,
        ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(32))),
        SizedBox(height: $(39)),
        Divider(height: 1, color: ColorConstant.LineColor),
        Row(
          children: [
            Expanded(
              child: Text(
                S.of(Get.context!).cancel,
                style: TextStyle(color: ColorConstant.DiscoveryBtn, fontWeight: FontWeight.w500, fontSize: $(16)),
              )
                  .intoContainer(
                      padding: EdgeInsets.symmetric(
                        vertical: $(12),
                        horizontal: $(10),
                      ),
                      alignment: Alignment.center)
                  .intoGestureDetector(onTap: () {
                Navigator.of(context).pop(false);
              }),
            ),
            canClickRetry
                ? Expanded(
                    child: Text(
                      S.of(Get.context!).retry,
                      style: TextStyle(color: ColorConstant.DiscoveryBtn, fontWeight: FontWeight.w500, fontSize: $(16)),
                    )
                        .intoContainer(
                            padding: EdgeInsets.symmetric(
                              vertical: $(12),
                              horizontal: $(10),
                            ),
                            alignment: Alignment.center)
                        .intoGestureDetector(onTap: () {
                      Navigator.of(context).pop(true);
                    }),
                  )
                : SizedBox.shrink(),
          ],
        )
      ],
    ).customDialogStyle();
  }
}
