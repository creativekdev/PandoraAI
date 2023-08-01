import 'package:cartoonizer/Common/importFile.dart';

const int _thousand = 1000;
const int _million = _thousand * 1000;
const int _billion = _million * 1000;

const int kb = 1024;
const int mb = 1024 * kb;
const int gb = 1024 * mb;

const _months = {
  1: 'January',
  2: 'February',
  3: 'March',
  4: 'April',
  5: 'May',
  6: 'June',
  7: 'July',
  8: 'August',
  9: 'September',
  10: 'October',
  11: 'November',
  12: 'December',
};

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

  String get dateMonth {
    String ym = '$this';
    if (ym.length != 6) {
      return '';
    }
    int month = int.parse(ym.substring(4));
    return _months[month]!;
  }

  String get dateYear {
    String ym = '$this';
    if (ym.length != 6) {
      return '';
    }
    int year = int.parse(ym.substring(0, 4));
    return '$year';
  }

  bool isSameYear(int value) {
    return this.dateYear == value.dateYear;
  }

  double get w {
    return ScreenUtil.screenSize.width / 100 * this;
  }

  double get h {
    return ScreenUtil.screenSize.height / 100 * this;
  }

  double get sp {
    return $(this.toDouble());
  }
}
