import 'package:cartoonizer/models/enums/adjust_function.dart';
import 'package:cartoonizer/views/ai/edition/controller/adjust_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/image_edition_controller.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
// import 'package:flutter_image_filters/flutter_image_filters.dart';

import '../../../../Common/importFile.dart';

class AdjustOperator {
  ImageEditionController parent;

  EditionItem? lastFun;

  AdjustOperator({required this.parent});

  update() => parent.update();

  List<AdjustData> dataList = [];

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
  }

  ScrollController scrollController = ScrollController();

  double padding = 0;
  double itemWidth = 0;
  bool isClick = false;

  autoCompleteScroll() {
    if (isClick) {
      return;
    }
    var pixels = scrollController.position.pixels + 0.000005; //修正误差
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

  void onInit() {
    resetConfig();
  }

  bool _canReset = false;

  bool get canReset => _canReset;

  set canReset(bool value) {
    if (_canReset == value) {
      return;
    }
    _canReset = value;
    update();
  }

  void resetConfig() {
    canReset = false;
    dataList = [
      AdjustData(function: AdjustFunction.brightness, initValue: 0, value: 0, previousValue: 0, start: -20, end: 20, multiple: 5),
      AdjustData(function: AdjustFunction.contrast, initValue: 0, value: 0, previousValue: 0, start: -40, end: 40, multiple: 2.5),
      AdjustData(function: AdjustFunction.saturation, initValue: 0, value: 0, previousValue: 0, start: -40, end: 40, multiple: 2.5),
      AdjustData(function: AdjustFunction.noise, initValue: 0, value: 0, previousValue: 0, start: 0, end: 40, multiple: 0.25),
      AdjustData(function: AdjustFunction.pixelate, initValue: 0, value: 0, previousValue: 0, start: 0, end: 40, multiple: 0.5),
      AdjustData(function: AdjustFunction.blur, initValue: 0, value: 0, previousValue: 0, start: 0, end: 40, multiple: 3 / 4),
      AdjustData(function: AdjustFunction.sharpen, initValue: 0, value: 0, previousValue: 0, start: 0, end: 40, multiple: 2.5),
      AdjustData(function: AdjustFunction.hue, initValue: 0, value: 0, previousValue: 0, start: -20, end: 20, multiple: 5),
    ];
    _index = 0;
    isClick = true;
    update();
    delay(() => isClick = false, milliseconds: 200);
    if (!scrollController.positions.isEmpty) {
      scrollController.animateTo(index * itemWidth, duration: Duration(milliseconds: 200), curve: Curves.bounceOut);
    }
  }

  buildConfiguration() {
    // var brightnessShaderConfiguration = BrightnessShaderConfiguration()..brightness = dataList[0].value * dataList[0].multiple / 200;
    // var contrastShaderConfiguration = ContrastShaderConfiguration()..contrast = dataList[1].value * dataList[1].multiple / 83.5 + 1.2;
    // var d = dataList[2].value * dataList[2].multiple / 100 + 1;
    // // var saturationShaderConfiguration = SaturationShaderConfiguration()..saturation = dataList[2].value * dataList[2].multiple / 100 + 1;
    // var saturationShaderConfiguration = SaturationShaderConfiguration()..saturation = d;
    // return GroupShaderConfiguration()
    //   ..add(brightnessShaderConfiguration)
    //   ..add(contrastShaderConfiguration)
    //   ..add(saturationShaderConfiguration);
  }
}
