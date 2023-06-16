import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/ai_draw_result_entity.dart';
import 'package:cartoonizer/models/ai_server_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:cartoonizer/utils/array_util.dart';
import 'package:common_utils/common_utils.dart';

class AiDrawApi extends RetryAbleRequester {
  CacheManager cacheManager = AppDelegate().getManager();

  AiDrawApi() : super(client: DioNode().build());

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    var userManager = AppDelegate.instance.getManager<UserManager>();
    var effectManager = AppDelegate.instance.getManager<EffectManager>();
    Map<String, String> headers = {};
    headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    var apiConfigEntity = await effectManager.loadData();
    var pick = apiConfigEntity?.aiConfig.pick((t) => t.key == 'scribble');
    return ApiOptions(baseUrl: pick?.serverUrl ?? 'https://ai.pandoraai.app:50004', headers: headers);
  }

  Future<AiDrawResultEntity?> draw({
    required String directoryPath,
    required String initImage,
    String? text,
    int width = 512,
    int height = 512,
    int seed = -1,
    int steps = 20,
    onFailed,
  }) async {
    var params = <String, dynamic>{
      'prompt': text,
      'width': width,
      'height': height,
      'seed': seed,
      'steps': steps,
      'batch_size': 4,
      'init_images': [initImage],
    };
    var baseEntity = await post('/sdapi/v1/scribble', params: params, onFailed: onFailed);
    AiDrawResultEntity? result = jsonConvert.convert<AiDrawResultEntity>(baseEntity?.data);
    if (result == null) {
      return null;
    }
    if (result.images.isEmpty) {
      return null;
    }
    for (int i = 0; i < result.images.length; i++) {
      if (i < 4) {
        String value = result.images[i];
        String key = EncryptUtil.encodeMd5(value);
        String filePath = getFileName(directoryPath, key);
        var base64decode = await base64Decode(value);
        await File(filePath).writeAsBytes(base64decode.toList());
        result.filePath.add(filePath);
      }
    }
    result.s = baseEntity!.s;
    CartoonizerApi().logScribble({
      'prompt': text,
      'width': width,
      'height': height,
      'seed': seed,
      'steps': steps,
      'batch_size': 4,
      'init_images': [initImage],
      'result_id': baseEntity.s,
    });
    return result;
  }

  String getFileName(String directoryPath, String encode) {
    return '${directoryPath}$encode.png';
  }
}
