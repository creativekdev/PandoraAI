import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sizer/sizer.dart';

import 'connector_platform.dart';

class Auth {
  static const _platformList = <ConnectorPlatform>[
    ConnectorPlatform.youtube,
    ConnectorPlatform.instagram,
    ConnectorPlatform.tiktok,
  ];
  static const platform = MethodChannel('io.socialbook/linkone');

  Future<AuthResult> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

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
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

    String? token = facebookAuthCredential.accessToken;
    String? tokenId = facebookAuthCredential.idToken;
    print(facebookAuthCredential.accessToken);

    // Once signed in, return the UserCredential
    var userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    return AuthResult(credential: userCredential, token: token, tokenId: tokenId);
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

  AuthResult({
    this.credential,
    this.token,
    this.tokenId,
  });
}

class _TiktokRequester extends BaseRequester {
  _TiktokRequester() : super(newInstance: true);

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
