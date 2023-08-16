import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/edition/controller/ie_base_holder.dart';
import 'package:image/image.dart' as imgLib;

import '../../../../app/app.dart';
import '../../../../app/cache/cache_manager.dart';
import '../../../common/background/background_picker.dart';

class RemoveBgHolder extends ImageEditionBaseHolder {
  ui.Color? backgroundColor;
  File? _backgroundImage;

  File? get backgroundImage => _backgroundImage;

  setBackgroundImage(File? file, bool isSave) async {
    _backgroundImage = file;
    await buildBackLibImg(isSave);
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
  BackgroundData preBackgroundData = BackgroundData();

  RemoveBgHolder({required super.parent});

  @override
  initData() {
    if (removedImage == null) {}
    preBackgroundData.color = Colors.transparent;
    preBackgroundData.filePath = null;
  }

  buildBackLibImg(bool isSave) async {
    if (_backgroundImage == null) {
      imageBack = null;
      if (isSave) {
        preBackgroundData.color = Colors.transparent;
        preBackgroundData.filePath = null;
      }
    } else {
      imageBack = await getLibImage(await getImage(_backgroundImage!));
      shownImage = imageBack;
      if (isSave) {
        preBackgroundData.color = null;
        preBackgroundData.filePath = _backgroundImage?.path;
      }
    }
    update();
  }

  saveImageWithColor(Color bgColor, bool isSave) async {
    imgLib.Image newImage = imgLib.Image(imageFront!.width, imageFront!.height);
    int fillColor = bgColor.value; // 获取颜色的ARGB值
    print("127.0.0.1 fillColor== $fillColor");
    if (isSave) {
      preBackgroundData.color = abgrToRgba(fillColor);
      print("127.0.0.1 preBackgroundData.color == ${preBackgroundData.color}");
      preBackgroundData.filePath = null;
    }
    newImage.fillBackground(fillColor);
    imgLib.drawImage(newImage, imageFront!);
    shownImage = newImage;
    CacheManager cacheManager = AppDelegate.instance.getManager();
    var path = cacheManager.storageOperator.removeBgDir.path + '${DateTime.now().millisecondsSinceEpoch}.png';
    List<int> outputBytes = imgLib.encodePng(newImage);
    await File(path).writeAsBytes(outputBytes);
    resultFilePath = path;
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

  ui.Color abgrToRgba(int abgrValue) {
    int alpha = (abgrValue >> 24) & 0xFF;
    int blue = (abgrValue >> 16) & 0xFF;
    int green = (abgrValue >> 8) & 0xFF;
    int red = abgrValue & 0xFF;

    return Color.fromRGBO(red, green, blue, alpha / 255.0);
  }

  @override
  onResetClick() {
    resultFilePath = null;
    canReset = false;
  }
}
