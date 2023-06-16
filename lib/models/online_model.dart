import 'package:cartoonizer/models/ad_config_entity.dart';
import 'package:cartoonizer/models/app_feature_entity.dart';
import 'package:cartoonizer/models/daily_limit_rule_entity.dart';
import 'package:cartoonizer/models/social_user_info.dart';

class OnlineModel {
  SocialUserInfo? user;
  AdConfigEntity adConfig;
  bool loginSuccess;
  DailyLimitRuleEntity dailyLimitRuleEntity;
  AppFeatureEntity? feature;

  OnlineModel({
    required this.user,
    required this.loginSuccess,
    required this.adConfig,
    required this.dailyLimitRuleEntity,
    required this.feature,
  });
}
