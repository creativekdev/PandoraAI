import 'dart:io';

import 'package:cartoonizer/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

const _appDir = '/cartoonizer/';
const _videoDir = 'video/';

class StorageOperator {
  var _mainPath = '';

  /// videoDir
  Directory get videoDir => Directory('$_mainPath$_videoDir');

  Future<bool> initializeDir() async {
    Directory? directory = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
    if (directory == null) return false;
    await _mkdirs(directory.path, [_appDir]);
    _mainPath = '${directory.path}$_appDir';
    await _mkdirs(_mainPath, [
      _videoDir,
    ]);
    return true;
  }

  Future<bool> _mkdirs(String mainPath, List<String> paths) async {
    for (var value in paths) {
      await mkdirByPath('$mainPath/$value');
    }
    return true;
  }

  Future<int> totalSize() async {
    return await _getFileSize(videoDir);
  }

  Future<int> _getFileSize(dynamic target) async {
    if (target is Directory) {
      int total = 0;
      var list = await target.listSync();
      for (var value in list) {
        var i = await _getFileSize(value);
        total += i;
      }
      return total;
    } else if (target is File) {
      return await target.length();
    } else if (target is FileSystemEntity) {
      return _getFileSize(File(target.path));
    } else {
      return 0;
    }
  }

  Future clearDirectory(Directory directory) async {
    var listSync = directory.listSync();
    for (var value in listSync) {
      await value.delete();
    }
  }
}
