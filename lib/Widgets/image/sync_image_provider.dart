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

class SyncFileImage extends SyncImageProvider {
  File file;

  SyncFileImage({required this.file});

  @override
  void _loadImage() {
    var resolve = FileImage(file).resolve(ImageConfiguration.empty);
    resolve.addListener(ImageStreamListener((image, synchronousCall) {
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
      _completer.complete(image);
    }));
  }
}
