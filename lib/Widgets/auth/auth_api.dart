import 'dart:convert';

import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';

class AuthApi extends RetryAbleRequester {
  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    return ApiOptions(baseUrl: Config.instance.host, headers: {});
  }


  Future<BaseEntity?> signUpWithGoogle(String token) async {
    var tokenBody = jsonEncode(<String, dynamic>{
      "access_token": token,
      "scope": "https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email openid",
      "token_type": "Bearer",
      "access_type": "offline",
      "type": "google_signup",
    });
    return get('/signup/oauth/google/callback', params: {'tokens': tokenBody});
  }

  Future<BaseEntity?> signUpWithYoutube(String token, int timeStamp) async {
    var tokenBody = jsonEncode(<String, dynamic>{
      "access_token": token,
      "scope": "https://www.googleapis.com/auth/yt-analytics.readonly https://www.googleapis.com/auth/youtube.readonly",
      "token_type": "Bearer",
      "access_type": "offline",
    });
    final headers = {"cookie": "bst_social_signup=$timeStamp"};
    return get('/signup/oauth/youtube/callback', params: {'tokens': tokenBody}, headers: headers);
  }

  Future<BaseEntity?> signUpWithInstagram(String token) async {
    var tempStamp = DateTime.now().millisecondsSinceEpoch;
    final headers = {"cookie": "bst_social_signup=$tempStamp"};
    var baseEntity = await get('/signup/oauth/instagram_v2/callback', params: {'access_token': token}, headers: headers);
    return baseEntity;
  }

  Future<BaseEntity?> signUpWithTiktok(String accessToken, String openId, String tempData) async {
    var tokenBody = jsonEncode(<String, dynamic>{
      "access_token": accessToken,
      "open_id": openId,
    });
    var tempStamp = DateTime.now().millisecondsSinceEpoch;
    final headers = {"cookie": "bst_social_signup=${tempStamp}"};
    return get('/signup/oauth/tiktok/callback', params: {'tokens': tokenBody, 'code': tempData}, headers: headers);
  }

  //////////////////////////////////////////////////////////////////////////////////////

  Future<BaseEntity?> connectWithYoutube(String token) async {
    var tokenBody = jsonEncode(<String, dynamic>{
      "access_token": token,
      "scope": "https://www.googleapis.com/auth/yt-analytics.readonly https://www.googleapis.com/auth/youtube.readonly",
      "token_type": "Bearer",
      "access_type": "offline",
    });
    var tempStamp = DateTime.now().millisecondsSinceEpoch;
    final headers = {"cookie": "bst_social_signup=$tempStamp"};
    return get('/oauth/youtube/callback', params: {'tokens': tokenBody}, headers: headers);
  }

  Future<BaseEntity?> connectWithFacebook(String token) async {
    // todo: facebook is not docked in yet
    return null;
  }

  Future<BaseEntity?> connectWithInstagram(String token) async {
    var tempStamp = DateTime.now().millisecondsSinceEpoch;
    final headers = {"cookie": "bst_social_signup=$tempStamp"};
    var baseEntity = await get('/oauth/instagram_v2/callback', params: {'access_token': token}, headers: headers);
    return baseEntity;
  }

  Future<BaseEntity?> connectWithTiktok(String accessToken, String openId, String tempData) async {
    var tokenBody = jsonEncode(<String, dynamic>{
      "access_token": accessToken,
      "open_id": openId,
    });
    var tempStamp = DateTime.now().millisecondsSinceEpoch;
    final headers = {"cookie": "bst_social_signup=${tempStamp}"};
    return get('/oauth/tiktok/callback', params: {'tokens': tokenBody, 'code': tempData}, headers: headers);
  }
}
