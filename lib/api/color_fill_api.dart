import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/ai_server_entity.dart';
import 'package:cartoonizer/models/color_fill_result_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:common_utils/common_utils.dart';

class ColorFillApi extends RetryAbleRequester {
  ColorFillApi() : super(client: DioNode().build());

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    var userManager = AppDelegate.instance.getManager<UserManager>();
    var effectManager = AppDelegate.instance.getManager<EffectManager>();
    Map<String, String> headers = {};
    headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    var apiConfigEntity = await effectManager.loadData();
    var pick = apiConfigEntity?.aiConfig.pick((t) => t.key == 'lineart');
    debugPrint(pick.toString());
    return ApiOptions(baseUrl: pick?.serverUrl ?? 'https://ai.pandoraai.app:7003', headers: headers);
  }

  Future<ColorFillResultEntity?> transfer({
    required String imageUrl,
    required String directoryPath,
    onFailed,
  }) async {
    var baseEntity = await post(
      '/sdapi/v1/lineart',
      params: {
        'init_images': [imageUrl],
      },
      onFailed: onFailed,
      needRetry: true,
      canClickRetry: true,
    );
    ColorFillResultEntity? result = jsonConvert.convert<ColorFillResultEntity>(baseEntity?.data);
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
