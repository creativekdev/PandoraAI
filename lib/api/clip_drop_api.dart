import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/lib_image_widget/lib_image_widget.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';

class ClipDropApi extends RetryAbleRequester {
  CacheManager cacheManager = AppDelegate().getManager();

  ClipDropApi() : super(client: DioNode().build(logResponseEnable: false));

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    return ApiOptions(baseUrl: '', headers: {});
  }

  String getFileName(String directoryPath, String encode) {
    return '${directoryPath}$encode.png';
  }

  Future<String?> getCachePath(String filePath) async {
    var resultPath = _getResultPath(filePath);
    if (await File(resultPath).exists()) {
      return resultPath;
    }
    return null;
  }

  String _getResultPath(String filePath) {
    var rootPath = cacheManager.storageOperator.recordBackgroundRemovalDir.path;
    String key = EncryptUtil.encodeMd5(filePath);
    return getFileName(rootPath, key);
  }

  Future<String?> remove({
    required String filePath,
  }) async {
    var resultPath = _getResultPath(filePath);
    if (await File(resultPath).exists()) {
      return resultPath;
    }
    var formData = FormData();
    formData.files.add(MapEntry('image_file', await MultipartFile.fromFile(filePath)));
    var baseEntity = await postUpload(
      'https://clipdrop-api.co/remove-background/v1',
      data: formData,
      headers: {
        'x-api-key': 'e1b9d3125867dff8202a3a5f61a1349f3db48fb56582202403c72b8edc0b26d5aa8e8e5ebe29caed9d396140cbb64309',
      },
    );
    if (baseEntity != null) {
      var stream = await (baseEntity.data as ResponseBody).stream.toList();
      final result = BytesBuilder();
      for (Uint8List subList in stream) {
        result.add(subList);
      }
      var takeBytes = result.takeBytes();
      await File(resultPath).writeAsBytes(takeBytes);
      return resultPath;
    } else {
      return null;
    }
  }
}