import 'package:cartoonizer/Widgets/connector/platform_connector_page.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:common_utils/common_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'connector_platform.dart';

class Auth {
  static const _platformList = <ConnectorPlatform>[
    ConnectorPlatform.youtube,
    ConnectorPlatform.instagram,
    ConnectorPlatform.tiktok,
  ];
  static const platform = MethodChannel(PLATFORM_CHANNEL);

  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      String? token = googleAuth?.accessToken;
      String? tokenId = googleAuth?.idToken;

      var credential;
      if (googleAuth?.accessToken != null || googleAuth?.idToken != null) {
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        var userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        return AuthResult(credential: userCredential, token: token, tokenId: tokenId);
      } else {
        return AuthResult(token: token, tokenId: tokenId);
      }
    } catch (error) {
      print(error);
      return AuthResult(token: null, tokenId: null, errorMsg: "Oops! Something went wrong");
    }
  }

  Future<AuthResult> signInWithYoutube() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: ['https://www.googleapis.com/auth/yt-analytics.readonly', 'https://www.googleapis.com/auth/youtube.readonly']).signIn();

    // Obtain the auth details from the request
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    String? token = googleAuth?.accessToken;
    String? tokenId = googleAuth?.idToken;

    var credential;
    try {
      if (googleAuth?.accessToken != null || googleAuth?.idToken != null) {
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        var userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        return AuthResult(credential: userCredential, token: token, tokenId: tokenId);
      } else {
        return AuthResult(token: token, tokenId: tokenId);
      }
    } catch (error) {
      print(error);
      return AuthResult(token: token, tokenId: tokenId);
    }
    // Once signed in, return the UserCredential
  }

  Future<AuthResult> signInWithFacebook() async {
    // Trigger the sign-in flow
    FacebookAuth.instance.autoLogAppEventsEnabled(true);
    final LoginResult loginResult = await FacebookAuth.instance.login(permissions: [
      'instagram_basic',
      'pages_show_list',
      'instagram_manage_insights',
      'pages_read_engagement',
      'instagram_manage_comments',
    ],loginBehavior: LoginBehavior.nativeOnly);

    if (loginResult.status == LoginStatus.success) {
      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

      String? token = facebookAuthCredential.accessToken;
      String? tokenId = facebookAuthCredential.idToken;
      LogUtil.d(facebookAuthCredential.accessToken, tag: 'FBSdkLogin');

      // Once signed in, return the UserCredential
      // var userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      return AuthResult(credential: null, token: token, tokenId: tokenId);
    } else {
      return AuthResult(errorMsg: loginResult.message);
    }
  }

  Future<TiktokResult?> signInWithTiktok() async {
    var tempData = await platform.invokeMethod("OpenTiktok");
    if (tempData != null) {
      var baseEntity = await _TiktokRequester().auth(tempData);
      if (baseEntity != null) {
        var accessToken = baseEntity.data['data']['access_token'];
        var openId = baseEntity.data['data']['open_id'];
        return TiktokResult(accessToken: accessToken, openId: openId, tempData: tempData);
      }
    }
    return null;
  }

  Future<void> accountBottomSheet(BuildContext context, {Function(bool? result)? callback}) {
    return showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (_) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(context).loginToThePlatformAccount,
                  style: TextStyle(
                    fontSize: $(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'PoppinsMedium',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _platformList
                      .map((e) => socialMediaContainer(
                              title: e.title(),
                              icon: e.image(),
                              onTap: () {
                                Get.back();
                                PlatformConnectorPage.push(context, platform: e).then((value) {
                                  callback?.call(value);
                                });
                              },
                              iconColor: Colors.white)
                          .intoContainer(margin: EdgeInsets.only(top: $(10))))
                      .toList(),
                ),
              ],
            ),
          );
        });
  }

  Widget socialMediaContainer({String? icon, String? title, Color? iconColor, dynamic onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 6.h,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 5.h,
              width: 5.h,
              child: Image.asset(
                icon!,
                height: 3.h,
                width: 3.h,
                fit: BoxFit.fitHeight,
              ),
            ),
            SizedBox(
              width: 2.w,
            ),
            Text(
              title!,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xff5f5f5f),
                fontSize: $(14),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}

class AuthResult {
  UserCredential? credential;
  String? token;
  String? tokenId;
  String? errorMsg;

  AuthResult({
    this.credential,
    this.token,
    this.tokenId,
    this.errorMsg,
  });
}

class _TiktokRequester extends RetryAbleRequester {
  _TiktokRequester() : super(client: DioNode.instance.build(logResponseEnable: true));

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    return ApiOptions(baseUrl: 'https://open-api.tiktok.com', headers: {});
  }

  Future<BaseEntity?> auth(String tempData) async {
    return await get('/oauth/access_token',
        params: {
          'client_key': 'aw9iospxikqd2qsx',
          'client_secret': 'eec8b87abbbb43f7d43aaf4a66155a2d',
          'code': tempData,
          'grant_type': 'authorization_code',
        },
        preHandleRequest: false);
  }
}

class TiktokResult {
  String accessToken;
  String openId;
  String tempData;

  TiktokResult({
    required this.tempData,
    required this.accessToken,
    required this.openId,
  });
}
