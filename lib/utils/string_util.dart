const int _thousand = 1000;
const int _million = _thousand * 1000;
const int _billion = _million * 1000;

const int kb = 1024;
const int mb = 1024 * kb;
const int gb = 1024 * mb;

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

  String get fileSize {
    if (this >= gb) {
      return '${(this / gb).toStringAsFixed(2)} GB';
    } else if (this > mb) {
      return '${(this / mb).toStringAsFixed(2)} MB';
    } else if (this > kb) {
      return '${(this / kb).toStringAsFixed(2)} KB';
    } else {
      return '$this Bytes';
    }
  }
}
