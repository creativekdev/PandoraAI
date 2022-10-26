import 'dart:convert';
import 'package:cartoonizer/app/user/rate_notice_operator.dart';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/upload_record_entity.g.dart';

@JsonSerializable()
class UploadRecordEntity {
  late String url;
  @JSONField(name: "create_dt")
  late int createDt;
  late String fileName;

  UploadRecordEntity({
    this.url = '',
    this.createDt = 0,
    this.fileName = '',
  });

  factory UploadRecordEntity.fromJson(Map<String, dynamic> json) => $UploadRecordEntityFromJson(json);

  Map<String, dynamic> toJson() => $UploadRecordEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

extension UploadRecordEntityEx on UploadRecordEntity {
  bool urlExpired() {
    return DateTime.now().millisecondsSinceEpoch - createDt > 6 * 24 * hour;
  }
}