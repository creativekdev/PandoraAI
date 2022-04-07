class InstagramConstant {
  static InstagramConstant? _instance;
  static InstagramConstant get instance {
    _instance ??= InstagramConstant._init();
    return _instance!;
  }

  InstagramConstant._init();

  static const String clientID = '265711231158701';
  static const String appSecret = '6482b266274a1009f8dcaa224b3798a0';
  static const String redirectUri = 'https://socialbook.io/oauth/instagram_v2/callback';
  static const String scope = 'user_profile,user_media';
  static const String responseType = 'code';
  final String url = 'https://api.instagram.com/oauth/authorize?client_id=$clientID&redirect_uri=$redirectUri&scope=user_profile,user_media&response_type=$responseType';
}
