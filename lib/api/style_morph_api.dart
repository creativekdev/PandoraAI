import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/style_morph_result_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:common_utils/common_utils.dart';

class StyleMorphApi extends RetryAbleRequester {
  StyleMorphApi():super(client: DioNode().build());
  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    var userManager = AppDelegate.instance.getManager<UserManager>();
    Map<String, String> headers = {};
    headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    return ApiOptions(baseUrl: userManager.aiServers['stylemorph'] ?? 'https://ai.pandoraai.app:7002', headers: headers);
  }

  Future<StyleMorphResultEntity?> startTransfer({
    required String initImage,
    required String templateName,
    required String directoryPath,
  }) async {
    Map<String, dynamic> params = {
      'init_images': [initImage],
      'template_name': templateName,
    };

    var baseEntity = await post('/sdapi/v1/stylemorph', params: params);
    StyleMorphResultEntity? result = jsonConvert.convert<StyleMorphResultEntity>(baseEntity?.data);
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

  String getFileName(String directoryPath, String encode) {
    return '${directoryPath}$encode.png';
  }
}
