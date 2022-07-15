import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';

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
    client = DioNode.instance.build();
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

  /// download files
  String download(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) {
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
    _taskMap[key] = cancelToken;
    try {
      client.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          onReceiveProgress?.call(count, total);
          _listenerMap[key]?.forEach((element) {
            element.onChanged.call(count, total);
          });
        },
      ).then((value) {
        if (value.statusCode == 200) {
          _listenerMap[key]?.forEach((element) {
            element.onFinished.call(File(savePath));
          });
        } else {
          _listenerMap[key]?.forEach((element) {
            element.onError(Exception(value.statusMessage));
          });
        }
        _taskMap.remove(key);
      });
    } on Exception catch (e) {
      _listenerMap[key]?.forEach((element) {
        element.onError.call(e);
      });
      _taskMap.remove(key);
    }

    return key;
  }
}

class DownloadListener {
  final Function(File file) onFinished;
  final Function(int count, int total) onChanged;
  final Function(Exception exception) onError;

  DownloadListener({required this.onChanged, required this.onError, required this.onFinished});
}
