import 'dart:io';
import 'dart:typed_data';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/ai_server_entity.dart';
import 'package:cartoonizer/models/another_me_result_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:cartoonizer/utils/array_util.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';

class Uploader extends RetryAbleRequester {
  /// upload don't need log response data
  Uploader() : super(client: DioNode.instance.build(logResponseEnable: false));

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    return ApiOptions(baseUrl: '', headers: {});
  }

  /// upload file bytes to aws s3
  Future<BaseEntity?> upload(
    String url,
    Uint8List bytes,
    String contentType, {
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
  }) async {
    var stream = MultipartFile.fromBytes(bytes).finalize();
    return await put(
      url,
      stream,
      options: Options(
        headers: {'Content-Length': bytes.length},
      ),
      preHandleRequest: false,
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
      headers: {'Content-Type': contentType},
    );
  }

  /// upload file to aws s3
  Future<BaseEntity?> uploadFile(
    String url,
    File file,
    String contentType, {
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
  }) async {
    return await put(
      url,
      file.openRead(),
      options: Options(
        headers: {'Content-Length': file.lengthSync()},
      ),
      preHandleRequest: false,
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
      headers: {'Content-Type': contentType},
    );
  }

  Future<AnotherMeResultEntity?> generateAnotherMe(String url, String? cachedId, onFailed) async {
    var params = <String, dynamic>{
      'init_images': [url],
    };
    if (!TextUtil.isEmpty(cachedId)) {
      params['cache_id'] = cachedId!;
    }
    EffectManager effectManager = AppDelegate().getManager();
    var apiConfigEntity = effectManager.data!;
    var pick = apiConfigEntity.aiConfig.pick(
      (t) => t.key == 'anotherme',
    );
    var baseEntity = await post('${pick!.serverUrl}/sdapi/v1/anotherme', params: params, onFailed: onFailed);
    var entity = jsonConvert.convert<AnotherMeResultEntity>(baseEntity?.data);
    if (entity != null && baseEntity != null) {
      entity.s = baseEntity.s;
    }
    return entity;
  }
}
