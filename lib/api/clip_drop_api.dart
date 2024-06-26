import 'dart:io';
import 'dart:typed_data';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as libImg;
import 'package:worker_manager/worker_manager.dart';

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
    libImg.Image image = await getLibImage(await getImage(File(filePath)));
    List<int> bytes = await new Executor().execute(arg1: image, fun1: _convertToJpg);
    String newFilePath = "${resultPath}.jpg";
    File file = File(newFilePath);
    await file.writeAsBytes(bytes);
    var formData = FormData();
    formData.files.add(MapEntry('image_file', await MultipartFile.fromFile(newFilePath)));
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
      await File(resultPath).writeAsBytes(result.takeBytes(), flush: true);
      return resultPath;
    } else {
      return null;
    }
  }
}

Future<List<int>> _convertToJpg(libImg.Image data, TypeSendPort port) async {
  libImg.JpegEncoder encoder = libImg.JpegEncoder();
  List<int> bytes = encoder.encodeImage(data);
  return bytes;
}
