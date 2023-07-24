import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/ai_server_entity.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/cartoonizer_result_entity.dart';
import 'package:cartoonizer/models/style_morph_result_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:cartoonizer/utils/array_util.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:common_utils/common_utils.dart';

import 'transform_api.dart';

class CartoonizerApi extends RetryAbleRequester {
  late TransformApi transformApi;
  CacheManager cacheManager = AppDelegate().getManager();

  CartoonizerApi() : super(client: DioNode().build()) {
    transformApi = TransformApi();
  }

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    UserManager userManager = AppDelegate().getManager();
    Map<String, String> headers = {};
    headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    return ApiOptions(baseUrl: Config.instance.apiHost, headers: headers);
  }

  Future<CartoonizerResultEntity?> startTransfer({
    required String initImage,
    required String directoryPath,
    required EffectItem selectEffect,
    onFailed,
  }) async {
    var tokenResponse = await get('/tool/image/cartoonize/token', needRetry: false, toastOnFailed: false, onFailed: onFailed);
    if (tokenResponse == null) {
      return null;
    }
    var token = tokenResponse.data['data'];
    var dataBody = <String, dynamic>{
      'querypics': [initImage],
      'is_data': 0,
      // 'algoname': includeOriginalFace() ? selectedEffect.algoname + "-original_face" : selectedEffect.algoname,
      'algoname': selectEffect.algoName,
      'direct': 1,
      'hide_watermark': 1,
    };
    if (token != null) {
      dataBody['token'] = token;
    }
    selectEffect.handleApiParams(dataBody);
    var aiHost = _getAiHostByStyle(selectEffect);
    var baseEntity = await transformApi.transform(
      aiHost.cartoonizeApi,
      directoryPath,
      dataBody,
      aiHost: aiHost,
    );
    if (baseEntity == null) {
      return null;
    }

    AppApi().logCartoonizer({
      ...dataBody,
      'result_id': baseEntity.s,
    });
    return baseEntity;
  }

  String getFileName(String directoryPath, String encode) {
    return '${directoryPath}$encode.png';
  }

  String _getAiHostByStyle(EffectItem effect) {
    var server = effect.server;
    if (server.contains('cartoonize')) {
      server = 'cartoonize';
    }
    EffectManager effectManager = AppDelegate().getManager();
    return effectManager.data!.aiConfig.pick((t) => t.key == server)?.serverUrl ?? Config.instance.host;
  }
}
