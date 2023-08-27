import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';

import 'base_filter_operator.dart';

class AdjustOperator extends BaseFilterOperator {
  AdjustOperator({required super.parent});

  @override
  onInit() {
    adjustList = FilterAdjustUtils.createAdjusts();
  }

  List<AdjustData> adjustList = [];

  int _adjIndex = 0;

  int get adjIndex => _adjIndex;

  set adjIndex(int i) {
    if (_adjIndex == i) {
      return;
    }
    _adjIndex = i;
    isClick = true;
    delay(() => isClick = false, milliseconds: 200);
    if (!scrollController.positions.isEmpty) {
      scrollController.animateTo(adjIndex * itemWidth, duration: Duration(milliseconds: 200), curve: Curves.bounceOut);
    }
    update();
    parent.buildImage();
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
    if (pos != _adjIndex) {
      _adjIndex = pos;
      update();
    }
    scrollController.animateTo(pos * itemWidth, duration: Duration(milliseconds: 100), curve: Curves.bounceOut);
  }

}
