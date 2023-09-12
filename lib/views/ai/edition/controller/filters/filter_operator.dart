import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';

import 'base_filter_operator.dart';

class FilterOperator extends BaseFilterOperator<FilterEnum> {
  late List<FilterEnum> filters;

  late FilterEnum _currentFilter;

  FilterEnum get currentFilter => _currentFilter;

  set currentFilter(FilterEnum filterEnum) {
    _currentFilter = filterEnum;
    update();
  }

  var scrollController = ScrollController();
  double offset = 0;

  FilterOperator({required super.parent}) {
    scrollController.addListener(() {
      offset = scrollController.position.pixels;
    });
  }

  @override
  onInit(FilterEnum recent) {
    filters = FilterAdjustUtils.createFilters();
    _currentFilter = recent;
  }

  void restorePos() {
    if (scrollController.positions.isEmpty) {
      return;
    }
    scrollController.jumpTo(offset);
  }
}
