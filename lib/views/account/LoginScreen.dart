import 'dart:io';

import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/auth/auth.dart';
import 'package:cartoonizer/widgets/auth/auth_api.dart';
import 'package:cartoonizer/widgets/auth/sign_list_widget.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/auth.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/account/EmailVerificationScreen.dart';
import 'package:cartoonizer/views/account/widget/icon_input.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ForgotPasswordScreen.dart';
import 'SignupScreen.dart';
import 'SocialSignUpScreen.dart';

class LoginScreen extends StatefulWidget {
  bool toSignUp;

  LoginScreen({Key? key, this.toSignUp = false}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends AppState<LoginScreen> {
  bool isShow = true;
  final emailController = TextEditingController();
  final passController = TextEditingController();

  // var token;
  // var tokenId;
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();

  bool agreementCheck = false;
  late TapGestureRecognizer agreementTap;
  late TapGestureRecognizer termTap;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'login_screen');
    Events.loginShow(source: cacheManager.getString(CacheManager.preLoginAction));
    agreementTap = TapGestureRecognizer();
    termTap = TapGestureRecognizer();
    thirdpartManager.adsHolder.ignore = true;
    delay(() {
      if (widget.toSignUp) {
        var prefixPage = ModalRoute.of(context)!.settings.arguments;
        toSignUp(prefixPage, context);
      }
    }, milliseconds: 64);
  }

  @override
  void dispose() {
    agreementTap.dispose();
    termTap.dispose();
    emailController.dispose();
    passController.dispose();
    thirdpartManager.adsHolder.ignore = false;
    super.dispose();
  }

  onAppleLogin() async {
    showLoading().whenComplete(() {
      signInWithApple().then((value) {
        if (value) {
          hideLoading().whenComplete(() async {
            onLoginSuccess(context);
          });
        } else {
          hideLoading().whenComplete(() {
            CommonExtension().showToast("Oops! Something went wrong");
          });
        }
      }).catchError((e) {
        hideLoading();
        if (e is SignInWithAppleAuthorizationException) {
          switch (e.code) {
            case AuthorizationErrorCode.canceled:
            case AuthorizationErrorCode.unknown:
              // do nothing
              break;
            default:
              CommonExtension().showToast("Oops! Something went wrong");
              break;
          }
        } else {
          CommonExtension().showToast("Oops! Something went wrong");
        }
      });
    });
  }

  onGoogleLogin() async {
    showLoading().whenComplete(() {
      Auth().signInWithGoogle().then((userCredential) {
        if (userCredential.credential == null) {
          if (!TextUtil.isEmpty(userCredential.errorMsg)) {
            CommonExtension().showToast(userCredential.errorMsg!);
          }
          hideLoading();
        } else {
          AuthApi().signUpWithGoogle(userCredential.token!).then((value) {
            hideLoading().whenComplete(() async {
              if (value == null) {
                CommonExtension().showToast("Oops! Something went wrong");
              } else {
                if (value.data is Map && (value.data as Map).containsKey('data')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: "/SocialSignUpScreen"),
                      builder: (context) => SocialSignUpScreen(
                        additionalUserInfo: userCredential.credential!.additionalUserInfo!,
                        token: value.data['data']['token'],
                        tokenId: value.data['data']['tokenId'],
                        channel: "google",
                      ),
                    ),
                  ).then((value) async {
                    if (!value) {
                      Navigator.pop(context, value);
                    }
                  });
                } else {
                  onLoginSuccess(context);
                }
              }
            });
          });
        }
      });
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    var prefixPage = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppNavigationBar(
        backgroundColor: Colors.black,
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
                S.of(context).welcomeBack,
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
                inputAction: TextInputAction.done,
                passwordInput: true,
              ).intoMaterial(color: Colors.transparent).hero(tag: 'pwd'),
              SizedBox(height: $(16)),
              Row(
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
                    child: TitleTextWidget(S.of(context).forgot_password, ColorConstant.BlueColor, FontWeight.w400, 12),
                  ),
                ],
              ),
              SizedBox(height: $(40)),
              TitleTextWidget(S.of(context).sign_in, ColorConstant.White, FontWeight.w500, $(16))
                  .intoContainer(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: $(10)),
                      decoration: BoxDecoration(
                        color: ColorConstant.DiscoveryBtn,
                        borderRadius: BorderRadius.circular($(8)),
                      ))
                  .intoMaterial(color: Colors.transparent)
                  .hero(tag: 'btn')
                  .intoGestureDetector(onTap: () async {
                if (emailController.text.trim().isEmpty) {
                  CommonExtension().showToast(S.of(context).email_validation);
                } else if (passController.text.trim().isEmpty) {
                  CommonExtension().showToast(S.of(context).pass_validation);
                } else if (!emailController.text.trim().isEmail) {
                  CommonExtension().showToast(S.of(context).email_validation1);
                } else if (!agreementCheck) {
                  CommonExtension().showToast(S.of(context).pleaseReadAndAgreePrivacyAndTermsOfUse);
                } else {
                  FocusManager.instance.primaryFocus?.unfocus();
                  showLoading().whenComplete(() async {
                    var baseEntity = await userManager.login(emailController.text.trim(), passController.text.trim());
                    if (baseEntity != null) {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setBool("isLogin", true);
                      await onLoginSuccess(context);
                    }
                    if (mounted) {
                      hideLoading();
                    }
                  });
                }
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
                  top: $(60),
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
                    SizedBox(width: 3.w),
                    TitleTextWidget(S.of(context).or, ColorConstant.loginTitleColor, FontWeight.w500, 12),
                    SizedBox(width: 3.w),
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
                      onAppleLogin();
                      break;
                    case ThirdPartAccount.google:
                      onGoogleLogin();
                      break;
                    case ThirdPartAccount.youtube:
                    case ThirdPartAccount.instagram:
                    case ThirdPartAccount.tiktok:
                      break;
                  }
                },
              ),
              SizedBox(height: $(30)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TitleTextWidget(S.of(context).no_account, ColorConstant.White, FontWeight.w400, 12),
                  Text(
                    S.of(context).sign_up,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ColorConstant.BlueColor, fontWeight: FontWeight.w500, fontFamily: 'Poppins', fontSize: 12, decoration: TextDecoration.underline),
                  ).intoGestureDetector(
                    onTap: () {
                      toSignUp(prefixPage, context);
                    },
                  ),
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

  void toSignUp(Object? prefixPage, BuildContext context) {
    GetStorage().write('signup_through', '');
    if (prefixPage == 'signup') {
      Navigator.pop(context);
    } else {
      cacheManager.setString(CacheManager.preSignupAction, 'from_login');
      Navigator.push<bool>(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: "/SignupScreen"),
          builder: (context) => SignupScreen(),
        ),
      ).then((value) {
        if (value ?? false) {
          Navigator.pop(context);
        }
      });
    }
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
          var action = AppDelegate.instance.getManager<CacheManager>().getString(CacheManager.preLoginAction);
          AppApi().onSignUp(email: onlineModel.user?.getShownEmail() ?? '').whenComplete(() {
            AppApi().identify(accountId: onlineModel.user?.id.toString() ?? '');
          });
          Events.loginSuccessShow(source: action);
          await loginBack(context);
        }
      });
    } else {
      var action = AppDelegate.instance.getManager<CacheManager>().getString(CacheManager.preLoginAction);
      Events.loginSuccessShow(source: action);
      await loginBack(context);
    }
  }
}
