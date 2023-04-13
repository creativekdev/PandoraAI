import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/user_ref_link_entity.g.dart';

@JsonSerializable()
class UserRefLinkEntity {
  @JSONField(name: "user_id")
  int userId = 0;
  String code = '';
  int clicks = 0;
  bool approved = false;
  int score = 0;
  int signups = 0;
  @JSONField(name: "current_signups")
  int currentSignups = 0;
  int downloads = 0;
  @JSONField(name: "is_admin")
  bool isAdmin = false;
  @JSONField(name: "link_commission_rate")
  int linkCommissionRate = 0;
  dynamic note;
  @JSONField(name: "rf_products")
  dynamic rfProducts;
  dynamic benefits;
  String created = '';
  String modified = '';
  int id = 0;

  UserRefLinkEntity();

  factory UserRefLinkEntity.fromJson(Map<String, dynamic> json) => $UserRefLinkEntityFromJson(json);

  Map<String, dynamic> toJson() => $UserRefLinkEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
