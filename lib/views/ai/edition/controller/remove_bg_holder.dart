import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/edition/controller/ie_base_holder.dart';
import 'package:image/image.dart' as imgLib;

import '../../../../app/app.dart';
import '../../../../app/cache/cache_manager.dart';

class RemoveBgHolder extends ImageEditionBaseHolder {
  ui.Color? backgroundColor;
  File? _backgroundImage;

  File? get backgroundImage => _backgroundImage;

  setBackgroundImage(File? file) async {
    _backgroundImage = file;
    await buildBackLibImg();
  }

  File? _removedImage;

  File? get removedImage => _removedImage;

  set removedImage(File? file) {
    _removedImage = file;
    shownImageWidget = Image.file(file!);
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

  saveImageWithColor(Color backgroundColor) async {
    imgLib.Image newImage = imgLib.Image(imageFront!.width, imageFront!.height);
    int fillColor = backgroundColor.value; // 获取颜色的ARGB值
    newImage.fillBackground(fillColor);
    imgLib.drawImage(newImage, imageFront!);
    CacheManager cacheManager = AppDelegate.instance.getManager();
    var path = cacheManager.storageOperator.removeBgDir.path + '${DateTime.now().millisecondsSinceEpoch}.jpg';
    List<int> outputBytes = imgLib.encodePng(newImage);
    File(path).writeAsBytes(outputBytes).then((value) {
      resultFilePath = path;
    });
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

  @override
  Widget buildShownImage() {
    if (resultFile == null) {
      return shownImageWidget ?? Image.file(originFile!);
    } else {
      return Image.file(resultFile ?? originFile!);
    }
  }
}
