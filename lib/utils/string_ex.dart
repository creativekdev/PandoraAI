import 'package:cartoonizer/config.dart';
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

  get cartoonizeApi {
    if (this == Config.instance.host) {
      return '$this/api/tool/image/cartoon';
    } else {
      return '$this/api/image/cartoonize';
    }
  }

  bool get isGoogleAccount {
    if(TextUtil.isEmpty(this.trim())) {
      return false;
    }
    return this.contains('googleusercontent.com');
  }
}