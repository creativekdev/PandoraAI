import 'dart:io';

import 'package:cartoonizer/common/importFile.dart';
import 'package:image/image.dart' as imgLib;

import '../../../../utils/utils.dart';
import 'image_edition_controller.dart';

abstract class ImageEditionBaseHolder {
  late ImageEditionController parent;

  Widget? shownImageWidget;

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
    // update();
  }

  File? get resultFile => _resultFilePath == null ? null : File(_resultFilePath!);

  imgLib.Image? _shownImage;

  set shownImage(imgLib.Image? value) {
    _shownImage = value;
    parent.setShownImage(value);
    // update();
  }

  imgLib.Image? get shownImage => _shownImage;

  bool _canReset = false;

  bool get canReset => _canReset;

  set canReset(bool value) {
    if (_canReset == value) {
      return;
    }
    _canReset = value;
    update();
  }

  ///------------------------------------------------------------------------------------
  ImageEditionBaseHolder({required this.parent});

  onInit() {}

  initData() async {
    getImage(originFile!).then((value) {
      getLibImage(value).then((value) {
        shownImage = value;
      });
    });
  }

  update() {
    parent.update();
  }

  dispose() {}

  onResetClick() {}
}
