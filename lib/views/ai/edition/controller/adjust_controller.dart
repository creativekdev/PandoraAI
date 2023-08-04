import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/enums/adjust_function.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as imgLib;

class AdjustController extends GetxController {
  List<AdjustData> dataList = [];

  String? _originFilePath;

  String? get originFilePath => _originFilePath;

  set originFilePath(String? path) {
    if (_originFilePath == path) {
      return;
    }
    _originFilePath = path;
    getImage(originFile!).then((value) {
      getLibImage(value).then((value) {
        _imageData = value;
        update();
      });
    });
    update();
  }

  File? get originFile => _originFilePath == null ? null : File(_originFilePath!);

  int _index = 0;

  int get index => _index;

  set index(int i) {
    _index = i;
    isClick = true;
    delay(() => isClick = false, milliseconds: 200);
    scrollController.animateTo(index * itemWidth, duration: Duration(milliseconds: 200), curve: Curves.bounceOut);
    update();
    showToast();
  }

  ScrollController scrollController = ScrollController();

  double padding = 0;
  double itemWidth = 0;
  imgLib.Image? _imageData;
  Uint8List? resultBytes;
  bool isClick = false;

  @override
  void onInit() {
    super.onInit();
    dataList = [
      AdjustData(function: AdjustFunction.brightness, value: 0, previousValue: 0, start: -20, end: 20),
      AdjustData(function: AdjustFunction.contrast, value: 100, previousValue: 100, start: 0, end: 100),
      AdjustData(function: AdjustFunction.saturation, value: 100, previousValue: 100, start: 0, end: 100),
      AdjustData(function: AdjustFunction.noise, value: 0, previousValue: 0, start: 0, end: 10),
      AdjustData(function: AdjustFunction.pixelate, value: 0, previousValue: 0, start: 0, end: 20),
      AdjustData(function: AdjustFunction.blur, value: 0, previousValue: 0, start: 0, end: 30),
      AdjustData(function: AdjustFunction.sharpen, value: 0, previousValue: 0, start: 0, end: 100),
      AdjustData(function: AdjustFunction.hue, value: 0, previousValue: 0, start: -180, end: 180),
    ];
  }

  autoCompleteScroll() {
    if (isClick) {
      return;
    }
    var pixels = scrollController.position.pixels;
    var pos = pixels ~/ itemWidth;
    var d = pixels % itemWidth;
    if (d > 0.5 * itemWidth) {
      pos++;
    }
    if (pos != _index) {
      _index = pos;
      update();
      showToast();
    }
    scrollController.animateTo(pos * itemWidth, duration: Duration(milliseconds: 100), curve: Curves.bounceOut);
  }

  void buildResult() {
    imgLib.Image res_image;
    res_image = imgLib.copyCrop(_imageData!, 0, 0, _imageData!.width, _imageData!.height);
    _imAdjust(dataList, res_image);
    resultBytes = Uint8List.fromList(imgLib.encodeJpg(res_image));
    update();
  }

  showToast() {
    CommonExtension().showToast(
      dataList[index].function.title(),
      gravity: ToastGravity.CENTER,
    );
  }
}

_imAdjust(List<AdjustData> datas, imgLib.Image image) {
  for (var value in datas) {
    _imAdjustOne(value, image);
  }
}

_imAdjustOne(AdjustData data, imgLib.Image image) {
  switch (data.function) {
    case AdjustFunction.brightness:
      imgLib.brightness(image, data.value.toInt());
      break;
    case AdjustFunction.contrast:
      imgLib.contrast(image, data.value);
      break;
    case AdjustFunction.saturation:
      for (var y = 0; y < image.height; ++y) {
        for (var x = 0; x < image.width; ++x) {
          final pixel = image.getPixel(x, y);
          int red = imgLib.getRed(pixel);
          int green = imgLib.getGreen(pixel);
          int blue = imgLib.getBlue(pixel);
          int alpha = imgLib.getAlpha(pixel);
          HSVColor hsv = HSVColor.fromColor(Color.fromARGB(alpha, red, green, blue));
          hsv = hsv.withSaturation(data.value * hsv.saturation / 100);
          Color color = hsv.toColor();
          image.setPixelRgba(x, y, color.red, color.green, color.blue);
        }
      }
      break;
    case AdjustFunction.noise:
      imgLib.noise(image, (data.value / 100 * 255).toInt());
      break;
    case AdjustFunction.pixelate:
      imgLib.pixelate(image, data.value.toInt());
      break;
    case AdjustFunction.blur:
      imgLib.gaussianBlur(image, data.value ~/ 2);
      break;
    case AdjustFunction.sharpen:
      if (data.value.toInt() > 0) {
        final kernel = [-1, -1, -1, -1, 9 + data.value.toInt() / 100, -1, -1, -1, -1];
        imgLib.convolution(image, kernel);
      }
      break;
    case AdjustFunction.hue:
      for (var y = 0; y < image.height; ++y) {
        for (var x = 0; x < image.width; ++x) {
          final pixel = image.getPixel(x, y);
          int red = imgLib.getRed(pixel);
          int green = imgLib.getGreen(pixel);
          int blue = imgLib.getBlue(pixel);
          int alpha = imgLib.getAlpha(pixel);
          HSVColor hsv = HSVColor.fromColor(Color.fromARGB(alpha, red, green, blue));
          hsv = hsv.withHue((hsv.hue + data.value) % 360);
          Color color = hsv.toColor();
          image.setPixelRgba(x, y, color.red, color.green, color.blue);
        }
      }
      break;
    case AdjustFunction.UNDEFINED:
      break;
  }
}

class AdjustData {
  AdjustFunction function;
  double value;
  double previousValue;
  double start;
  double end;

  AdjustData({
    required this.function,
    required this.value,
    required this.previousValue,
    required this.start,
    required this.end,
  });

  double getProgress() {
    return (value - start) / getTotal();
  }

  double getTotal() {
    return end - start;
  }
}
