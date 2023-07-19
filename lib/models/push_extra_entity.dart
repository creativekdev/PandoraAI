import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/push_extra_entity.g.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';

@JsonSerializable()
class PushModuleExtraEntity {
  @JSONField(name: 'type')
  String? typeString;

  @JSONField(serialize: false, deserialize: false)
  HomeCardType? _type;

  HomeCardType get type {
    if (_type == null) {
      _type = HomeCardTypeUtils.build(typeString);
    }
    return _type!;
  }

  set type(HomeCardType type) {
    _type = type;
    typeString = _type!.value();
  }

  String? initKey;
  String? url;

  PushModuleExtraEntity();

  factory PushModuleExtraEntity.fromJson(Map<String, dynamic> json) => $PushModuleExtraEntityFromJson(json);

  Map<String, dynamic> toJson() => $PushModuleExtraEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
