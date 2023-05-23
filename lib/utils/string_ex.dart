import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
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
    if (TextUtil.isEmpty(this.trim())) {
      return false;
    }
    return this.contains('googleusercontent.com');
  }

  String get toUpperCaseFirst {
    if (TextUtil.isEmpty(this)) {
      return this;
    }
    var s = this[0];
    return s.toUpperCase() + this.substring(1);
  }

  String get appendHash {
    EffectDataController effectDataController = Get.find();
    if (effectDataController.data?.hash == null) {
      return this;
    }
    if (this.contains("?")) {
      return '${this}&hash=${effectDataController.data?.hash}';
    } else {
      return '${this}?hash=${effectDataController.data?.hash}';
    }
  }

  String get intl {
    if (Get.context == null) {
      return this;
    }
    BuildContext context = Get.context!;
    S.of(context);
    switch (this.toLowerCase()) {
      case 'not_found':
        return S.of(context).not_found;
      case 'invalid password':
        return S.of(context).invalid_password;
      case 'oops failed':
        return S.of(context).commonFailedToast;
      case 'recent':
        return S.of(context).recent;
      case 'get inspired':
        return S.of(context).get_inspired;
      case 'facetoon':
        return S.of(context).face_toon;
      case 'effects':
        return S.of(context).effects;
      case 'january':
        return S.of(context).january;
      case 'february':
        return S.of(context).february;
      case 'march':
        return S.of(context).march;
      case 'april':
        return S.of(context).april;
      case 'may':
        return S.of(context).may;
      case 'june':
        return S.of(context).june;
      case 'july':
        return S.of(context).july;
      case 'august':
        return S.of(context).august;
      case 'september':
        return S.of(context).september;
      case 'october':
        return S.of(context).october;
      case 'november':
        return S.of(context).november;
      case 'december':
        return S.of(context).december;
      case 'man':
        return S.of(context).man;
      case 'woman':
        return S.of(context).woman;
      case 'cat':
        return S.of(context).cat;
      case 'dog':
        return S.of(context).dog;
      default:
        return this;
    }
  }

  String get fileImageType {
    var lowerCase = this.toLowerCase();
    if (lowerCase == 'png' || lowerCase == 'jpg' || lowerCase == 'jpeg' || lowerCase == 'webp' || lowerCase == 'gif' || lowerCase == 'bmp') {
      return this;
    } else {
      return 'png';
    }
  }
}
