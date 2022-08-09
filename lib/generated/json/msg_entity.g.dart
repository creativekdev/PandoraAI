import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:cartoonizer/models/enums/msg_type.dart';


MsgEntity $MsgEntityFromJson(Map<String, dynamic> json) {
	final MsgEntity msgEntity = MsgEntity();
	final String? action = jsonConvert.convert<String>(json['action']);
	if (action != null) {
		msgEntity.action = action;
	}
	final String? detail = jsonConvert.convert<String>(json['detail']);
	if (detail != null) {
		msgEntity.detail = detail;
	}
	final int? toId = jsonConvert.convert<int>(json['to_id']);
	if (toId != null) {
		msgEntity.toId = toId;
	}
	final bool? isSystem = jsonConvert.convert<bool>(json['is_system']);
	if (isSystem != null) {
		msgEntity.isSystem = isSystem;
	}
	final bool? read = jsonConvert.convert<bool>(json['read']);
	if (read != null) {
		msgEntity.read = read;
	}
	final int? targetId = jsonConvert.convert<int>(json['target_id']);
	if (targetId != null) {
		msgEntity.targetId = targetId;
	}
	final int? campaignId = jsonConvert.convert<int>(json['campaign_id']);
	if (campaignId != null) {
		msgEntity.campaignId = campaignId;
	}
	final int? emailCampaignId = jsonConvert.convert<int>(json['email_campaign_id']);
	if (emailCampaignId != null) {
		msgEntity.emailCampaignId = emailCampaignId;
	}
	final int? emailAssignmentId = jsonConvert.convert<int>(json['email_assignment_id']);
	if (emailAssignmentId != null) {
		msgEntity.emailAssignmentId = emailAssignmentId;
	}
	final int? productId = jsonConvert.convert<int>(json['product_id']);
	if (productId != null) {
		msgEntity.productId = productId;
	}
	final int? productAssignmentId = jsonConvert.convert<int>(json['product_assignment_id']);
	if (productAssignmentId != null) {
		msgEntity.productAssignmentId = productAssignmentId;
	}
	final String? payload = jsonConvert.convert<String>(json['payload']);
	if (payload != null) {
		msgEntity.payload = payload;
	}
	final String? created = jsonConvert.convert<String>(json['created']);
	if (created != null) {
		msgEntity.created = created;
	}
	final String? modified = jsonConvert.convert<String>(json['modified']);
	if (modified != null) {
		msgEntity.modified = modified;
	}
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		msgEntity.id = id;
	}
	return msgEntity;
}

Map<String, dynamic> $MsgEntityToJson(MsgEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['action'] = entity.action;
	data['detail'] = entity.detail;
	data['to_id'] = entity.toId;
	data['is_system'] = entity.isSystem;
	data['read'] = entity.read;
	data['target_id'] = entity.targetId;
	data['campaign_id'] = entity.campaignId;
	data['email_campaign_id'] = entity.emailCampaignId;
	data['email_assignment_id'] = entity.emailAssignmentId;
	data['product_id'] = entity.productId;
	data['product_assignment_id'] = entity.productAssignmentId;
	data['payload'] = entity.payload;
	data['created'] = entity.created;
	data['modified'] = entity.modified;
	data['id'] = entity.id;
	return data;
}