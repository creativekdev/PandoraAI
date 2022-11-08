import 'dart:io';
import 'dart:typed_data';

import 'package:cartoonizer/network/base_requester.dart';
import 'package:dio/dio.dart';

class Uploader extends BaseRequester {
  /// upload don't need log response data
  Uploader() : super(newInstance: true, logResponseEnable: false);

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    return ApiOptions(baseUrl: '', headers: {});
  }

  /// upload file to aws s3
  Future<BaseEntity?> upload(String url, Uint8List image, String contentType) async {
    var stream = MultipartFile.fromBytes(image).finalize();
    return await put(url, stream,
        options: Options(
          headers: {'Content-Length': image.length},
        ),
        preHandleRequest: false,
        headers: {
          'Content-Type': contentType,
        });
  }

  /// upload file to aws s3
  Future<BaseEntity?> uploadFile(String url, File file, String contentType) async {
    return await put(url, file.openRead(),
        options: Options(
          headers: {'Content-Length': file.lengthSync()},
        ),
        preHandleRequest: false,
        headers: {
          'Content-Type': contentType,
        });
  }
}
