import 'dart:convert';
import 'dart:io';

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
    required String directoryPath,
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
    var api = '/sdapi/v1/txt2img';
    if (!TextUtil.isEmpty(initImage)) {
      params['init_images'] = [initImage];
      api = '/sdapi/v1/img2img';
    }
    var baseEntity = await post(api, params: params);
    List<String>? images = (baseEntity?.data['images'] as List?)?.map((e) => e.toString()).toList();
    if(images != null && images.isNotEmpty) {
      var dataString = images.first;
      String key = EncryptUtil.encodeMd5(dataString);
      String filePath = getFileName(directoryPath, key);
      var base64decode = await base64Decode(dataString);
      await File(filePath).writeAsBytes(base64decode.toList());
      return filePath;
    }
    return null;
  }

  Future<List<AiGroundStyleEntity>?> artists() async {
    var json = cacheManager.getJson(CacheManager.aiGroundStyles);
    if (json != null) {
      var list = jsonConvert.convertListNotNull<AiGroundStyleEntity>(json);
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

  Future<List<AiGroundStyleEntity>?> _getFromNet() async {
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
    return list;
  }


  String getFileName(String directoryPath, String encode) {
    return '${directoryPath}$encode.png';
  }
}
