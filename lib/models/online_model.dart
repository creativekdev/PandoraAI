import 'package:cartoonizer/models/social_user_info.dart';

class OnlineModel {
  SocialUserInfo? user;
  Map<String, dynamic> aiServers;
  bool loginSuccess;

  OnlineModel({
    required this.user,
    required this.loginSuccess,
    required this.aiServers,
  });
}
