import 'filters_holder.dart';

abstract class BaseFilterOperator {
  FiltersHolder parent;

  BaseFilterOperator({required this.parent});

  update() => parent.update();

  onInit();

  dispose(){}
}
