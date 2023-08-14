import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/enums/adjust_function.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/edition/widget/adjust_options.dart';
import 'package:common_utils/common_utils.dart';
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

  @override
  onResetClick() {
    resetConfig();
  }

  void saveResult(imgLib.Image data) async {
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
    onSwitchNewAdj();
  }

  ScrollController scrollController = ScrollController();

  double padding = 0;
  double itemWidth = 0;
  bool isClick = false;
  imgLib.Image? _originImageData;
  imgLib.Image? baseImage;
  imgLib.Image? shownImage;

  ui.Image? showUIImage;

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

  void resetConfig() {
    canReset = false;
    dataList = [
      AdjustData(
        function: AdjustFunction.brightness,
        initValue: 0,
        value: 0,
        previousValue: 0,
        start: -100,
        end: 100,
        multiple: 0.5,
      ),
      AdjustData(function: AdjustFunction.contrast, initValue: 100, value: 100, previousValue: 100, start: 0, end: 100, multiple: 1),
      AdjustData(function: AdjustFunction.saturation, initValue: 100, value: 100, previousValue: 100, start: 0, end: 100, multiple: 1),
      AdjustData(function: AdjustFunction.noise, initValue: 0, value: 0, previousValue: 0, start: 0, end: 100, multiple: 0.1),
      AdjustData(function: AdjustFunction.pixelate, initValue: 0, value: 0, previousValue: 0, start: 0, end: 100, multiple: 0.2),
      AdjustData(function: AdjustFunction.blur, initValue: 0, value: 0, previousValue: 0, start: 0, end: 100, multiple: 0.3),
      AdjustData(function: AdjustFunction.sharpen, initValue: 0, value: 0, previousValue: 0, start: 0, end: 100, multiple: 1),
      AdjustData(function: AdjustFunction.hue, initValue: 0, value: 0, previousValue: 0, start: -200, end: 200, multiple: 4),
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

  void buildResult(bool saveFile) async {
    canReset = true;
    shownImage = imgLib.Image.from(baseImage!);
    shownImage = await executor.execute(arg1: dataList.filter((t) => t.active), arg2: shownImage!, fun2: _imAdjust);
    createShownBytes();
    if (saveFile) {
      saveResult(shownImage!);
    }
  }

  onSwitchNewAdj() async {
    if (_originImageData == null) {
      return;
    }
    dataList.forEach((element) => element.active = false);
    dataList[index].active = true;
    baseImage = imgLib.Image.from(_originImageData!);
    baseImage = await executor.execute(arg1: dataList.filter((t) => !t.active), arg2: baseImage!, fun2: _imAdjust);
    shownImage = imgLib.Image.from(baseImage!);
    shownImage = await executor.execute(arg1: dataList.filter((t) => t.active), arg2: shownImage!, fun2: _imAdjust);
    createShownBytes();
    saveResult(shownImage!);
  }

  void createShownBytes() async {
    if (shownImage == null) {
      return;
    }

    var s = await executor.execute(arg1: shownImage!, fun1: _copyImage);
    showUIImage = await toImage(s);
    update();
  }

  @override
  Widget buildShownImage() {
    if (shownImage == null) {
      return Image.file(resultFile ?? originFile!);
    }
    double scale = ScreenUtil.screenSize.width / shownImage!.width;
    return Transform.scale(
        scale: scale,
        child: CustomPaint(
          painter: LibImagePainter(image: showUIImage!),
          child: Container(
            width: shownImage!.width.toDouble(),
            height: shownImage!.height.toDouble(),
          ),
        ));
  }

  @override
  dispose() {
    executor.dispose();
    return super.dispose();
  }

  Future<ui.Image> toImage(imgLib.Image image) async {
    final c = Completer<ui.Image>();
    var start = DateTime.now().millisecondsSinceEpoch;
    ui.decodeImageFromPixels(
      image.data.buffer.asUint8List(),
      image.width,
      image.height,
      ui.PixelFormat.rgba8888,
      (ui.Image image) {
        print("trans-lib-uiimage: ${DateTime.now().millisecondsSinceEpoch - start}");
        c.complete(image);
      },
    );
    return c.future;
  }
}

imgLib.Image _copyImage(imgLib.Image image, TypeSendPort port) {
  return imgLib.copyResize(image, width: image.width, height: image.height);
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
      image = imgLib.brightness(image, (data.value * data.multiple).toInt())!;
      break;
    case AdjustFunction.contrast:
      image = imgLib.contrast(image, data.value * data.multiple)!;
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
          hsv = hsv.withSaturation(data.value * data.multiple * hsv.saturation / 100);
          Color color = hsv.toColor();
          image.setPixelRgba(x, y, color.red, color.green, color.blue);
        }
      }
      break;
    case AdjustFunction.noise:
      image = imgLib.noise(image, ((data.value * data.multiple) / 100 * 255).toInt());
      break;
    case AdjustFunction.pixelate:
      image = imgLib.pixelate(image, (data.value * data.multiple).toInt());
      break;
    case AdjustFunction.blur:
      image = imgLib.gaussianBlur(image, (data.value * data.multiple) ~/ 2);
      break;
    case AdjustFunction.sharpen:
      if (data.value.toInt() > 0) {
        final kernel = [-1, -1, -1, -1, 9 + (data.value * data.multiple).toInt() / 100, -1, -1, -1, -1];
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
          hsv = hsv.withHue((hsv.hue + data.value * data.multiple) % 360);
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
  double multiple;

  AdjustData({
    required this.function,
    required this.value,
    required this.previousValue,
    required this.start,
    required this.end,
    required this.initValue,
    required this.multiple,
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
