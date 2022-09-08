import 'package:common_utils/common_utils.dart';

extension StringEx on String {
  avatar() {
    if (TextUtil.isEmpty(this.trim())) {
      return this;
    }
    if (!this.startsWith('http')) {
      return 'https://s3-us-west-2.amazonaws.com/superboostaa/$this';
    }
    return this;
  }
}
