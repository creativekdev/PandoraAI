import 'package:cartoonizer/views/mine/filter/Filter.dart';

import 'base_filter_operator.dart';

class FilterOperator extends BaseFilterOperator {
  late List<FilterEnum> filters;

  late FilterEnum _currentFilter;

  FilterEnum get currentFilter => _currentFilter;

  set currentFilter(FilterEnum filterEnum) {
    _currentFilter = filterEnum;
    update();
  }

  FilterOperator({required super.parent});

  @override
  onInit() {
    filters = FilterAdjustUtils.createFilters();
    _currentFilter = FilterEnum.NOR;
  }
}
