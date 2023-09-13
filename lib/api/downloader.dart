import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';

import '../widgets/widget_extensions.dart';

class Downloader {
  // 工厂模式
  factory Downloader() => _getInstance();

  static Downloader get instance => _getInstance();
  static Downloader? _instance;

  static Downloader _getInstance() {
    _instance ??= Downloader._internal();
    return _instance!;
  }

  late Dio client;

  Map<String, List<DownloadListener>> _listenerMap = {};
  Map<String, CancelToken> _taskMap = {};

  Downloader._internal() {
    BaseOptions options = new BaseOptions();
    options.receiveTimeout = 0;
    options.connectTimeout = 60000;
    client = Dio(options);
  }

  subscribe(String key, DownloadListener listener) {
    var listeners = _listenerMap[key];
    if (listeners == null) {
      _listenerMap[key] = [];
      listeners = _listenerMap[key];
    }
    listeners!.add(listener);
  }

  unsubscribeSync(String key, DownloadListener listener) {
    var listeners = _listenerMap[key];
    if (listeners != null) {
      delay(() => listeners.remove(listener));
    }
  }

  Future<Response?> downloadSync(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return client.download(url, savePath, onReceiveProgress: onReceiveProgress);
    } on DioError catch (e) {
      return null;
    }
  }

  /// download files
  Future<String> download(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    var key = EncryptUtil.encodeMd5('$url$savePath');
    if (_listenerMap[key] == null) {
      _listenerMap[key] = [];
    }
    if (_taskMap[key] != null) {
      if (_taskMap[key]!.isCancelled) {
        _taskMap.remove(key);
      } else {
        return key;
      }
    }
    CancelToken cancelToken = CancelToken();
    String tempPath = savePath + ".tmp";
    var tmpFile = File(tempPath);
    if (tmpFile.existsSync()) {
      tmpFile.deleteSync();
    }
    _taskMap[key] = cancelToken;
    try {
      client.download(
        url,
        tempPath,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          onReceiveProgress?.call(count, total);
          _listenerMap[key]?.forEach((element) {
            element.onChanged.call(count, total);
          });
        },
      ).then((value) async {
        var statusCode = value.statusCode ?? 0;
        if (statusCode >= 200 && statusCode < 300) {
          var file = File(tempPath);
          await file.copy(savePath);
          file.delete();
          _listenerMap[key]?.forEach((element) {
            element.onFinished.call(File(savePath));
          });
        } else {
          _listenerMap[key]?.forEach((element) {
            element.onError(Exception(value.statusMessage));
          });
        }
        _taskMap.remove(key);
      }).onError((error, stackTrace) {
        _listenerMap[key]?.forEach((element) {
          element.onError(Exception(error.toString()));
        });
      });
    } on Exception catch (e) {
      _listenerMap[key]?.forEach((element) {
        element.onError.call(e);
      });
      _taskMap.remove(key);
    }
    return key;
  }

  cancel(String key) {
    var cancelToken = _taskMap[key];
    if (cancelToken != null) {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel();
      }
    }
  }
}

class DownloadListener {
  final Function(File file) onFinished;
  final Function(int count, int total) onChanged;
  final Function(Exception exception) onError;

  DownloadListener({required this.onChanged, required this.onError, required this.onFinished});
}
