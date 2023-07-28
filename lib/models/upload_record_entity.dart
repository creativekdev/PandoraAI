import 'dart:convert';
import 'package:cartoonizer/app/user/rate_notice_operator.dart';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/upload_record_entity.g.dart';

@JsonSerializable()
class UploadRecordEntity {
  late String key;
  late String url;
  @JSONField(name: "create_dt")
  late int createDt;
  late String originFileName;
  late String fileName;
  @JSONField(name: "cached_id")
  late String cachedId;
  bool checked = false;

  UploadRecordEntity({
    this.key = '',
    this.url = '',
    this.createDt = 0,
    this.fileName = '',
    this.cachedId = '',
    this.originFileName = '',
    this.checked = false,
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
    return DateTime.now().millisecondsSinceEpoch - createDt > 3 * 24 * hour;
  }
}
