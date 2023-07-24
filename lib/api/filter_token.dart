import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';

class FilterToken extends RetryAbleRequester {
  CacheManager cacheManager = AppDelegate().getManager();
  UserManager userManager = AppDelegate().getManager();

  FilterToken({Dio? client}) : super(client: client);

  factory FilterToken.quickResponse() {
    var client = DioNode.instance.client;
    client.options.connectTimeout = 10000;
    return FilterToken(client: client);
  }

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    Map<String, String> headers = {};
    headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    return ApiOptions(baseUrl: Config.instance.host, headers: headers);
  }

  Future<String?> getImageToken({onFailed}) async {
    var baseEntity = await get('/api/tool/image/token', onFailed: onFailed, needRetry: false);
    if (baseEntity != null) {
      return baseEntity.data['data'];
    }
    return null;
  }
}
