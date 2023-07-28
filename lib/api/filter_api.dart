import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/api/filter_token.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';

class FilterApi extends RetryAbleRequester {
  CacheManager cacheManager = AppDelegate().getManager();
  UserManager userManager = AppDelegate().getManager();

  FilterApi({Dio? client}) : super(client: client);

  // factory FilterApi.quickResponse() {
  //   var client = DioNode.instance.client;
  //   client.options.connectTimeout = 50000;
  //   return FilterApi(client: client);
  // }

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    Map<String, String> headers = {};
    headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    return ApiOptions(baseUrl: Config.instance.aiHost, headers: headers);
  }

  Future<String?> removeBg({required String imageUrl, onFailed}) async {
    var token = await FilterToken().getImageToken(onFailed: onFailed);
    if (token == null) {
      return null;
    }
    return await removeBackground(token: token, imageUrl: imageUrl, onFailed: onFailed);
  }

  Future<String?> removeBackground({
    required String token,
    required String imageUrl,
    onFailed,
  }) async {
    Map<String, dynamic> params = {
      'direct': 1,
      'token': token,
      'algoname': 'humanseg',
      'querypics': [imageUrl],
      'need_save_s3': false,
    };
    var baseEntity = await post('/api/image/analyze/token', params: params, onFailed: onFailed);
    return baseEntity?.data?['data'];
  }

  Future<String?> removeBgAndSave({required String imageUrl, onFailed}) async {
    var rootPath = cacheManager.storageOperator.recordBackgroundRemovalDir.path;
    String? dataString = await removeBg(imageUrl: imageUrl, onFailed: onFailed);
    String key = EncryptUtil.encodeMd5(dataString!);
    String filePath = getFileName(rootPath, key);
    var base64decode = await base64Decode(dataString);
    await File(filePath).writeAsBytes(base64decode.toList());
    return filePath;
  }

  String getFileName(String directoryPath, String encode) {
    return '${directoryPath}$encode.png';
  }
}
