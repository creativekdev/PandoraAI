import 'dart:io';
import 'dart:typed_data';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/another_me_result_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';

class Uploader extends BaseRequester {
  /// upload don't need log response data
  Uploader() : super(newInstance: true, logResponseEnable: false);

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    return ApiOptions(baseUrl: '', headers: {});
  }

  /// upload file to aws s3
  Future<BaseEntity?> upload(String url, Uint8List image, String contentType) async {
    var stream = MultipartFile.fromBytes(image).finalize();
    return await put(url, stream,
        options: Options(
          headers: {'Content-Length': image.length},
        ),
        preHandleRequest: false,
        headers: {
          'Content-Type': contentType,
        });
  }

  /// upload file to aws s3
  Future<BaseEntity?> uploadFile(String url, File file, String contentType) async {
    return await put(url, file.openRead(),
        options: Options(
          headers: {'Content-Length': file.lengthSync()},
        ),
        preHandleRequest: false,
        headers: {
          'Content-Type': contentType,
        });
  }

  Future<AnotherMeResultEntity?> generateAnotherMe(String url, int faceRatio, String? cachedId) async {
    UserManager userManager = AppDelegate().getManager();
    var params = {
      'init_images': [url],
      'face_ratio': faceRatio,
    };
    if (!TextUtil.isEmpty(cachedId)) {
      params['cache_id'] = cachedId!;
    }
    var baseEntity = await post('${userManager.aiServers['sdppm']}/sdapi/v1/anotherme', params: params);
    var entity = jsonConvert.convert<AnotherMeResultEntity>(baseEntity?.data);
    if (entity != null && baseEntity != null) {
      entity.s = baseEntity.s;
    }
    return entity;
  }
}
