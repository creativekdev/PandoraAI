import 'package:image/image.dart' as imgLib;

class ImageProcessor {
  static int argbToRgb(int pixel) {
    var alpha = imgLib.getAlpha(pixel);
    var a = alpha / 255;
    var red = imgLib.getRed(pixel);
    var green = imgLib.getGreen(pixel);
    var blue = imgLib.getBlue(pixel);
    var r = a * red + (1 - a) * 255;
    var g = a * green + (1 - a) * 255;
    var b = a * blue + (1 - a) * 255;
    return imgLib.Color.fromRgb(r.toInt(), g.toInt(), b.toInt());
  }

  static int getR(int pixel) {
    return imgLib.getRed(pixel);
  }

  static int getG(int pixel) {
    return imgLib.getGreen(pixel);
  }

  static int getB(int pixel) {
    return imgLib.getBlue(pixel);
  }

  static int getA(int pixel) {
    return imgLib.getAlpha(pixel);
  }

  static setRGB(int pixel, int r, int g, int b) {
    if (r > 255)
      r = 255;
    else if (r < 0) r = 0;
    if (g > 255)
      g = 255;
    else if (g < 0) g = 0;
    if (b > 255)
      b = 255;
    else if (b < 0) b = 0;

    return (pixel & 0xFF000000) | ((b << 16) & 0x00FF0000) | ((g << 8) & 0x0000FF00) | ((r) & 0x000000FF);
  }

  static convolution(imgLib.Image image, List<int> kernel) {
    List<int> di = [-1, 0, 1, -1, 0, 1, -1, 0, 1];
    List<int> dj = [-1, -1, -1, 0, 0, 0, 1, 1, 1];
    imgLib.Image __image = imgLib.copyCrop(image, 0, 0, image.width, image.height);

    for (int i = 1; i < image.width - 1; i++) {
      for (int j = 1; j < image.height - 1; j++) {
        int valr, valb, valg;
        valr = valb = valg = 0;
        for (int c = 0; c < 9; c++) {
          int pixel = image.getPixel(i + di[c], j + dj[c]);
          if (imgLib.getAlpha(pixel) < 255) {
            continue;
          }
          valr = valr + getR(pixel) * kernel[c];
          valg = valg + getG(pixel) * kernel[c];
          valb = valb + getB(pixel) * kernel[c];
        }
        __image.setPixel(i, j, setRGB(image.getPixel(i, j), valr, valg, valb));
      }
    }
    return __image;
  }
}
