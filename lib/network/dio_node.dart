import 'dart:convert';

import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const _receiveTimeout = 60000;
const _connectTimeout = 30000;
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
  static Map<String, int> _timeRecord = {};

  late Dio client;

  DioNode._internal() {
    client = build();
  }

  Dio build({
    bool logResponseEnable = true,
    int? receiveTimeout,
    int? connectTimeout,
  }) {
    BaseOptions options = new BaseOptions();
    options.receiveTimeout = receiveTimeout ?? _receiveTimeout;
    options.connectTimeout = connectTimeout ?? _connectTimeout;
    options.responseType = _responseType;
    Dio client = Dio(options);
    // debug代码，xia哥的服务器需要关闭ssl证书认证
    // (client.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
    //   client.badCertificateCallback=(cert, host, port){
    //     return true;
    //   };
    // };
    client.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options, handler) {
      if (kReleaseMode) {
        return handler.next(options);
      }
      var tag = _generateRequestTag(options);
      _timeRecord[tag] = DateTime.now().millisecondsSinceEpoch;
      String url = options.baseUrl + options.path;
      LogUtil.v('request: $url  headers: ${options.generateHeaders()}', tag: tag);
      var getParams = options._generateGetParams();
      if (getParams != null) {
        LogUtil.v('request: $url  queryParams: $getParams', tag: tag);
      }
      var postParams = options._generatePostParams();
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
      if (kReleaseMode || !logResponseEnable) {
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
      int spend = -1;
      if (_timeRecord[tag] != null) {
        spend = DateTime.now().millisecondsSinceEpoch - _timeRecord.remove(tag)!;
      }
      LogUtil.v('response: $url  spend: $spend,  response: $result', tag: tag);
      return handler.next(response);
    }, onError: (e, handler) {
      if (kReleaseMode || !logResponseEnable) {
        return handler.next(e);
      }
      String url = e.requestOptions.baseUrl + e.requestOptions.path;
      var tag = _generateRequestTag(e.requestOptions);
      int spend = -1;
      if (_timeRecord[tag] != null) {
        spend = DateTime.now().millisecondsSinceEpoch - _timeRecord.remove(tag)!;
      }
      LogUtil.v('response: $url  spend: $spend,  error: ${e.toString()}', tag: tag);
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
    var getParams = options._generateGetParams();
    if (getParams != null) {
      requestTag = _TAG + "_" + EncryptUtil.encodeMd5(url + getParams).substring(0, 8);
    } else {
      var postParams = options._generatePostParams();
      if (postParams != null) {
        requestTag = _TAG + "_" + EncryptUtil.encodeMd5(url + postParams).substring(0, 8);
      } else {
        requestTag = _TAG + "_" + EncryptUtil.encodeMd5(url).substring(0, 8);
      }
    }
    return requestTag;
  }
}

extension RequestOptionsEx on RequestOptions {
  String generateHeaders() {
    String result = "{";
    headers.forEach((key, value) {
      result += '$key:$value,';
    });
    result += "}";
    return result;
  }

  String? generateParams() {
    var getParams = _generateGetParams();
    if (getParams != null) {
      return getParams;
    }
    return _generatePostParams();
  }

  String? _generateGetParams() {
    String? result;
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

  String? _generatePostParams() {
    String? result;
    var reqData = data;
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
