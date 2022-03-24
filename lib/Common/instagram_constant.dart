class InstagramConstant {
  // test email
  // qvzkdrdjen_1592670448@tfbnw.net, open_yzsfeya_user@tfbnw.net

  static InstagramConstant? _instance;
  static InstagramConstant get instance {
    _instance ??= InstagramConstant._init();
    return _instance!;
  }

  InstagramConstant._init();

  static const String clientID = '213870987565647';
  static const String appSecret = '732af4bceef75c2215d9a6e4d86d3490';
  static const String redirectUri = 'https://socialbook.io/';
  static const String scope = 'user_profile,user_media';
  static const String responseType = 'code';
  final String url = 'https://api.instagram.com/oauth/authorize?client_id=$clientID&redirect_uri=$redirectUri&scope=user_profile,user_media&response_type=$responseType';
}
