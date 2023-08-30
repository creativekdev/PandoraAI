import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/ai_server_entity.dart';
import 'package:cartoonizer/models/txt2img_result_entity.dart';
import 'package:cartoonizer/models/txt2img_style_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:cartoonizer/utils/array_util.dart';
import 'package:common_utils/common_utils.dart';

import '../app/user/user_manager.dart';

class Text2ImageApi extends RetryAbleRequester {
  CacheManager cacheManager = AppDelegate().getManager();

  Text2ImageApi() : super(client: DioNode().build());

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    var userManager = AppDelegate.instance.getManager<UserManager>();
    var effectManager = AppDelegate.instance.getManager<EffectManager>();
    Map<String, String> headers = {};
    headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    var apiConfigEntity = await effectManager.loadData();
    var pick = apiConfigEntity?.aiConfig.pick((t) => t.key == 'txt2img');
    return ApiOptions(baseUrl: pick?.serverUrl ?? 'https://ai.pandoraai.app:7003', headers: headers);
  }

  Future<String?> randomPrompt() async {
    var baseEntity = await get('/sdapi/v1/random_prompt');
    return baseEntity?.data['data'];
  }

  Future<Txt2imgResultEntity?> text2image({
    required String prompt,
    required String directoryPath,
    String? initImage,
    int width = 512,
    int height = 512,
    int seed = -1,
    int steps = 20,
    onFailed,
  }) async {
    var params = <String, dynamic>{
      'prompt': prompt,
      'width': width,
      'height': height,
      'seed': seed,
      'steps': steps,
    };
    var api = '/sdapi/v1/txt2img';
    if (!TextUtil.isEmpty(initImage)) {
      params['init_images'] = [initImage];
      api = '/sdapi/v1/img2img';
    }
    var baseEntity = await post(api, params: params, onFailed: onFailed);
    Txt2imgResultEntity? result = jsonConvert.convert<Txt2imgResultEntity>(baseEntity?.data);
    if (result == null) {
      return null;
    }
    if (result.images.isEmpty) {
      return null;
    }
    var dataString = result.images.first;
    String key = EncryptUtil.encodeMd5(dataString);
    String filePath = getFileName(directoryPath, key);
    var base64decode = await base64Decode(dataString);
    await File(filePath).writeAsBytes(base64decode.toList());
    result.filePath = filePath;
    result.s = baseEntity!.s;
    return result;
  }

  Future<List<Txt2imgStyleEntity>?> artists() async {
    var json = cacheManager.getJson(CacheManager.txt2imgStyles);
    if (json != null) {
      var list = jsonConvert.convertListNotNull<Txt2imgStyleEntity>(json);
      if (list == null) {
        return null;
      }
      list.forEach((element) {
        element.url = '${Config.instance.text2imageHost}/${element.category}/${element.slug}.jpg';
      });
      _getFromNet();
      return list;
    }
    return await _getFromNet();
  }

  Future<List<Txt2imgStyleEntity>?> _getFromNet() async {
    var baseEntity = await get('/sdapi/v1/artists');
    if (baseEntity == null) {
      return null;
    }
    cacheManager.setJson(CacheManager.txt2imgStyles, baseEntity.data);
    var list = jsonConvert.convertListNotNull<Txt2imgStyleEntity>(baseEntity.data);
    if (list == null) {
      return null;
    }
    list.forEach((element) {
      element.url = '${Config.instance.text2imageHost}/${element.category}/${element.slug}.jpg';
    });
    return list;
  }

  String getFileName(String directoryPath, String encode) {
    return '${directoryPath}$encode.png';
  }
}
