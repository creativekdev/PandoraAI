import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/api/allshare_api.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/auth.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/password_util.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/account/EmailVerificationScreen.dart';
import 'package:cartoonizer/views/account/widget/icon_input.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/auth/sign_list_widget.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:common_utils/common_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../InstaLoginScreen.dart';
import 'SocialSignUpScreen.dart';
import 'LoginScreen.dart';
import 'widget/password_verify_desc_card.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends AppState<SignupScreen> {
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late AppApi api;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'signup_screen');
    Events.signupShow(
      source: cacheManager.getString(CacheManager.preSignupAction),
      prePage: cacheManager.getString(CacheManager.preLoginAction),
    );
    agreementTap = TapGestureRecognizer();
    termTap = TapGestureRecognizer();
    api = AppApi().bindState(this);
    passController.addListener(() {
      _passwordStrength = PasswordUtil.checkPasswordStrength(passController.text);
      setState(() {});
    });
  }

  PasswordStrength _passwordStrength = PasswordStrength.LengthError;

  bool isShow = true;
  bool isShow1 = true;
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passController = TextEditingController();
  final cPassController = TextEditingController();

  var token;
  var tokenId;
  static const platform = MethodChannel(PLATFORM_CHANNEL);

  bool agreementCheck = false;
  late TapGestureRecognizer agreementTap;
  late TapGestureRecognizer termTap;

  Future<dynamic> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      token = googleAuth?.accessToken;
      tokenId = googleAuth?.idToken;

      OAuthCredential credential;
      if (googleAuth?.accessToken != null || googleAuth?.idToken != null) {
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        return await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        return null;
      }
    } catch (error) {
      print(error);
      return null;
    }
    // Once signed in, return the UserCredential
  }

  Future<dynamic> signInWithYoutube() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: ['https://www.googleapis.com/auth/yt-analytics.readonly', 'https://www.googleapis.com/auth/youtube.readonly']).signIn();

    // Obtain the auth details from the request
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    token = googleAuth?.accessToken;
    tokenId = googleAuth?.idToken;

    var credential;
    try {
      if (googleAuth?.accessToken != null || googleAuth?.idToken != null) {
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        return await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        return null;
      }
    } catch (error) {
      print(error);
      return null;
    }
    // Once signed in, return the UserCredential
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

    token = facebookAuthCredential.accessToken;
    tokenId = facebookAuthCredential.idToken;
    print(facebookAuthCredential.accessToken);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  signUpNormal() async {
    var email = emailController.text.trim();
    var pass = passController.text.trim();
    var cpass = cPassController.text.trim();
    if (!email.contains('@')) {
      CommonExtension().showToast(S.of(context).input_valid_email, gravity: ToastGravity.CENTER);
      return;
    }
    if (TextUtil.isEmpty(pass)) {
      CommonExtension().showToast(S.of(context).input_password, gravity: ToastGravity.CENTER);
      return;
    }
    if (_passwordStrength == PasswordStrength.LengthError) {
      CommonExtension().showToast(S.of(context).password_length_tips, gravity: ToastGravity.CENTER);
      return;
    }
    if (pass != cpass) {
      CommonExtension().showToast(S.of(context).password_not_match, gravity: ToastGravity.CENTER);
      return;
    }
    if (!agreementCheck) {
      CommonExtension().showToast(S.of(context).pleaseReadAndAgreePrivacyAndTermsOfUse, gravity: ToastGravity.CENTER);
      return;
    }
    await showLoading();
    var split = email.split('@');
    String name = '';
    if (split.length > 0) {
      name = split[0];
    }
    api.signUp(name: name, email: email, password: pass).then((value) async {
      await hideLoading();
      if (value != null) {
        onLoginSuccess(context);
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passController.dispose();
    cPassController.dispose();
    api.unbind();
    super.dispose();
  }

  onAppleClick() {
    showLoading().whenComplete(() async {
      try {
        var result = await signInWithApple();
        if (result) {
          await onLoginSuccess(context);
        } else {
          CommonExtension().showToast("Oops! Something went wrong");
        }
      } on SignInWithAppleAuthorizationException catch (e) {
        switch (e.code) {
          case AuthorizationErrorCode.canceled:
          case AuthorizationErrorCode.unknown:
            // do nothing
            break;
          default:
            CommonExtension().showToast("Oops! Something went wrong");
            break;
        }
      } catch (e) {
        CommonExtension().showToast("Oops! Something went wrong");
      } finally {
        hideLoading();
      }
    });
  }

  onGoogleClick() {
    showLoading().whenComplete(() async {
      try {
        var temp = await signInWithGoogle();
        if (temp == null) {
          return;
        }
        var tokenBody = jsonEncode(<String, dynamic>{
          "access_token": token,
          "scope": "https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email openid",
          "token_type": "Bearer",
          "access_type": "offline",
          "type": "google_signup"
        });
        final tokenResponse = await API.get("/signup/oauth/google/callback", params: {"tokens": tokenBody});
        if (tokenResponse.statusCode == 200) {
          final Map parsed = json.decode(tokenResponse.body.toString());
          // print(parsed);
          if (parsed.containsKey("data")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: "/SocialSignUpScreen"),
                builder: (context) => SocialSignUpScreen(
                  additionalUserInfo: temp.additionalUserInfo!,
                  token: parsed['data']['token'],
                  tokenId: tokenId,
                  channel: "google",
                ),
              ),
            ).then((value) async {
              if (!value) {
                Navigator.pop(context, value);
              }
            });
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
            await onLoginSuccess(context);
          }
        } else {
          CommonExtension().showToast("Oops! Something went wrong");
        }
      } catch (e) {
      } finally {
        hideLoading();
      }
    });
  }

  onYoutubeClick() {
    showLoading().whenComplete(() async {
      FirebaseAnalytics.instance.logSignUp(signUpMethod: "youtube");
      try {
        var temp = await signInWithYoutube();
        if (temp == null) {
          return;
        }
        var tokenBody = jsonEncode(<String, dynamic>{
          "access_token": token,
          "scope": "https://www.googleapis.com/auth/yt-analytics.readonly https://www.googleapis.com/auth/youtube.readonly",
          "token_type": "Bearer",
          "access_type": "offline",
        });

        var tempStamp = DateTime.now().millisecondsSinceEpoch;
        final headers = {"cookie": "bst_social_signup=${tempStamp}"};
        final tokenResponse = await API.get("/signup/oauth/youtube/callback", params: {"tokens": tokenBody}, headers: headers);
        await hideLoading();
        if (tokenResponse.statusCode == 200) {
          final Map parsed = json.decode(tokenResponse.body.toString());
          print(parsed);
          if (parsed.containsKey("data")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: "/SocialSignUpScreen"),
                builder: (context) => SocialSignUpScreen(
                  additionalUserInfo: temp.additionalUserInfo!,
                  token: parsed['data']['token'],
                  tokenId: tempStamp,
                  channel: "youtube",
                ),
              ),
            ).then((value) async {
              if (!value) {
                Navigator.pop(context, value);
              }
            });
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
            onLoginSuccess(context);
          }
        } else {
          CommonExtension().showToast("Oops! Something went wrong");
        }
      } finally {
        hideLoading();
      }
    });
  }

  onInstagramClick() {
    FirebaseAnalytics.instance.logSignUp(signUpMethod: "instagram");
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/InstaLoginScreen"),
        builder: (context) => InstaLoginScreen(),
      ),
    ).then((value) async {
      if (value != null) {
        await showLoading();
        var tempStamp = DateTime.now().millisecondsSinceEpoch;
        final headers = {"cookie": "bst_social_signup=${tempStamp}"};
        final access_response = await API.get("/signup/oauth/instagram_v2/callback", params: {"access_token": value['accessToken']}, headers: headers);
        hideLoading();
        print(access_response.body);
        if (access_response.statusCode == 200) {
          final Map parsed = json.decode(access_response.body.toString());
          if (parsed["data"]["result"] as bool) {
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: "/SocialSignUpScreen"),
                builder: (context) => SocialSignUpScreen(
                  additionalUserInfo: null,
                  token: parsed["data"]["name"],
                  tokenId: tempStamp,
                  channel: "instagram",
                ),
              ),
            ).then((value) async {
              if (!value) {
                Navigator.pop(context, value);
              }
            });
          }
        } else {
          CommonExtension().showToast("Oops! Something went wrong");
        }
      }
      print(value);
    });
  }

  onTiktokClick() async {
    FirebaseAnalytics.instance.logSignUp(signUpMethod: "tiktok");
    var tempData = await platform.invokeMethod("OpenTiktok");
    if (tempData != null) {
      try {
        await showLoading();
        final codeResponse = await get(Uri.parse(
            "https://open-api.tiktok.com/oauth/access_token?client_key=aw9iospxikqd2qsx&client_secret=eec8b87abbbb43f7d43aaf4a66155a2d&code=${tempData}&grant_type=authorization_code"));
        print(codeResponse.statusCode);
        print(codeResponse.body);
        if (codeResponse.statusCode == 200) {
          final Map parsed = json.decode(codeResponse.body.toString());
          var tokenBody = jsonEncode(<String, dynamic>{
            "access_token": parsed['data']['access_token'],
            "open_id": parsed['data']['open_id'],
            // "refresh_token": parsed['data']['refresh_token'],
          });
          var tempStamp = DateTime.now().millisecondsSinceEpoch;
          final headers = {"cookie": "bst_social_signup=${tempStamp}"};
          final tiktokResponse = await API.get("/oauth/tiktok/callback", headers: headers, params: {"tokens": tokenBody, "code": tempData});
          hideLoading();
          if (tiktokResponse.statusCode == 200) {
            final Map parsed = json.decode(tiktokResponse.body.toString());
            if (parsed["data"]["result"] as bool) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: "/SocialSignUpScreen"),
                  builder: (context) => SocialSignUpScreen(
                    additionalUserInfo: parsed["data"],
                    token: parsed["data"]["name"],
                    tokenId: tempStamp,
                    channel: "tiktok",
                  ),
                ),
              ).then((value) async {
                if (!value) {
                  Navigator.pop(context, value);
                }
              });
            }
          } else {
            CommonExtension().showToast("Oops! Something went wrong");
          }
        } else {
          hideLoading();
          CommonExtension().showToast("Oops! Something went wrong");
        }
      } catch (error) {}
    }
  }

  String getPasswordStrength() {
    switch (_passwordStrength) {
      case null:
        return "";
      case PasswordStrength.LengthError:
        return "密码必须是6-16位";
      case PasswordStrength.Weak:
        return "密码强度太弱";
      case PasswordStrength.Medium:
        return "密码强度中等";
      case PasswordStrength.Strong:
        return "密码强度高";
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    var prefixPage = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppNavigationBar(
        backgroundColor: Colors.black,
        // visible: false,
        backIcon: Icon(
          Icons.close,
          size: $(24),
          color: Colors.white,
        ).hero(tag: 'back'),
      ),
      body: Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(bottom: 2.h, left: $(15), right: $(15)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).createAccount,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: $(32),
                ),
                textAlign: TextAlign.start,
              ).intoContainer(
                width: double.maxFinite,
                margin: EdgeInsets.only(top: $(70), bottom: $(24)),
              ),
              iconInput(
                title: S.of(context).email,
                iconRes: Images.ic_email,
                controller: emailController,
                inputAction: TextInputAction.next,
                showClear: true,
              ).intoMaterial(color: Colors.transparent).hero(tag: 'email'),
              SizedBox(height: $(16)),
              iconInput(
                title: S.of(context).password,
                iconRes: Images.ic_password,
                passwordIcon: Images.ic_password_hide,
                plainIcon: Images.ic_password_show,
                controller: passController,
                inputAction: TextInputAction.next,
                passwordInput: true,
              ).intoMaterial(color: Colors.transparent).hero(tag: 'pwd'),
              PasswordVerifyDescCard(passwordStrength: _passwordStrength).intoContainer(padding: EdgeInsets.symmetric(vertical: $(4))),
              SizedBox(height: $(5)),
              iconInput(
                title: S.of(context).c_password,
                iconRes: Images.ic_password,
                passwordIcon: Images.ic_password_hide,
                plainIcon: Images.ic_password_show,
                controller: cPassController,
                inputAction: TextInputAction.done,
                passwordInput: true,
              ),
              SizedBox(height: $(40)),
              TitleTextWidget(S.of(context).sign_up, ColorConstant.White, FontWeight.w500, $(16))
                  .intoContainer(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: $(10)),
                      decoration: BoxDecoration(
                        color: ColorConstant.DiscoveryBtn,
                        borderRadius: BorderRadius.circular($(8)),
                      ))
                  .intoMaterial(color: Colors.transparent)
                  .hero(tag: 'btn')
                  .intoGestureDetector(onTap: () {
                signUpNormal();
              }),
              SizedBox(height: $(15)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildCheckIcon(context, agreementCheck).intoGestureDetector(onTap: () {
                    setState(() {
                      agreementCheck = !agreementCheck;
                    });
                  }),
                  Expanded(
                      child: RichText(
                    text: TextSpan(text: S.of(context).IHaveReadAndAgreeTo, style: TextStyle(fontSize: $(14)), children: [
                      TextSpan(
                          text: S.of(context).UserAgreement,
                          style: TextStyle(color: ColorConstant.BlueColor),
                          recognizer: agreementTap
                            ..onTap = () {
                              var uri = Uri.parse(USER_PRIVACY);
                              if (Platform.isIOS) {
                                launchUrl(uri, mode: LaunchMode.inAppWebView);
                              } else {
                                launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            }),
                      TextSpan(text: S.of(context).and, style: TextStyle(color: ColorConstant.White)),
                      TextSpan(
                          text: S.of(context).TermsOfUse,
                          style: TextStyle(color: ColorConstant.BlueColor),
                          recognizer: termTap
                            ..onTap = () {
                              var uri = Uri.parse(TERM_AND_USE);
                              if (Platform.isIOS) {
                                launchUrl(uri, mode: LaunchMode.inAppWebView);
                              } else {
                                launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            }),
                    ]),
                    maxLines: 3,
                  )),
                ],
              ).hero(tag: "agreement"),
              Container(
                margin: EdgeInsets.only(
                  left: $(20),
                  right: $(20),
                  top: $(35),
                  bottom: $(30),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        color: ColorConstant.DividerColor,
                        thickness: 0.1.h,
                      ),
                    ),
                    SizedBox(
                      width: 3.w,
                    ),
                    TitleTextWidget(S.of(context).or, ColorConstant.loginTitleColor, FontWeight.w500, 12),
                    SizedBox(
                      width: 3.w,
                    ),
                    Expanded(
                      child: Divider(
                        color: ColorConstant.DividerColor,
                        thickness: 0.1.h,
                      ),
                    ),
                  ],
                ),
              ).intoMaterial(color: Colors.transparent).hero(tag: 'line'),
              SignListWidget(
                onTap: (account) {
                  switch (account) {
                    case ThirdPartAccount.apple:
                      onAppleClick();
                      break;
                    case ThirdPartAccount.google:
                      onGoogleClick();
                      break;
                    case ThirdPartAccount.youtube:
                      onYoutubeClick();
                      break;
                    case ThirdPartAccount.instagram:
                      onInstagramClick();
                      break;
                    case ThirdPartAccount.tiktok:
                      onTiktokClick();
                      break;
                  }
                },
                thirdPart: [
                  ThirdPartAccount.google,
                  ThirdPartAccount.youtube,
                  ThirdPartAccount.apple,
                  ThirdPartAccount.instagram,
                  ThirdPartAccount.tiktok,
                ],
              ),
              SizedBox(height: $(30)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TitleTextWidget(S.of(context).already_account, ColorConstant.White, FontWeight.w400, 12),
                  GestureDetector(
                    onTap: () => {
                      if (prefixPage != null)
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(name: "/LoginScreen", arguments: "signup"),
                              builder: (context) => LoginScreen(),
                            ),
                          )
                        }
                      else
                        {Navigator.pop(context, false)}
                    },
                    child: Text(
                      S.of(context).sign_in,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ColorConstant.BlueColor, fontWeight: FontWeight.w500, fontFamily: 'Poppins', fontSize: 12, decoration: TextDecoration.underline),
                    ),
                  )
                ],
              ),
              Container(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    ).blankAreaIntercept();
  }

  Widget buildCheckIcon(BuildContext context, bool check) {
    return (check
            ? Image.asset(
                Images.ic_album_checked,
                width: $(12),
                color: Colors.white,
              ).intoContainer(
                alignment: Alignment.center,
                width: $(16),
                height: $(16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular($(16)), color: ColorConstant.BlueColor),
              )
            : Container(
                width: $(16),
                height: $(16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular($(16)), border: Border.all(width: 1, color: Colors.white)),
              ))
        .intoContainer(padding: EdgeInsets.only(right: $(6), bottom: $(10), top: $(2)), color: Colors.transparent);
  }

  Future<void> onLoginSuccess(BuildContext context) async {
    var onlineModel = await userManager.refreshUser();
    if (onlineModel.user?.status != "activated") {
      Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => EmailVerificationScreen(emailController.text),
          settings: RouteSettings(name: "/EmailVerificationScreen"),
        ),
      ).then((value) async {
        if (value ?? false) {
          var action = AppDelegate.instance.getManager<CacheManager>().getString(CacheManager.preSignupAction);
          var prePage = AppDelegate.instance.getManager<CacheManager>().getString(CacheManager.preLoginAction);
          userManager.allShareApi.onSignUp(email: onlineModel.user?.getShownEmail() ?? '').whenComplete(() {
            userManager.allShareApi.identify(accountId: onlineModel.user?.id.toString() ?? '');
          });
          Events.signupOkShow(source: action, prePage: prePage);
          await loginBack(context);
        }
      });
    } else {
      userManager.allShareApi.onSignUp(email: onlineModel.user?.getShownEmail() ?? '').whenComplete(() {
        userManager.allShareApi.identify(accountId: onlineModel.user?.id.toString() ?? '');
      });
      var action = AppDelegate.instance.getManager<CacheManager>().getString(CacheManager.preSignupAction);
      var prePage = AppDelegate.instance.getManager<CacheManager>().getString(CacheManager.preLoginAction);
      Events.signupOkShow(source: action, prePage: prePage);
      await loginBack(context);
    }
  }
}
