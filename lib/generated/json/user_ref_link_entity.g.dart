import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/user_ref_link_entity.dart';

UserRefLinkEntity $UserRefLinkEntityFromJson(Map<String, dynamic> json) {
  final UserRefLinkEntity userRefLinkEntity = UserRefLinkEntity();
  final int? userId = jsonConvert.convert<int>(json['user_id']);
  if (userId != null) {
    userRefLinkEntity.userId = userId;
  }
  final String? code = jsonConvert.convert<String>(json['code']);
  if (code != null) {
    userRefLinkEntity.code = code;
  }
  final int? clicks = jsonConvert.convert<int>(json['clicks']);
  if (clicks != null) {
    userRefLinkEntity.clicks = clicks;
  }
  final bool? approved = jsonConvert.convert<bool>(json['approved']);
  if (approved != null) {
    userRefLinkEntity.approved = approved;
  }
  final int? score = jsonConvert.convert<int>(json['score']);
  if (score != null) {
    userRefLinkEntity.score = score;
  }
  final int? signups = jsonConvert.convert<int>(json['signups']);
  if (signups != null) {
    userRefLinkEntity.signups = signups;
  }
  final int? currentSignups = jsonConvert.convert<int>(json['current_signups']);
  if (currentSignups != null) {
    userRefLinkEntity.currentSignups = currentSignups;
  }
  final int? downloads = jsonConvert.convert<int>(json['downloads']);
  if (downloads != null) {
    userRefLinkEntity.downloads = downloads;
  }
  final bool? isAdmin = jsonConvert.convert<bool>(json['is_admin']);
  if (isAdmin != null) {
    userRefLinkEntity.isAdmin = isAdmin;
  }
  final int? linkCommissionRate = jsonConvert.convert<int>(json['link_commission_rate']);
  if (linkCommissionRate != null) {
    userRefLinkEntity.linkCommissionRate = linkCommissionRate;
  }
  final dynamic note = jsonConvert.convert<dynamic>(json['note']);
  if (note != null) {
    userRefLinkEntity.note = note;
  }
  final dynamic rfProducts = jsonConvert.convert<dynamic>(json['rf_products']);
  if (rfProducts != null) {
    userRefLinkEntity.rfProducts = rfProducts;
  }
  final dynamic benefits = jsonConvert.convert<dynamic>(json['benefits']);
  if (benefits != null) {
    userRefLinkEntity.benefits = benefits;
  }
  final String? created = jsonConvert.convert<String>(json['created']);
  if (created != null) {
    userRefLinkEntity.created = created;
  }
  final String? modified = jsonConvert.convert<String>(json['modified']);
  if (modified != null) {
    userRefLinkEntity.modified = modified;
  }
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    userRefLinkEntity.id = id;
  }
  return userRefLinkEntity;
}

Map<String, dynamic> $UserRefLinkEntityToJson(UserRefLinkEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['user_id'] = entity.userId;
  data['code'] = entity.code;
  data['clicks'] = entity.clicks;
  data['approved'] = entity.approved;
  data['score'] = entity.score;
  data['signups'] = entity.signups;
  data['current_signups'] = entity.currentSignups;
  data['downloads'] = entity.downloads;
  data['is_admin'] = entity.isAdmin;
  data['link_commission_rate'] = entity.linkCommissionRate;
  data['note'] = entity.note;
  data['rf_products'] = entity.rfProducts;
  data['benefits'] = entity.benefits;
  data['created'] = entity.created;
  data['modified'] = entity.modified;
  data['id'] = entity.id;
  return data;
}
