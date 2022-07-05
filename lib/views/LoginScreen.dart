import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/common/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'ForgotPasswordScreen.dart';
import 'SignupScreen.dart';
import 'SocialSignUpScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isShow = true;
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool isLoading = false;
  var token;
  var tokenId;
  UserManager userManager = AppDelegate.instance.getManager();
  late ScrollController scrollController;
  double blueAreaHeight = 100;

  @override
  void initState() {
    logEvent(Events.login_page_loading);
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

  Future<void> goBack() async {
    final box = GetStorage();
    String? login_back_page = box.read('login_back_page');
    if (login_back_page != null) {
      Navigator.popUntil(context, ModalRoute.withName(login_back_page));
      box.remove('login_back_page');
    } else {
      Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
    }
  }

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
    passController.dispose();
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
                  StringConstant.login,
                  ColorConstant.BtnTextColor,
                  FontWeight.w600,
                  $(18),
                )),
            body: Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(bottom: 2.h),
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
                                  ImagesConstant.ic_login_cartoon,
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
                    TitleTextWidget(StringConstant.welcome, ColorConstant.White, FontWeight.w600, 20),
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
                    TextInputWidget(StringConstant.email, ImagesConstant.ic_email, ColorConstant.TextBlack, FontWeight.w400, 12.sp, TextInputAction.next,
                        TextInputType.emailAddress, false, emailController),
                    SizedBox(
                      height: 1.5.h,
                    ),
                    Container(
                      width: double.maxFinite,
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Card(
                        elevation: 0.5.h,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 4.w,
                            ),
                            Image.asset(
                              ImagesConstant.ic_password,
                              height: 8.w,
                              width: 8.w,
                            ),
                            SizedBox(
                              width: 1.5.w,
                            ),
                            Container(
                              width: 0.5.w,
                              height: 4.5.h,
                              color: ColorConstant.BorderColor,
                            ),
                            SizedBox(
                              width: 1.5.w,
                            ),
                            Expanded(
                              child: TextField(
                                controller: passController,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: ColorConstant.TextBlack,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Poppins',
                                  fontSize: 12.sp,
                                ),
                                obscureText: isShow,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(right: 5.w),
                                  hintText: StringConstant.password,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: ColorConstant.HintColor,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Poppins',
                                    fontSize: 12.sp,
                                  ),
                                ),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => {
                                    setState(() {
                                      isShow = !isShow;
                                    })
                                  },
                                  child: Image.asset(
                                    isShow ? ImagesConstant.ic_eye : ImagesConstant.ic_eye_close,
                                    height: 7.w,
                                    width: 7.w,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 1.h, right: 5.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    settings: RouteSettings(name: "/ForgotPasswordScreen"),
                                    builder: (context) => ForgotPasswordScreen(),
                                  ))
                            },
                            child: TitleTextWidget(StringConstant.forgot_password, ColorConstant.White, FontWeight.w400, 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (emailController.text.trim().isEmpty) {
                          CommonExtension().showToast(StringConstant.email_validation);
                        } else if (passController.text.trim().isEmpty) {
                          CommonExtension().showToast(StringConstant.pass_validation);
                        } else if (!CommonExtension().isValidEmail(emailController.text.trim())) {
                          CommonExtension().showToast(StringConstant.email_validation1);
                        } else {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            isLoading = true;
                          });
                          var baseEntity = await userManager.login(emailController.text.trim(), passController.text.trim());
                          setState(() {
                            isLoading = false;
                          });
                          if (baseEntity != null) {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setBool("isLogin", true);
                            await loginBack(context);
                            logEvent(Events.login, eventValues: {"method": "email"});
                          }
                        }
                      },
                      child: ButtonWidget(StringConstant.sign_in),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
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
                          TitleTextWidget(StringConstant.or, ColorConstant.PrimaryColor, FontWeight.w500, 12),
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
                              logEvent(Events.login, eventValues: {"method": "apple"});
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
                        height: 1.5.h,
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
                            print(parsed);
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
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: IconifiedButtonWidget(StringConstant.google, ImagesConstant.ic_google),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TitleTextWidget(StringConstant.no_account, ColorConstant.White, FontWeight.w400, 12),
                        GestureDetector(
                          onTap: () => {
                            GetStorage().write('signup_through', ''),
                            if (prefixPage == 'signup')
                              {Navigator.pop(context)}
                            else
                              {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    settings: RouteSettings(name: "/SignupScreen"),
                                    builder: (context) => SignupScreen(),
                                  ),
                                )
                              }
                          },
                          child: Text(
                            StringConstant.sign_up,
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
