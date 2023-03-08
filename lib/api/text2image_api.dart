import 'dart:convert';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/ai_ground_style_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:common_utils/common_utils.dart';

import '../app/user/user_manager.dart';

class Text2ImageApi extends BaseRequester {
  CacheManager cacheManager = AppDelegate().getManager();

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    var userManager = AppDelegate.instance.getManager<UserManager>();
    Map<String, String> headers = {};
    headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    return ApiOptions(baseUrl: userManager.aiServers['sdserver'] ?? 'https://ai.pandoraai.app:7003', headers: headers);
  }

  Future<String?> randomPrompt() async {
    var baseEntity = await get('/sdapi/v1/random_prompt');
    return baseEntity?.data['data'];
  }

  Future<String?> text2image({
    required String prompt,
    String? initImage,
    int width = 512,
    int height = 512,
    int seed = -1,
    int steps = 20,
  }) async {
    var params = <String, dynamic>{
      'prompt': prompt,
      'width': width,
      'height': height,
      'seed': seed,
      'steps': steps,
    };
    if (!TextUtil.isEmpty(initImage)) {
      params['init_images'] = [initImage];
    }
    var baseEntity = await post('/sdapi/v1/txt2img', params: params);
    List<String>? images = (baseEntity?.data['images'] as List?)?.map((e) => e.toString()).toList();
    return images?.first;
  }

  Future<Map<String, List<AiGroundStyleEntity>>?> artists() async {
    var json = cacheManager.getJson(CacheManager.aiGroundStyles);
    if (json != null) {
      var list = jsonConvert.convertListNotNull<AiGroundStyleEntity>(json);
      if (list == null) {
        return null;
      }
      list.forEach((element) {
        element.url = '${Config.instance.text2imageHost}/${element.category}/${element.slug}.jpg';
      });
      Map<String, List<AiGroundStyleEntity>> result = {};
      for (var entity in list) {
        List<AiGroundStyleEntity> children = result[entity.category] ?? [];
        children.add(entity);
        result[entity.category] = children;
      }
      _getFromNet();
      return result;
    }
    return await _getFromNet();
  }

  Future<Map<String, List<AiGroundStyleEntity>>?> _getFromNet() async {
    var baseEntity = await get('/sdapi/v1/artists');
    if (baseEntity == null) {
      return null;
    }
    cacheManager.setJson(CacheManager.aiGroundStyles, baseEntity.data);
    var list = jsonConvert.convertListNotNull<AiGroundStyleEntity>(baseEntity.data);
    if (list == null) {
      return null;
    }
    list.forEach((element) {
      element.url = '${Config.instance.text2imageHost}/${element.category}/${element.slug}.jpg';
    });
    Map<String, List<AiGroundStyleEntity>> result = {};
    for (var entity in list) {
      List<AiGroundStyleEntity> children = result[entity.category] ?? [];
      children.add(entity);
      result[entity.category] = children;
    }
    return result;
  }
}
