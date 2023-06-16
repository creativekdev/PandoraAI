import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/views/mine/filter/ImageProcessor.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';

import 'package:image/image.dart' as imgLib;

class Filter{
  static List<String> filters = [
    "NOR",
    "INV",
    "EDG",
    "SHR",
    "OLD",
    "BLK",
    "RMV",
    "FUS",
    "FRZ",
    "CMC",
  ];
  static Future<imgLib.Image> ImFilter(String filter, imgLib.Image _image) async {
    //uncomment when image_picker is installed
    imgLib.Image res_image;
    res_image = imgLib.copyCrop(_image, 0, 0, _image.width, _image.height);
    switch (filter) {
      case "NOR":
        break;
      case "INV":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            r = 255 - r;
            g = 255 - g;
            b = 255 - b;
            pixel = ImageProcessor.setRGB(pixel, r, g, b);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "EDG":
        List<int> kernel = [-1, -1, -1, -1, 8, -1, -1, -1, -1];
        res_image = ImageProcessor.convolution(res_image, kernel);
        break;
      case "SHR":
        List<int> kernel = [-1, -1, -1, -1, 9, -1, -1, -1, -1];
        res_image = ImageProcessor.convolution(res_image, kernel);
        break;
      case "OLD":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int newR = (0.393 * r + 0.769 * g + 0.189 * b).toInt();
            int newG = (0.349 * r + 0.686 * g + 0.168 * b).toInt();
            int newB = (0.272 * r + 0.534 * g + 0.131 * b).toInt();
            pixel = ImageProcessor.setRGB(pixel, newR, newG, newB);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "BLK":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int avg = (r + g + b).toDouble() ~/ 3;
            if(avg>100) avg = 255;
            else avg = 0;
            int newR = avg;
            int newG = avg;
            int newB = avg;
            pixel = ImageProcessor.setRGB(pixel, newR, newG, newB);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "RMV":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int avg = (r + g + b).toDouble() ~/ 3;
            int newR = avg;
            int newG = avg;
            int newB = avg;
            pixel = ImageProcessor.setRGB(pixel, newR, newG, newB);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "FUS":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int newR = ((r * 128) / (g + b + 1)).toInt();
            int newG = ((g * 128) / (r + b + 1)).toInt();
            int newB = ((b * 128) / (g + r + 1)).toInt();
            pixel = ImageProcessor.setRGB(pixel, newR, newG, newB);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "FRZ":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int newR = (((r - g - b) * 3) / 2).toInt();
            int newG = (((g - r - b) * 3) / 2).toInt();
            int newB = (((b - g - r) * 3) / 2).toInt();
            pixel = ImageProcessor.setRGB(pixel, newR, newG, newB);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "CMC":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int newR = (((g - b + g + r).abs() * r) / 256).toInt();
            int newG = (((b - g + b + r).abs() * r) / 256).toInt();
            int newB = (((b - g + b + r).abs() * g) / 256).toInt();
            pixel = ImageProcessor.setRGB(pixel, newR, newG, newB);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      default:
    }
    return res_image;
  }
}