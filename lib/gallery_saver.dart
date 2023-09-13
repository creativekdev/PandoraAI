import 'dart:io';

import 'package:cartoonizer/files.dart';
import 'package:common_utils/common_utils.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'Common/importFile.dart';
import 'app/app.dart';
import 'app/user/user_manager.dart';

class GallerySaver {
  static const String channelName = 'gallery_saver';
  static const String methodSaveImage = 'saveImage';
  static const String methodSaveVideo = 'saveVideo';

  static const String pleaseProvidePath = 'Please provide valid file path.';
  static const String fileIsNotVideo = 'File on path is not a video.';
  static const String fileIsNotImage = 'File on path is not an image.';
  static const MethodChannel _channel = const MethodChannel(channelName);

  ///saves video from provided temp path and optional album name in gallery
  static Future<String?> saveVideo(
    String path,
    bool isSaveToGallery, {
    String? albumName,
    bool toDcim = false,
    Map<String, String>? headers,
  }) async {
    File? tempFile;
    if (path.isEmpty) {
      throw ArgumentError(pleaseProvidePath);
    }
    if (!isVideo(path)) {
      throw ArgumentError(fileIsNotVideo);
    }
    if (!isLocalFilePath(path)) {
      tempFile = await _downloadFile(path, headers: headers);
      path = tempFile.path;
    }
    var result = true;
    if (isSaveToGallery) {
      result = await _channel.invokeMethod(
        methodSaveVideo,
        <String, dynamic>{'path': path, 'albumName': albumName, 'toDcim': toDcim},
      );
    }

    // if (tempFile != null) {
    //   tempFile.delete();
    // }
    return result ? path : "";
  }

  ///saves image from provided temp path and optional album name in gallery
  static Future<bool?> saveImage(
    String path, {
    String? albumName,
    bool toDcim = false,
    Map<String, String>? headers,
  }) async {
    File? tempFile;
    if (path.isEmpty) {
      throw ArgumentError(pleaseProvidePath);
    }
    if (!isImage(path)) {
      throw ArgumentError(fileIsNotImage);
    }
    if (!isLocalFilePath(path)) {
      tempFile = await _downloadFile(path, headers: headers);
      path = tempFile.path;
    }

    bool? result = await _channel.invokeMethod(
      methodSaveImage,
      <String, dynamic>{'path': path, 'albumName': albumName, 'toDcim': toDcim},
    );
    if (tempFile != null) {
      tempFile.delete();
    }
    if (result == true) {
      // 增加次数判断，看是否显示rate_us
      UserManager userManager = AppDelegate.instance.getManager();
      userManager.rateNoticeOperator.onSwitch(Get.context!, false);
    }
    return result;
  }

  static Future<void> saveImageFromPath(
    String path, {
    String? albumName,
    bool toDcim = false,
    Map<String, String>? headers,
  }) async {
    await _channel.invokeMethod(
      methodSaveVideo,
      <String, dynamic>{'path': path, 'albumName': albumName, 'toDcim': toDcim},
    );
  }

  static Future<File> _downloadFile(String url, {Map<String, String>? headers}) async {
    LogUtil.v(url);
    LogUtil.v(headers);
    http.Client _client = new http.Client();
    var req = await _client.get(Uri.parse(url), headers: headers);
    if (req.statusCode >= 400) {
      throw HttpException(req.statusCode.toString());
    }
    var bytes = req.bodyBytes;
    String dir = (await getTemporaryDirectory()).path;
    File file = new File('$dir/${basename(url)}');
    await file.writeAsBytes(bytes);
    LogUtil.d('File size:${await file.length()}');
    LogUtil.d(file.path);
    return file;
  }
}
