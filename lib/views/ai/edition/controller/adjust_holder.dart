import 'dart:io';
import 'dart:ui';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/enums/adjust_function.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as imgLib;
import 'package:worker_manager/worker_manager.dart';

import 'ie_base_holder.dart';

class AdjustHolder extends ImageEditionBaseHolder {
  AdjustHolder({required super.parent});

  List<AdjustData> dataList = [];
  Executor executor = new Executor();

  @override
  setOriginFilePath(String? path) {
    if (originFilePath == path) {
      return;
    }
    originFilePath = path;
    initData();
    update();
  }

  void saveResult(imgLib.Image data) {
    CacheManager cacheManager = AppDelegate().getManager();
    var dir = cacheManager.storageOperator.adjustDir;
    var projName = EncryptUtil.encodeMd5(originFilePath!);
    var directory = Directory(dir.path + projName);
    mkdir(directory).whenComplete(() {
      var fileName = getFileName(originFile!.path);
      var targetFile = File(directory.path + '/${getConfigKey()}' + fileName);
      if (targetFile.existsSync()) {
        resultFilePath = targetFile.path;
        update();
      } else {
        var resultBytes = Uint8List.fromList(imgLib.encodeJpg(data));
        targetFile.writeAsBytes(resultBytes).whenComplete(() {
          resultFilePath = targetFile.path;
          update();
        });
      }
    });
  }

  String getConfigKey() {
    var string = dataList.map((e) => e.toString()).toList().join(',');
    return EncryptUtil.encodeMd5(string);
  }

  int _index = 0;

  int get index => _index;

  set index(int i) {
    if (_index == i) {
      return;
    }
    _index = i;
    isClick = true;
    delay(() => isClick = false, milliseconds: 200);
    if (!scrollController.positions.isEmpty) {
      scrollController.animateTo(index * itemWidth, duration: Duration(milliseconds: 200), curve: Curves.bounceOut);
    }
    update();
    showToast();
    onSwitchNewAdj();
  }

  ScrollController scrollController = ScrollController();

  double padding = 0;
  double itemWidth = 0;
  bool isClick = false;
  imgLib.Image? _originImageData;
  imgLib.Image? baseImage;
  imgLib.Image? shownImage;
  Uint8List? showImageBytes;

  @override
  void onInit() {
    super.onInit();
    resetConfig();
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

  @override
  initData() {
    getImage(originFile!).then((value) {
      getLibImage(value).then((value) {
        _originImageData = value;
        onSwitchNewAdj();
      });
    });
  }

  showToast() {
    CommonExtension().showToast(
      dataList[index].function.title(),
      gravity: ToastGravity.CENTER,
    );
  }

  void resetConfig() {
    dataList = [
      AdjustData(function: AdjustFunction.brightness, initValue: 0, value: 0, previousValue: 0, start: -50, end: 50),
      AdjustData(function: AdjustFunction.contrast, initValue: 100, value: 100, previousValue: 100, start: 0, end: 100),
      AdjustData(function: AdjustFunction.saturation, initValue: 100, value: 100, previousValue: 100, start: 0, end: 100),
      AdjustData(function: AdjustFunction.noise, initValue: 0, value: 0, previousValue: 0, start: 0, end: 10),
      AdjustData(function: AdjustFunction.pixelate, initValue: 0, value: 0, previousValue: 0, start: 0, end: 20),
      AdjustData(function: AdjustFunction.blur, initValue: 0, value: 0, previousValue: 0, start: 0, end: 30),
      AdjustData(function: AdjustFunction.sharpen, initValue: 0, value: 0, previousValue: 0, start: 0, end: 100),
      AdjustData(function: AdjustFunction.hue, initValue: 0, value: 0, previousValue: 0, start: -180, end: 180),
    ];
    _index = 0;
    isClick = true;
    update();
    onSwitchNewAdj();
    delay(() => isClick = false, milliseconds: 200);
    if (!scrollController.positions.isEmpty) {
      scrollController.animateTo(index * itemWidth, duration: Duration(milliseconds: 200), curve: Curves.bounceOut);
    }
  }

  void buildResult() async {
    var start = DateTime.now().millisecondsSinceEpoch;
    shownImage = await executor.execute(arg1: baseImage!, fun1: _copyImage);
    shownImage = await executor.execute(arg1: dataList.filter((t) => t.active), arg2: shownImage!, fun2: _imAdjust);
    print("trans-result: ${DateTime.now().millisecondsSinceEpoch - start}");
    createShownBytes();
    saveResult(shownImage!);
  }

  onSwitchNewAdj() async {
    if (_originImageData == null) {
      return;
    }
    dataList.forEach((element) => element.active = false);
    dataList[index].active = true;
    var start = DateTime.now().millisecondsSinceEpoch;
    baseImage = await executor.execute(arg1: _originImageData!, fun1: _copyImage);
    baseImage = await executor.execute(arg1: dataList.filter((t) => !t.active), arg2: baseImage!, fun2: _imAdjust);
    var baseT = DateTime.now().millisecondsSinceEpoch;
    var baseStart = baseT - start;
    print("trans-base: $baseStart");
    shownImage = await executor.execute(arg1: baseImage!, fun1: _copyImage);
    shownImage = await executor.execute(arg1: dataList.filter((t) => t.active), arg2: shownImage!, fun2: _imAdjust);
    print("trans-result: ${DateTime.now().millisecondsSinceEpoch - baseT}");
    createShownBytes();
    saveResult(shownImage!);
  }

  void createShownBytes() {
    if (shownImage == null) {
      return;
    }
    getUiImage(shownImage!).then((value) async {
      var byteData = await value.toByteData(format: ImageByteFormat.png);
      showImageBytes = byteData!.buffer.asUint8List();
      shownImageWidget = Image.memory(showImageBytes!);
      update();
    });
  }

  @override
  dispose() {
    executor.dispose();
    return super.dispose();
  }
}

imgLib.Image _copyImage(imgLib.Image image, TypeSendPort port) {
  return imgLib.copyCrop(image, 0, 0, image.width, image.height);
}

imgLib.Image _imAdjust(List<AdjustData> datas, imgLib.Image image, TypeSendPort port) {
  for (var value in datas) {
    image = _imAdjustOne(value, image);
  }
  return image;
}

imgLib.Image _imAdjustOne(AdjustData data, imgLib.Image image) {
  switch (data.function) {
    case AdjustFunction.brightness:
      image = imgLib.brightness(image, data.value.toInt())!;
      break;
    case AdjustFunction.contrast:
      image = imgLib.contrast(image, data.value)!;
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
      image = imgLib.noise(image, (data.value / 100 * 255).toInt());
      break;
    case AdjustFunction.pixelate:
      image = imgLib.pixelate(image, data.value.toInt());
      break;
    case AdjustFunction.blur:
      image = imgLib.gaussianBlur(image, data.value ~/ 2);
      break;
    case AdjustFunction.sharpen:
      if (data.value.toInt() > 0) {
        final kernel = [-1, -1, -1, -1, 9 + data.value.toInt() / 100, -1, -1, -1, -1];
        image = imgLib.convolution(image, kernel);
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
  return image;
}

class AdjustData {
  AdjustFunction function;
  double value;
  final double initValue;
  double previousValue;
  double start;
  double end;
  bool active = false;

  AdjustData({
    required this.function,
    required this.value,
    required this.previousValue,
    required this.start,
    required this.end,
    required this.initValue,
  });

  double getProgress() {
    return (value - start) / getTotal();
  }

  double getTotal() {
    return end - start;
  }

  @override
  String toString() {
    return 'AdjustData{function: $function, value: $value, initValue: $initValue, previousValue: $previousValue, start: $start, end: $end}';
  }
}
