import 'dart:io';

import 'image_edition_controller.dart';

abstract class ImageEditionBaseHolder {
  late ImageEditionController _parent;

  String? originFilePath;

  setOriginFilePath(String? path) {
    if (originFilePath == path) {
      return;
    }
    originFilePath = path;
    initData();
    update();
  }

  File? get originFile => originFilePath == null ? null : File(originFilePath!);

  ///------------------------------------------------------------------------------------

  String? _resultFilePath;

  set resultFilePath(String? path) {
    if (_resultFilePath == path) {
      return;
    }
    _resultFilePath = path;
    update();
  }

  File? get resultFile => _resultFilePath == null ? null : File(_resultFilePath!);

  ///------------------------------------------------------------------------------------
  ImageEditionBaseHolder({required ImageEditionController parent}) {
    this._parent = parent;
  }

  onInit() {}

  initData();

  update() {
    _parent.update();
  }

  dispose() {}
}
