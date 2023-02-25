import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/image/sync_download_video.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:common_utils/common_utils.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';

class TransformApi {
  late Uploader _api;

  TransformApi() {
    _api = Uploader();
  }

  bind(State state) => _api.bindState(state);

  unbind() => _api.unbind();

  String getFileName(String directoryPath, String encode) {
    return '${directoryPath}$encode.png';
  }
  /// transform image, save to directoryPath/{md5 of data}.png
  /// if is video type. save to video path defined in [StorageOperator]
  Future<BaseEntity?> transform(String url, String directoryPath, Map<String, dynamic> params, {required String aiHost}) async {
    var baseEntity = await _api.post(url, params: params);
    if (baseEntity != null) {
      var dataString = baseEntity.data['data'].toString();
      if (TextUtil.isEmpty(dataString)) {
        return baseEntity;
      }
      if (dataString.contains('.mp4')) {
        var videoUrl = '$aiHost/resource/$dataString';
        var file = await SyncDownloadVideo(url: videoUrl, type: 'mp4').getVideo();
        if (file != null) {
          return baseEntity;
        } else {
          return null;
        }
      }
      if (dataString.startsWith('<')) {
        return baseEntity;
      }
      String key = EncryptUtil.encodeMd5(dataString);
      String filePath = getFileName(directoryPath, key);
      var base64decode = await base64Decode(dataString);
      await File(filePath).writeAsBytes(base64decode.toList());
      return baseEntity;
    }
    return baseEntity;
  }
}
