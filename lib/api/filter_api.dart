import 'dart:convert';
import 'dart:io';
import 'dart:ui';

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

  Future<String?> removeBg({required String imageUrl, required int originWidth, required int originHeight, onFailed}) async {
    var token = await FilterToken().getImageToken(onFailed: onFailed);
    if (token == null) {
      return null;
    }
    return await removeBackground(
      token: token,
      imageUrl: imageUrl,
      onFailed: onFailed,
      originHeight: originHeight,
      originWidth: originWidth,
    );
  }

  Future<String?> removeBackground({
    required String token,
    required String imageUrl,
    required int originWidth,
    required int originHeight,
    onFailed,
  }) async {
    Map<String, dynamic> params = {
      'direct': 1,
      'token': token,
      'algoname': 'humanseg',
      'querypics': [imageUrl],
      'need_save_s3': false,
      'is_mask_only': true,
      'resize_w': originWidth,
      'resize_h': originHeight,
    };
    var baseEntity = await post('/api/image/analyze/token', params: params, onFailed: onFailed);
    return baseEntity?.data?['data'];
  }

  Future<String?> removeBgAndSave({required String imageUrl, required String originalPath, onFailed}) async {
    var rootPath = cacheManager.storageOperator.recordBackgroundRemovalDir.path;
    String key = EncryptUtil.encodeMd5(imageUrl);
    String filePath = getMaskFileName(rootPath, key);
    var image = await getImage(File(originalPath));
    if (File(filePath).existsSync()) {
      return await removeInLocal(filePath, originalPath, image: image);
    }
    String? dataString = await removeBg(imageUrl: imageUrl, originWidth: image.width, originHeight: image.height, onFailed: onFailed);
    if (dataString == null) {
      return null;
    }
    var base64decode = await base64Decode(dataString);
    await File(filePath).writeAsBytes(base64decode.toList());
    return await removeInLocal(filePath, originalPath, image: image);
  }

  String getFileName(String directoryPath, String encode) {
    return '${directoryPath}$encode.png';
  }

  String getMaskFileName(String directoryPath, String encode) {
    return '${directoryPath}$encode.jpg';
  }

  Future<String?> removeInLocal(
    String maskPath,
    String originalPath, {
    required Image image,
  }) async {
    var rootPath = cacheManager.storageOperator.recordBackgroundRemovalDir.path;
    String key = EncryptUtil.encodeMd5(maskPath + originalPath);
    String filePath = getFileName(rootPath, key);
    // if (File(filePath).existsSync()) {
    //   return filePath;
    // }
    var originalImage = await getLibImage(image);
    var maskImage = await getLibImage(await getImage(File(maskPath)));
    // var newMask = imgLib.copyResize(maskImage, width: originalImage.width, height: originalImage.height);
    for (int x = 0; x < originalImage.width; x++) {
      for (int y = 0; y < originalImage.height; y++) {
        var pixel = maskImage.getPixel(x, y);
        var orPixel = originalImage.getPixel(x, y);
        int a = imgLib.getAlpha(pixel);
        int r = imgLib.getRed(orPixel);
        int g = imgLib.getGreen(orPixel);
        int b = imgLib.getBlue(orPixel);
        int newPixel = imgLib.Color.fromRgba(r, g, b, a);
        originalImage.setPixel(x, y, newPixel);
        // var newP = originalImage.getPixel(x, y);
        // print('newP:$newP, oldP:$orPixel');
      }
    }
    await File(filePath).writeAsBytes(imgLib.encodePng(originalImage));
    return filePath;
  }
}
