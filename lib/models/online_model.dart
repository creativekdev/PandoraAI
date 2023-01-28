import 'package:cartoonizer/models/ad_config_entity.dart';
import 'package:cartoonizer/models/social_user_info.dart';

class OnlineModel {
  SocialUserInfo? user;
  Map<String, dynamic> aiServers;
  AdConfigEntity adConfig;
  bool loginSuccess;

  OnlineModel({
    required this.user,
    required this.loginSuccess,
    required this.aiServers,
    required this.adConfig,
  });
}
