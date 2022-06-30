const int _thousand = 1000;
const int _million = _thousand * 1000;
const int _billion = _million * 1000;

extension NumEx on num {
  String get socialize {
    if (this >= _billion) {
      var d = this / _billion;
      return '${d.toStringAsFixed(1)}b';
    }
    if (this >= _million) {
      var d = this / _million;
      return '${d.toStringAsFixed(1)}m';
    }
    if (this >= 1000) {
      var d = this / 1000;
      return '${d.toStringAsFixed(1)}k';
    }
    return '$this';
  }
}
