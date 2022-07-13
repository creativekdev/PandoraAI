import 'dart:typed_data';

import 'package:cartoonizer/network/base_requester.dart';
import 'package:dio/dio.dart';

class Uploader extends BaseRequester {
  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    return ApiOptions(baseUrl: '', headers: {});
  }

  /// upload file to aws s3
  /// if use file, data should be set file.openRead(),
  Future<BaseEntity?> upload(String url, Uint8List image, String fileName) async {
    var stream = MultipartFile.fromBytes(image).finalize();
    return await put(url, stream,
        options: Options(
          headers: {'Content-Length': image.length},
        ),
        preHandleRequest: false);
  }
}
