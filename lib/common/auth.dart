import 'dart:convert';
import 'dart:math';

import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

/// Generates a cryptographically secure random nonce, to be included in a
/// credential request.
String generateNonce([int length = 32]) {
  final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
}

Future<bool> signInWithApple() async {
  // To prevent replay attacks with the credential returned from Apple, we
  // include a nonce in the credential request. When signing in with
  // Firebase, the nonce in the id token returned by Apple, is expected to
  // match the sha256 hash of `rawNonce`.
  final rawNonce = generateNonce();
  final nonce = sha256ofString(rawNonce);

  // Request credential for the currently signed in Apple account.
  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: nonce,
  );

  // Create an `OAuthCredential` from the credential returned by Apple.
  final oauthCredential = OAuthProvider("apple.com").credential(
    idToken: appleCredential.identityToken,
    rawNonce: rawNonce,
  );

  print(oauthCredential.idToken);

  // Sign in the user with Firebase. If the nonce we generated earlier does
  // not match the nonce in `appleCredential.identityToken`, sign in will fail.
  var appleInfo = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  var appleUser = appleInfo.user;

  var email = appleUser?.email ?? "";
  var emptyName = email.isEmpty ? '' : email.split("@")[0];
  var body = {
    "apple_id": appleUser?.uid ?? "",
    "email": email,
    "name": appleUser?.displayName ?? emptyName,
    "type": "apple_id",
  };

  final tokenResponse = await API.post("/signup/oauth/apple/callback", body: body);

  if (tokenResponse.statusCode == 200) {
    final Map parsedAppleResponse = json.decode(tokenResponse.body);
    if (parsedAppleResponse['data']['signup'] as bool) {
      // server logined redirect
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cookie = tokenResponse.headers.toString();
      var str = cookie.split(";");
      String id = "";
      for (int j = 0; j < str.length; j++) {
        if (str[j].contains("sb.connect.sid")) {
          id = str[j];
          j = str.length;
        }
      }
      var finalId = id.split(",");
      if (finalId.length > 1) {
        for (int j = 0; j < finalId.length; j++) {
          if (finalId[j].contains("sb.connect.sid")) {
            id = finalId[j];
            j = finalId.length;
          }
        }
      }
      prefs.setBool("isLogin", true);
      prefs.setString("login_cookie", id.split("=")[1]);
      return true;
    }
  }
  return false;
}
