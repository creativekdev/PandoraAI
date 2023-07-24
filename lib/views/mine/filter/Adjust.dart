import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:image/image.dart' as imgLib;

class Adjust {
  int selectedID = 0;
  bool isInitalized = false;
  double previousValue = 0.0;
  List<double> initSliderValues = [0, 100, 100, 0, 0, 0, 0, 0];
  List<double> sliderValues = [0, 100, 100, 0, 0, 0, 0, 0];
  List<List<int>> range = [
    [-100, 100],
    [0, 200],
    [0, 100],
    [0, 100],
    [0, 100],
    [0, 100],
    [0, 100],
    [-180, 180]
  ];

  List<int> isChanging = [1, 0, 0, 0, 0, 0, 0, 0];

  static List<String> assets = [Images.brightness, Images.contrast, Images.saturation, Images.noise, Images.pixelate, Images.blur, Images.sharpen, Images.hue];
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

  double getSliderValue(int id) {
    return sliderValues[id];
  }

  int getFilterIndex(String name) {
    return filters.indexWhere((element) => element == name);
  }

  Future<imgLib.Image> ImAdjust(imgLib.Image _image) async {
    //uncomment when image_picker is installed
    print("127.0.0.1 ImAdjust begin ${DateTime.now()}");

    imgLib.Image res_image;
    res_image = imgLib.copyCrop(_image, 0, 0, _image.width, _image.height);
    int id;
    //Change Brightness
    id = getFilterIndex("Brightness");
    print("127.0.0.1 Brightness begin ${DateTime.now()}");

    imgLib.brightness(res_image, sliderValues[id].toInt());
    //Change Contrast
    id = getFilterIndex("Contrast");
    print("127.0.0.1 Contrast begin ${DateTime.now()}");

    imgLib.contrast(res_image, sliderValues[id]);
    //Change Saturation
    id = getFilterIndex("Saturation");
    print("127.0.0.1 Saturation begin ${DateTime.now()}");

    for (var y = 0; y < res_image.height; ++y) {
      for (var x = 0; x < res_image.width; ++x) {
        final pixel = res_image.getPixel(x, y);
        int red = imgLib.getRed(pixel);
        int green = imgLib.getGreen(pixel);
        int blue = imgLib.getBlue(pixel);
        int alpha = imgLib.getAlpha(pixel);
        HSVColor hsv = HSVColor.fromColor(Color.fromARGB(alpha, red, green, blue));
        hsv = hsv.withSaturation(sliderValues[id] * hsv.saturation / 100);
        Color color = hsv.toColor();
        res_image.setPixelRgba(x, y, color.red, color.green, color.blue);
      }
    }
    // imgLib.adjustColor(res_image, saturation: sliderValues[id] / 100);
    //
    // for (var y = 0; y < res_image.height; ++y) {
    //   for (var x = 0; x < res_image.width; ++x) {
    //     final pixel = res_image.getPixel(x, y);
    //     int red = imgLib.getRed(pixel);
    //     int green = imgLib.getGreen(pixel);
    //     int blue = imgLib.getBlue(pixel);
    //     int alpha = imgLib.getAlpha(pixel);
    //     HSVColor hsv = HSVColor.fromColor( Color.fromARGB(alpha, red, green, blue));
    //     hsv = hsv.withSaturation(sliderValues[id] / 100);
    //     Color color = hsv.toColor();
    //     res_image.setPixelRgba(x, y, color.red, color.green, color.blue);
    //   }
    // }

    //Change Noise
    id = getFilterIndex("Noise");
    print("127.0.0.1 Noise begin ${DateTime.now()}");

    res_image = imgLib.noise(res_image, (sliderValues[id] / 100 * 255).toInt());
    //Change Pixelate
    id = getFilterIndex("Pixelate");
    print("127.0.0.1 Pixelate begin ${DateTime.now()}");

    res_image = imgLib.pixelate(res_image, sliderValues[id].toInt());

    //Change Blur
    id = getFilterIndex("Blur");
    print("127.0.0.1 Blur begin ${DateTime.now()}");

    res_image = imgLib.gaussianBlur(res_image, (sliderValues[id].toInt() / 2).toInt());

    //Change Sharpen
    id = getFilterIndex("Sharpen");
    print("127.0.0.1 Sharpen begin ${DateTime.now()}");

    if (sliderValues[id].toInt() > 0) {
      final kernel = [-1, -1, -1, -1, 9 + sliderValues[id].toInt() / 100, -1, -1, -1, -1];
      res_image = imgLib.convolution(res_image, kernel);
    }
    //Change Hue
    id = getFilterIndex("Hue");
    print("127.0.0.1 Hue begin ${DateTime.now()}");
    for (var y = 0; y < res_image.height; ++y) {
      for (var x = 0; x < res_image.width; ++x) {
        final pixel = res_image.getPixel(x, y);
        int red = imgLib.getRed(pixel);
        int green = imgLib.getGreen(pixel);
        int blue = imgLib.getBlue(pixel);
        int alpha = imgLib.getAlpha(pixel);
        HSVColor hsv = HSVColor.fromColor(Color.fromARGB(alpha, red, green, blue));
        hsv = hsv.withHue((hsv.hue + sliderValues[id]) % 360);
        Color color = hsv.toColor();
        res_image.setPixelRgba(x, y, color.red, color.green, color.blue);
      }
    }
    print("127.0.0.1 ImAdjust end ${DateTime.now()}");

    // imgLib.adjustColor(res_image, hue: sliderValues[id] / 180 * 3.141592);
    return res_image;
  }
}
