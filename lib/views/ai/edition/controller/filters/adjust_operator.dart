import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
import 'package:common_utils/common_utils.dart';

import 'base_filter_operator.dart';

class AdjustOperator extends BaseFilterOperator<List<RecentAdjustData>> {
  String _initHash = '';
  double offset = 0;

  AdjustOperator({required super.parent}) {
    scrollController.addListener(() {
      offset = scrollController.position.pixels;
    });
  }

  @override
  onInit(List<RecentAdjustData> recent) {
    adjustList = FilterAdjustUtils.createAdjusts();
    _initHash = EncryptUtil.encodeMd5(adjustList.map((e) => e.toString()).join(','));
    for (var value in recent) {
      adjustList.pick((t) => t.function == value.mAdjustFunction)?.value = value.value;
    }
    adjIndex = 0;
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

  bool diffWithOri() => EncryptUtil.encodeMd5(adjustList.map((e) => e.toString()).join(',')) != _initHash;

  autoCompleteScroll() {
    if (isClick) {
      return;
    }
    if (scrollController.positions.isEmpty) {
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

  restorePos() {
    if (scrollController.positions.isEmpty) {
      return;
    }
    scrollController.jumpTo(offset);
  }
}
