import 'dart:convert';

import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const _receiveTimeout = 10000;
const _connectTimeout = 15000;
const _responseType = ResponseType.json;
const String _TAG = "WEB";
const int logMaxLength = 10240;

///
/// @Author: wangyu
/// @Date: 2022/5/31
///
class DioNode {
  factory DioNode() => _getInstance();

  static DioNode get instance => _getInstance();
  static DioNode? _instance;

  late Dio client;

  DioNode._internal() {
    client = build();
  }

  Dio build() {
    BaseOptions options = new BaseOptions();
    options.receiveTimeout = _receiveTimeout;
    options.connectTimeout = _connectTimeout;
    options.responseType = _responseType;
    Dio client = Dio(options);
    client.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options, handler) {
      if (kReleaseMode) {
        return handler.next(options);
      }
      var tag = _generateRequestTag(options);
      String url = options.baseUrl + options.path;
      LogUtil.v('request: $url  headers: ${_generateHeaders(options)}', tag: tag);
      var getParams = _generateGetParams(options);
      if (getParams != null) {
        LogUtil.v('request: $url  queryParams: $getParams', tag: tag);
      }
      var postParams = _generatePostParams(options);
      if (postParams != null) {
        if (postParams.length > logMaxLength) {
          LogUtil.v('request: $url  data: ${postParams.substring(0, logMaxLength)}', tag: tag);
        } else {
          LogUtil.v('request: $url  data: $postParams', tag: tag);
        }
      } else {
        LogUtil.v('request: $url', tag: tag);
      }
      return handler.next(options);
    }, onResponse: (Response response, handler) {
      if (kReleaseMode) {
        return handler.next(response);
      }
      String url = response.requestOptions.baseUrl + response.requestOptions.path;
      String result;
      try {
        result = json.encode(response.data).toString();
      } catch (e) {
        result = response.data?.toString() ?? 'unsupported response data';
      }
      var tag = _generateRequestTag(response.requestOptions);
      LogUtil.v('response: $url  response: $result', tag: tag);
      return handler.next(response);
    }, onError: (e, handler) {
      if (kReleaseMode) {
        return handler.next(e);
      }
      String url = e.requestOptions.baseUrl + e.requestOptions.path;
      var tag = _generateRequestTag(e.requestOptions);
      LogUtil.v('response: $url  error: ${e.toString()}', tag: tag);
      return handler.next(e);
    }));
    return client;
  }

  static DioNode _getInstance() {
    if (_instance == null) {
      _instance = new DioNode._internal();
    }
    return _instance!;
  }

  String _generateRequestTag(RequestOptions options) {
    String requestTag;
    String url = options.baseUrl + options.path;
    var getParams = _generateGetParams(options);
    if (getParams != null) {
      requestTag = _TAG + "_" + EncryptUtil.encodeMd5(url + getParams).substring(0, 8);
    } else {
      var postParams = _generatePostParams(options);
      if (postParams != null) {
        requestTag = _TAG + "_" + EncryptUtil.encodeMd5(url + postParams).substring(0, 8);
      } else {
        requestTag = _TAG + "_" + EncryptUtil.encodeMd5(url).substring(0, 8);
      }
    }
    return requestTag;
  }

  String _generateHeaders(RequestOptions options) {
    String result = "{";
    options.headers.forEach((key, value) {
      result += '$key:$value,';
    });
    result += "}";
    return result;
  }

  String? _generateGetParams(RequestOptions options) {
    String? result;
    var queryParameters = options.queryParameters;
    if (queryParameters.keys.isNotEmpty) {
      var queryParamsString = "?";
      queryParameters.keys.forEach((v) {
        queryParamsString += "$v=${queryParameters[v]}";
        queryParamsString += "&";
      });
      result = queryParamsString;
    }
    return result;
  }

  String? _generatePostParams(RequestOptions options) {
    String? result;
    var reqData = options.data;
    if (reqData != null) {
      var data;
      if (reqData is FormData) {
        Map logData = {};
        reqData.fields.forEach((element) {
          logData[element.key] = element.value;
        });
        reqData.files.forEach((element) {
          logData[element.key] = "<file-${element.value.filename}>";
        });
        data = json.encode(logData);
      } else if (reqData is Map) {
        data = json.encode(reqData);
      } else if (reqData is List<Map>) {
        data = json.encode(reqData);
      } else {
        data = reqData.toString();
      }
      result = data;
    }
    return result;
  }
}
