import 'dart:async';
import 'dart:io';

import 'package:cartoonizer/api/downloader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';

class SyncDownloadImage {
  final Completer<File?> _completer = Completer();
  String url;
  bool downloading = false;
  String key = '';
  DownloadListener? downloadListener;
  String fileName = '';
  String type;

  SyncDownloadImage({
    required this.url,
    required this.type,
  });

  Future<File?> getImage() {
    try {
      _loadImage();
    } catch (e) {
      _completer.completeError(e);
    }
    return _completer.future;
  }

  _loadImage() {
    fileName = EncryptUtil.encodeMd5(url);
    var storageOperator = AppDelegate.instance.getManager<CacheManager>().storageOperator;
    var imageDir = storageOperator.imageDir;
    var savePath = imageDir.path + fileName + '.' + type;
    File data = File(savePath);
    if (data.existsSync()) {
      _completer.complete(data);
      downloading = false;
    } else {
      downloadListener = DownloadListener(
          onChanged: (count, total) {},
          onError: (error) {
            _completer.complete(null);
            downloading = false;
            Downloader.instance.unsubscribeSync(key, downloadListener!);
          },
          onFinished: (File file) {
            var imageDir = storageOperator.imageDir;
            var savePath = imageDir.path + fileName + '.' + type;
            _completer.complete(File(savePath));
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
