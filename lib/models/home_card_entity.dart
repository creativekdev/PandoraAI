import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/home_card_entity.g.dart';

@JsonSerializable()
class HomeCardEntity {

	late String type;
  @JSONField(name: "cover_image")
	late String url;
  
  HomeCardEntity();

  factory HomeCardEntity.fromJson(Map<String, dynamic> json) => $HomeCardEntityFromJson(json);

  Map<String, dynamic> toJson() => $HomeCardEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
