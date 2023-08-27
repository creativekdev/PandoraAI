import 'dart:io';
import 'dart:typed_data';

import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/edition/controller/filters/filters_holder.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart';
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
      Uint8List takeBytes = result.takeBytes();
      var imageInfo = await SyncMemoryImage(list: takeBytes).getImage();
      var image = await getLibImage(imageInfo.image);
      for (var x = 0; x < image.width; x++) {
        for (var y = 0; y < image.height; y++) {
          var pixel = image.getPixel(x, y);
          var alpha = getAlpha(pixel);
          if (alpha != 0) {
            alpha = 255;
          }
          var red = getRed(pixel);
          var green = getGreen(pixel);
          var blue = getBlue(pixel);
          var fromRgb = Color.fromRgba(red, green, blue, alpha);
          image.setPixel(x, y, fromRgb);
        }
      }
      var list = await new Executor().execute(arg1: image, fun1: encodePngThread);
      await File(resultPath).writeAsBytes(list, flush: true);
      return resultPath;
    } else {
      return null;
    }
  }
}
