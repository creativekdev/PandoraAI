import 'dart:io';

import 'package:cartoonizer/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

const _appDir = '/cartoonizer/';
const _videoDir = 'video/';
const _tempDir = 'temp/';

class StorageOperator {
  var _mainPath = '';

  /// videoDir
  Directory get videoDir => Directory('$_mainPath$_videoDir');

  Directory get tempDir => Directory('$_mainPath$_tempDir');

  Future<bool> initializeDir() async {
    Directory? directory = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
    if (directory == null) return false;
    await _mkdirs(directory.path, [_appDir]);
    _mainPath = '${directory.path}$_appDir';
    await _mkdirs(_mainPath, [
      _videoDir,
      _tempDir,
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
    var tempSize = await _getFileSize(tempDir);
    var videoSize = await _getFileSize(videoDir);
    return videoSize + tempSize;
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

  Future clearDirectories(List<Directory> list) async {
    for (var directory in list) {
      await clearDirectory(directory);
    }
  }

  Future clearDirectory(Directory directory) async {
    var listSync = directory.listSync();
    for (var value in listSync) {
      Directory d = Directory(value.path);
      if (d.existsSync()) {
        clearDirectory(d);
      } else {
        await value.delete();
      }
    }
  }
}
