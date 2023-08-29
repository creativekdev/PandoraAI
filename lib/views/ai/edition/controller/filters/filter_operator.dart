import 'package:cartoonizer/Common/importFile.dart';
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

  var scrollController = ItemScrollController();
  double itemWidth = 0;

  FilterOperator({required super.parent});

  @override
  onInit(FilterEnum recent) {
    filters = FilterAdjustUtils.createFilters();
    _currentFilter = recent;
  }
}
