import 'dart:async';
import 'dart:io';

import 'package:cartoonizer/api/downloader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';

class SyncDownloadVideo {
  final Completer<File?> _completer = Completer();
  String url;
  bool downloading = false;
  String key = '';
  DownloadListener? downloadListener;
  String fileName = '';
  String type;

  SyncDownloadVideo({
    required this.url,
    required this.type,
  });

  Future<File?> getVideo() {
    try {
      _loadVideo();
    } catch (e) {
      _completer.completeError(e);
    }
    return _completer.future;
  }

  _loadVideo() {
    fileName = EncryptUtil.encodeMd5(url);
    var storageOperator = AppDelegate.instance.getManager<CacheManager>().storageOperator;
    var videoDir = storageOperator.videoDir;
    var savePath = videoDir.path + fileName + '.' + type;
    File data = File(savePath);
    if (data.existsSync()) {
      if (!_completer.isCompleted) {
        _completer.complete(data);
      }
      downloading = false;
    } else {
      downloadListener = DownloadListener(
          onChanged: (count, total) {},
          onError: (error) {
            if (!_completer.isCompleted) {
              _completer.complete(null);
            }
            downloading = false;
            Downloader.instance.unsubscribeSync(key, downloadListener!);
          },
          onFinished: (File file) {
            var videoDir = storageOperator.videoDir;
            var savePath = videoDir.path + fileName + '.' + type;
            if (!_completer.isCompleted) {
              _completer.complete(File(savePath));
            }
            downloading = false;
          });
      downloading = true;
      Downloader.instance.download(url, savePath).then((value) {
        key = value;
        Downloader.instance.subscribe(value, downloadListener!);
      });
    }
  }
}
