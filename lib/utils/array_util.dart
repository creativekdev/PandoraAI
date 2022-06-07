typedef TransAction<T, S> = T Function(S data);

///
/// extensions feature dart > 2.7.0
extension ArrayExtension<T> on List<T> {
  String append(String split, String? Function(T e) action) {
    String result = "";
    for (int i = 0; i < length; i++) {
      T e = this[i];
      var actionResult = action(e);
      if (actionResult != null) {
        result += actionResult;
        if (i < length - 1) {
          result += split;
        }
      }
    }
    return result;
  }

  T? pick(bool Function(T t) action) {
    for (var value in this) {
      if (action(value)) {
        return value;
      }
    }
    return null;
  }

  List<T> filter(bool Function(T t) action) {
    List<T> result = [];
    for (var value in this) {
      if (action(value)) {
        result.add(value);
      }
    }
    return result;
  }

  List<T> wipeNullItem() => this.filter((t) => t != null);

  bool exist(bool Function(T t) action) {
    for (var value in this) {
      if (action(value)) {
        return true;
      }
    }
    return false;
  }
}
