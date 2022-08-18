import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/sToken.dart';
import 'package:cartoonizer/config.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dio_node.dart';
import 'exception_handler.dart';
import 'response_handler.dart';

///
/// @Author: wangyu
/// @Date: 2022/5/31
///
/// http base requester
///
/// a subclass of BaseRequester dock a api-server.
/// Example:
/// There are two api-server: https://socialbook.io, https://v2.socialbook.io
/// We need to define:
///   class [LinkOneApi.dart] extends BaseRequester
///   class LinkOneV2Api extends BaseRequester
/// and build diff ApiOptions with baseUrl and headers.
///
///
/// note:
/// requester still has it's own lifecycle.
/// it can be bound with State and GetxController.
/// and need to unbind when State or GetxController destroyed.
///
///   AState extends State<AWidget> {
///     late LinkOneApi api;
///     @override
///     initState() {
///       super.initState();
///       api = LinkOneApi().bindState(this);
///     }
///
///     @override
///     dispose() {
///       super.dispose();
///       api.unbind();
///     }
///   }
///
///   AGetxController extends GetxController {
///     late LinkOneApi api;
///     @override
///     onInit() {
///       super.onInit();
///       api = LinkOneApi().bindController(this);
///     }
///
///     @override
///     onClose() {
///       super.onClose();
///       api.unbind();
///     }
///   }
///
abstract class BaseRequester with ExceptionHandler, ResponseHandler {
  late Dio _client;

  BaseRequester({bool newInstance = false}) {
    if (newInstance) {
      _client = DioNode.instance.build();
    } else {
      _client = DioNode.instance.client;
    }
  }

  ///
  /// build ApiOptions, set baseurl and headers.
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params);

  Future _preHandleRequest(
    Map<String, String> headers,
    Map<String, dynamic> params,
    bool preHandleRequest,
  ) async {
    var options = await apiOptions(params);
    if (options == null) {
      onError(Exception('apiOptions is null'));
      return null;
    }
    _client.options.baseUrl = options.baseUrl;
    if (!preHandleRequest) {
      _client.options.headers.addAll(headers);
      return null;
    }

    /// pre handle params
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // add custom params
    params["app_name"] = APP_NAME;
    params["app_platform"] = Platform.operatingSystem;
    params["app_version"] = packageInfo.version;
    params["app_build"] = packageInfo.buildNumber;
    params['from_app'] = "1";
    // add ts and signature
    params["ts"] = DateTime.now().millisecondsSinceEpoch.toString();
    params["s"] = sToken(params);

    /// pre handle header
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    headers['cookie'] = "sb.connect.sid=${sharedPreferences.getString("login_cookie")}";
    options.headers.addAll(headers);
    _client.options.headers.addAll(options.headers);
  }

  Future<BaseEntity?> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    bool toastOnFailed = true,
    ProgressCallback? onReceiveProgress,
    bool preHandleRequest = true,
    Function(Response response)? onFailed,
  }) async {
    params ??= Map();
    headers ??= Map();
    await _preHandleRequest(headers, params, preHandleRequest);
    try {
      Response response = await _client.get(
        path,
        queryParameters: params,
        onReceiveProgress: onReceiveProgress,
      );
      return _onResponse(response, toastOnFailed: toastOnFailed, onFailed: onFailed);
    } on DioError catch (e) {
      onDioError(e);
      onFailed?.call(e.response!);
      return null;
    }
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
    Function(Response response)? onFailed,
  }) async {
    params ??= Map();
    headers ??= Map();
    await _preHandleRequest(headers, params, preHandleRequest);
    var data;
    if (isFormData) {
      data = FormData.fromMap(params);
    } else {
      data = params;
    }
    try {
      Response response = await _client.post(
        path,
        data: data,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return _onResponse(response, toastOnFailed: toastOnFailed, onFailed: onFailed);
    } on DioError catch (e) {
      onDioError(e);
      onFailed?.call(e.response!);
      return null;
    }
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
    Function(Response response)? onFailed,
  }) async {
    params ??= Map();
    headers ??= Map();
    await _preHandleRequest(headers, params, preHandleRequest);
    try {
      Response response = await _client.put(
        path,
        data: data,
        queryParameters: params,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        options: options,
      );
      return _onResponse(response, toastOnFailed: toastOnFailed, onFailed: onFailed);
    } on DioError catch (e) {
      onDioError(e);
      onFailed?.call(e.response!);
      return null;
    }
  }

  Future<BaseEntity?> delete(
    String path, {
    data,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    bool toastOnFailed = true,
    bool preHandleRequest = true,
    Function(Response response)? onFailed,
  }) async {
    params ??= Map();
    headers ??= Map();
    await _preHandleRequest(headers, params, preHandleRequest);
    try {
      Response response = await _client.delete(path, data: data, queryParameters: params);
      return _onResponse(response, toastOnFailed: toastOnFailed, onFailed: onFailed);
    } on DioError catch (e) {
      onDioError(e);
      onFailed?.call(e.response!);
      return null;
    }
  }

  BaseEntity? _onResponse(
    Response response, {
    bool toastOnFailed = true,
    Function(Response)? onFailed,
  }) {
    if (!interceptResponse(response)) {
      return null;
    }
    var headers = response.headers;
    if (response.statusCode == 200) {
      onPreHandleResult(response);
      var baseEntity = BaseEntity(data: response.data, headers: headers);
      return baseEntity;
    } else if (response.statusCode == 401) {
      onTokenExpired(response.statusCode, response.statusMessage);
      onFailed?.call(response);
      return null;
    } else {
      if (response.data is Map<String, dynamic>) {
        var map = response.data as Map<String, dynamic>?;
        onReqError(map?['message'] ?? response.statusMessage, toastOnFailed: toastOnFailed);
      } else {
        onReqError(response.statusMessage ?? '', toastOnFailed: toastOnFailed);
      }
      onFailed?.call(response);
      return null;
    }
  }
}

class ApiOptions {
  String baseUrl;
  Map<String, String> headers;

  ApiOptions({required this.baseUrl, required this.headers});
}

class BaseEntity {
  dynamic data;
  Headers? headers;

  BaseEntity({this.data, this.headers});
}
