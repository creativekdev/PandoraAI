import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/common/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'InstaLoginScreen.dart';
import 'SocialSignUpScreen.dart';
import 'LoginScreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  UserManager userManager = AppDelegate.instance.getManager();

  late ScrollController scrollController;
  double blueAreaHeight = 100;

  @override
  void initState() {
    logEvent(Events.signup_page_loading);
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.offset < 0) {
        setState(() {
          blueAreaHeight = 100 + scrollController.offset.abs();
        });
      } else {
        setState(() {
          blueAreaHeight = 0;
        });
      }
    });
  }

  bool isShow = true;
  bool isShow1 = true;
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passController = TextEditingController();
  final cPassController = TextEditingController();
  bool isLoading = false;
  var token;
  var tokenId;
  static const platform = MethodChannel('io.socialbook/cartoonizer');

  Future<dynamic> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

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

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passController.dispose();
    cPassController.dispose();
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var prefixPage = ModalRoute.of(context)!.settings.arguments;

    return LoadingOverlay(
      isLoading: isLoading,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Container(
                height: blueAreaHeight,
                width: double.maxFinite,
                color: ColorConstant.BlueColor,
              ),
              Expanded(
                  child: Container(
                color: ColorConstant.BackgroundColor,
              ))
            ],
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppNavigationBar(
                blurAble: false,
                backgroundColor: ColorConstant.BlueColor,
                middle: TitleTextWidget(
                  StringConstant.sign_up,
                  ColorConstant.BtnTextColor,
                  FontWeight.w600,
                  $(18),
                )),
            body: Container(
              color: Colors.transparent,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    Container(
                      height: 45.h,
                      width: 100.w,
                      child: Stack(
                        children: [
                          Image.asset(
                            ImagesConstant.ic_round_top,
                            width: 100.w,
                            height: 40.h,
                            fit: BoxFit.fill,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 14.h),
                            child: Center(
                              child: SimpleShadow(
                                child: Image.asset(
                                  ImagesConstant.ic_signup_cartoon,
                                  width: 100.w,
                                  height: 30.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TitleTextWidget(StringConstant.welcome1, ColorConstant.White, FontWeight.w600, 20),
                    Container(
                      width: 20.w,
                      height: 0.3.h,
                      margin: EdgeInsets.only(top: 0.5.h),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            ColorConstant.RadialColor1,
                            ColorConstant.RadialColor2,
                          ],
                          radius: 4.w,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    if (Platform.isIOS)
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            var result = await signInWithApple();
                            if (result) {
                              userManager.refreshUser();
                              await loginBack(context);
                              logEvent(Events.signup, eventValues: {"method": "apple", "signup_through": GetStorage().read('signup_through') ?? ""});
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
                            if (isLoading) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                        child: IconifiedButtonWidget(StringConstant.apple, ImagesConstant.ic_signup_apple),
                      ),
                    if (Platform.isIOS)
                      SizedBox(
                        height: 2.h,
                      ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
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
                            "type": APP_TYPE
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
                              userManager.refreshUser();
                              await loginBack(context);
                              logEvent(Events.login, eventValues: {"method": "google"});
                            }
                          } else {
                            CommonExtension().showToast("Oops! Something went wrong");
                          }
                        } finally {
                          if (isLoading)
                            setState(() {
                              isLoading = false;
                            });
                        }
                        ;
                      },
                      child: IconifiedButtonWidget(StringConstant.google, ImagesConstant.ic_google),
                    ),
                    SizedBox(
                      height: 1.5.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        FirebaseAnalytics.instance.logSignUp(signUpMethod: "youtube");

                        setState(() {
                          isLoading = true;
                        });
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
                          setState(() {
                            isLoading = false;
                          });
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
                              userManager.refreshUser();
                              await loginBack(context);
                              logEvent(Events.login, eventValues: {"method": "youtube"});
                            }
                          } else {
                            CommonExtension().showToast("Oops! Something went wrong");
                          }
                        } finally {
                          if (isLoading)
                            setState(() {
                              isLoading = false;
                            });
                        }
                        ;
                      },
                      child: IconifiedButtonWidget(StringConstant.youtube, ImagesConstant.ic_youtube),
                    ),
                    SizedBox(
                      height: 1.5.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        FirebaseAnalytics.instance.logSignUp(signUpMethod: "instagram");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: RouteSettings(name: "/InstaLoginScreen"),
                            builder: (context) => InstaLoginScreen(),
                          ),
                        ).then((value) async {
                          if (value != null) {
                            setState(() {
                              isLoading = true;
                            });
                            var tempStamp = DateTime.now().millisecondsSinceEpoch;
                            final headers = {"cookie": "bst_social_signup=${tempStamp}"};
                            final access_response = await API.get("/signup/oauth/instagram_v2/callback", params: {"access_token": value['accessToken']}, headers: headers);
                            setState(() {
                              isLoading = false;
                            });
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
                      },
                      child: IconifiedButtonWidget(StringConstant.instagram, ImagesConstant.ic_instagram),
                    ),
                    SizedBox(
                      height: 1.5.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        FirebaseAnalytics.instance.logSignUp(signUpMethod: "tiktok");
                        var tempData = await platform.invokeMethod("OpenTiktok");
                        if (tempData != null) {
                          try {
                            setState(() {
                              isLoading = true;
                            });
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
                              setState(() {
                                isLoading = false;
                              });
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
                              setState(() {
                                isLoading = false;
                              });
                              CommonExtension().showToast("Oops! Something went wrong");
                            }
                          } catch (error) {}
                        }
                      },
                      child: IconifiedButtonWidget(StringConstant.tiktok, ImagesConstant.ic_tiktok),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TitleTextWidget(StringConstant.already_account, ColorConstant.White, FontWeight.w400, 12),
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
                              {Navigator.pop(context)}
                          },
                          child: Text(
                            StringConstant.sign_in,
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: ColorConstant.BlueColor, fontWeight: FontWeight.w500, fontFamily: 'Poppins', fontSize: 12, decoration: TextDecoration.underline),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      color: ColorConstant.BackgroundColor,
                      height: 6.h,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).blankAreaIntercept();
  }
}
