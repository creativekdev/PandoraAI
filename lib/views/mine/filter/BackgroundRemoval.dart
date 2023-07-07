import 'dart:io';

import 'package:image/image.dart' as imgLib;
import 'package:cartoonizer/utils/utils.dart';

class BackgroundRemoval{

  Future<imgLib.Image> addBackgroundImage(imgLib.Image _image, String backgroundFilePath) async {
    File _backFile = File(backgroundFilePath);
    imgLib.Image res_image = await getLibImage(await getImage(_backFile!));
    res_image = imgLib.copyResize(res_image, width: _image.width, height: _image.height);
    for (int i = 0; i < res_image.width; i++) {
      for (int j = 0; j < res_image.height; j++) {
        var pixel1 = res_image.getPixel(i, j);
        var pixel2 = _image.getPixel(i, j);
        double alpha2 = imgLib.getAlpha(pixel2)/255;
        int red = (imgLib.getRed(pixel1)*(1- alpha2) + imgLib.getRed(pixel2) * alpha2).toInt() ;
        int green = (imgLib.getGreen(pixel1)*(1- alpha2) + imgLib.getGreen(pixel2) * alpha2).toInt() ;
        int blue = (imgLib.getBlue(pixel1)*(1- alpha2) + imgLib.getBlue(pixel2) * alpha2).toInt() ;
        res_image.setPixelRgba(i, j, red, green, blue);
      }
    }
    return res_image;
  }
}