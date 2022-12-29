import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';

abstract class SyncImageProvider {
  Completer<ImageInfo> _completer = Completer();

  Future<ImageInfo> getImage() {
    try {
      _loadImage();
    } catch (e) {
      _completer.completeError(e);
    }
    return _completer.future;
  }

  _loadImage();
}

class SyncMemoryImage extends SyncImageProvider {
  Uint8List list;

  SyncMemoryImage({required this.list});

  @override
  _loadImage() {
    var resolve = MemoryImage(list).resolve(ImageConfiguration.empty);
    resolve.addListener(ImageStreamListener((image, synchronousCall) {
      if (_completer.isCompleted) {
        return;
      }
      _completer.complete(image);
    }));
  }
}

class SyncFileImage extends SyncImageProvider {
  File file;

  SyncFileImage({required this.file});

  @override
  void _loadImage() {
    var resolve = FileImage(file).resolve(ImageConfiguration.empty);
    resolve.addListener(ImageStreamListener((image, synchronousCall) {
      if (_completer.isCompleted) {
        return;
      }
      _completer.complete(image);
    }));
  }
}

class SyncNetworkImage extends SyncImageProvider {
  String url;

  SyncNetworkImage({required this.url});

  @override
  void _loadImage() {
    var resolve = NetworkImage(url).resolve(ImageConfiguration.empty);
    resolve.addListener(ImageStreamListener((image, synchronousCall) {
      if (_completer.isCompleted) {
        return;
      }
      _completer.complete(image);
    }));
  }
}

class SyncAssetImage extends SyncImageProvider {
  String assets;

  SyncAssetImage({required this.assets});

  @override
  void _loadImage() {
    var resolve = AssetImage(assets).resolve(ImageConfiguration.empty);
    resolve.addListener(ImageStreamListener((image, synchronousCall) {
      if (_completer.isCompleted) {
        return;
      }
      _completer.complete(image);
    }));
  }
}
