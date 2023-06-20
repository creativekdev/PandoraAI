import 'dart:math';
import 'dart:ui';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/views/mine/filter/ImageProcessor.dart';
import 'package:image/image.dart' as imgLib;

class Adjust{
  int selectedID = 0;
  List<double> sliderValues = [50,50,50,0,0,0,0,0];
  static List<String> filters = [
    "Brightness",
    "Contrast",
    "Saturation",
    "Noise",
    "Pixelate",
    "Blur",
    "Sharpen",
    "Hue",
  ];
  int getCnt() {
    return filters.length;
  }
  void setSelectedID(int id) {
    selectedID = id;
  }
  int getSelectedID() {
    return selectedID;
  }
  double getSelectedValue() {
    return sliderValues[selectedID];
  }
  void setSliderValue(double sliderValue) {
    sliderValues[selectedID] = sliderValue;
  }
  Future<imgLib.Image> ImAdjust(imgLib.Image _image) async {
    //uncomment when image_picker is installed
    imgLib.Image res_image;
    res_image = imgLib.copyCrop(_image, 0, 0, _image.width, _image.height);
    switch (filters[selectedID]) {
      case "Brightness":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            r = r + (sliderValues[selectedID].toInt() - 50) * 2;
            g = g + (sliderValues[selectedID].toInt() - 50) * 2;
            b = b + (sliderValues[selectedID].toInt() - 50) * 2;
            pixel = ImageProcessor.setRGB(pixel, r, g, b);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "Contrast":
        int minR, minG, minB, maxR, maxG, maxB;
        minR = minG = minB = 255;
        maxR = maxG = maxB = 0;
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            minR = min(minR, r);
            maxR = max(maxR, r);
            minG = min(minG, g);
            maxG = max(maxG, g);
            minB = min(minB, b);
            maxB = max(maxB, b);
          }
        }
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int dr = maxR - minR;
            int dg = maxG - minG;
            int db = maxB - minB;
            r = ((r - minR) / dr) * 255 * (sliderValues[selectedID].toInt() + 1) * 2 ~/ 100;
            g = (g - minG) / dg * 255 * (sliderValues[selectedID].toInt() + 1) * 2 ~/ 100;
            b = (b - minB) / db * 255 * (sliderValues[selectedID].toInt() + 1) * 2 ~/ 100;
            pixel = ImageProcessor.setRGB(pixel, r, g, b);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "Saturation":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int a = 255;

            Color color = Color.fromARGB(a, r, g, b);
            HSVColor hsvColor = HSVColor.fromColor(color);
            hsvColor = hsvColor.withSaturation(sliderValues[selectedID] / 100);
            color = hsvColor.toColor();

            pixel = ImageProcessor.setRGBA(color.red, color.green, color.blue, color.alpha);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "Noise":

        break;
      case "Pixelate":

        int value  = sliderValues[selectedID].toInt() + 1;
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel((i~/value)*value, (j~/value)*value);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int a = 255;


            pixel = ImageProcessor.setRGB(pixel, r,g,b);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "Blur":

        break;
      case "Sharpen":

        break;
      case "Hue":

        break;
      default:
    }
    return res_image;
  }
}