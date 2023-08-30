///auto generate code, please do not modify;
enum MetagramStatus {
  init,
  processing,
  completed,
  UNDEFINED,
}

class MetagramStatusUtils {
  static MetagramStatus build(String? value) {
    switch (value) {
      case 'init':
        return MetagramStatus.init;
      case 'processing':
        return MetagramStatus.processing;
      case 'completed':
        return MetagramStatus.completed;
      default:
        return MetagramStatus.UNDEFINED;
    }
  }
}

extension MetagramStatusEx on MetagramStatus {
  value() {
    switch (this) {
      case MetagramStatus.init:
        return 'init';
      case MetagramStatus.processing:
        return 'processing';
      case MetagramStatus.completed:
        return 'completed';
      case MetagramStatus.UNDEFINED:
        return null;
    }
  }
}
