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
    return _intlMap[this.toLowerCase()]?.call() ?? this;
  }

  String get fileImageType {
    var lowerCase = this.toLowerCase();
    if (lowerCase == 'png' || lowerCase == 'jpg' || lowerCase == 'jpeg' || lowerCase == 'webp' || lowerCase == 'gif' || lowerCase == 'bmp') {
      return this;
    } else {
      return 'png';
    }
  }

  DateTime? get timezoneCur {
    DateTime? result;
    var date = DateUtil.getDateTime(this, isUtc: true);
    if (date != null) {
      var timeZoneOffset = DateTime.now().timeZoneOffset;
      result = date.add(timeZoneOffset);
    }
    return result;
  }
}

typedef StringRender = String Function();

Map<String, StringRender> _intlMap = {
  'not_found': () => S.of(Get.context!).not_found,
  'invalid password': () => S.of(Get.context!).invalid_password,
  'oops failed': () => S.of(Get.context!).commonFailedToast,
  'recent': () => S.of(Get.context!).recent,
  'get inspired': () => S.of(Get.context!).get_inspired,
  'facetoon': () => S.of(Get.context!).face_toon,
  'effects': () => S.of(Get.context!).effects,
  'january': () => S.of(Get.context!).january,
  'february': () => S.of(Get.context!).february,
  'march': () => S.of(Get.context!).march,
  'april': () => S.of(Get.context!).april,
  'may': () => S.of(Get.context!).may,
  'june': () => S.of(Get.context!).june,
  'july': () => S.of(Get.context!).july,
  'august': () => S.of(Get.context!).august,
  'september': () => S.of(Get.context!).september,
  'october': () => S.of(Get.context!).october,
  'november': () => S.of(Get.context!).november,
  'december': () => S.of(Get.context!).december,
  'monday': () => S.of(Get.context!).monday,
  'tuesday': () => S.of(Get.context!).tuesday,
  'wednesday': () => S.of(Get.context!).wednesday,
  'thursday': () => S.of(Get.context!).thursday,
  'friday': () => S.of(Get.context!).friday,
  'saturday': () => S.of(Get.context!).saturday,
  'sunday': () => S.of(Get.context!).sunday,
  'man': () => S.of(Get.context!).man,
  'woman': () => S.of(Get.context!).woman,
  'cat': () => S.of(Get.context!).cat,
  'dog': () => S.of(Get.context!).dog,
  'size': () => S.of(Get.context!).size,
  'model': () => S.of(Get.context!).model,
  'quantity': () => S.of(Get.context!).quantity,
  'color': () => S.of(Get.context!).color,
  'colors': () => S.of(Get.context!).colors,
  'template': () => S.of(Get.context!).template,
  'album': () => S.of(Get.context!).album,
};
