import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/edition/controller/ie_base_holder.dart';
import 'package:image/image.dart' as imgLib;

class RemoveBgHolder extends ImageEditionBaseHolder {
  ui.Color? backgroundColor;
  File? _backgroundImage;

  File? get backgroundImage => _backgroundImage;

  set backgroundImage(File? file) {
    _backgroundImage = file;
    buildBackLibImg();
  }

  File? _removedImage;

  File? get removedImage => _removedImage;

  set removedImage(File? file) {
    _removedImage = file;
    buildFrontLibImg();
  }

  double ratio = 1;

  ui.Image? imageUiFront;
  imgLib.Image? imageFront;
  imgLib.Image? imageBack;

  RemoveBgHolder({required super.parent});

  @override
  initData() {
    if (removedImage == null) {}
  }

  buildBackLibImg() async {
    if (_backgroundImage == null) {
      imageBack = null;
    } else {
      imageBack = await getLibImage(await getImage(_backgroundImage!));
    }
    update();
  }

  buildFrontLibImg() async {
    if (_removedImage == null) {
      imageFront = null;
    } else {
      imageUiFront = await getImage(_removedImage!);
      imageFront = await getLibImage(imageUiFront!);
    }
    update();
  }

  ui.Color rgbaToAbgr(ui.Color rgbaColor) {
    int abgrValue = (rgbaColor.alpha << 24) | (rgbaColor.blue << 16) | (rgbaColor.green << 8) | rgbaColor.red;
    return ui.Color(abgrValue);
  }
}
