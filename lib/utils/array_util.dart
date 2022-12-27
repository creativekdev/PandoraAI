import 'package:cartoonizer/Common/importFile.dart';

typedef TransAction<T, S> = T Function(S data);
typedef TransAction2<T, S> = T Function(S data, int index);

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

  Future<List<T>> filterSync(Future<bool> Function(T t) action) async {
    List<T> result = [];
    for (var value in this) {
      if (await action(value)) {
        result.add(value);
      }
    }
    return result;
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

  List<Out> transfer<Out>(TransAction2<Out, T> action) {
    List<Out> result = [];
    for (int i = 0; i < this.length; i++) {
      result.add(action(this[i], i));
    }
    return result;
  }

  int? findPosition(TransAction<bool, T> action) {
    for (int i = 0; i < this.length; i++) {
      if (action(this[i])) {
        return i;
      }
    }
    return null;
  }
}
