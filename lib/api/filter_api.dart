import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/api/filter_token.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/mine/filter/ImageProcessor.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as imgLib;

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
      'is_mask_only': true,
    };
    var baseEntity = await post('/api/image/analyze/token', params: params, onFailed: onFailed);
    return baseEntity?.data?['data'];
  }

  Future<String?> removeBgAndSave({required String imageUrl, required String originalPath, onFailed}) async {
    var rootPath = cacheManager.storageOperator.recordBackgroundRemovalDir.path;
    String key = EncryptUtil.encodeMd5(imageUrl);
    String filePath = getFileName(rootPath, key);
    if (File(filePath).existsSync()) {
      return await removeInLocal(filePath, originalPath);
    }
    String? dataString = await removeBg(imageUrl: imageUrl, onFailed: onFailed);
    if (dataString == null) {
      return null;
    }
    var base64decode = await base64Decode(dataString);
    await File(filePath).writeAsBytes(base64decode.toList());
    return await removeInLocal(filePath, originalPath);
  }

  String getFileName(String directoryPath, String encode) {
    return '${directoryPath}$encode.png';
  }

  Future<String?> removeInLocal(
    String maskPath,
    String originalPath,
  ) async {
    var rootPath = cacheManager.storageOperator.recordBackgroundRemovalDir.path;
    String key = EncryptUtil.encodeMd5(maskPath + originalPath);
    String filePath = getFileName(rootPath, key);
    // if (File(filePath).existsSync()) {
    //   return filePath;
    // }
    var originalImage = await getLibImage(await getImage(File(originalPath)));
    var maskImage = await getLibImage(await getImage(File(maskPath)));
    var newMask = imgLib.copyResize(maskImage, width: originalImage.width, height: originalImage.height);
    for (int x = 0; x < originalImage.width; x++) {
      for (int y = 0; y < originalImage.height; y++) {
        var pixel = newMask.getPixel(x, y);
        int a = ImageProcessor.getA(pixel);
        int r = ImageProcessor.getR(pixel);
        int g = ImageProcessor.getG(pixel);
        int b = ImageProcessor.getB(pixel);
        if (a == 255 && r == 0 && g == 0 && b == 0) {
          int newPixel = ImageProcessor.setRGBA(0, 0, 0, 0);
          originalImage.setPixel(x, y, newPixel);
        }
      }
    }
    await File(filePath).writeAsBytes(imgLib.encodePng(originalImage));
    return filePath;
  }
}
