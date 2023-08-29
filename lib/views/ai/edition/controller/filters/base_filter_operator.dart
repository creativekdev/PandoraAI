import 'filters_holder.dart';

abstract class BaseFilterOperator<T> {
  FiltersHolder parent;

  BaseFilterOperator({required this.parent});

  update() => parent.update();

  onInit(T recent);

  dispose(){}
}
