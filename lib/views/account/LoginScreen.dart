import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/auth/auth.dart';
import 'package:cartoonizer/Widgets/auth/auth_api.dart';
import 'package:cartoonizer/Widgets/auth/sign_list_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/auth.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/EmailVerificationScreen.dart';
import 'package:cartoonizer/views/account/widget/icon_input.dart';
import 'package:common_utils/common_utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../ForgotPasswordScreen.dart';
import '../SignupScreen.dart';
import '../SocialSignUpScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();

  @override
  void initState() {
    super.initState();
    logEvent(Events.login_page_loading);
    thirdpartManager.adsHolder.ignore = true;
  }

  @override
  void dispose() {
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
            logEvent(Events.login, eventValues: {"method": "apple"});
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
                  logEvent(Events.login, eventValues: {"method": "google"});
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
        visible: false,
      ),
      body: Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(bottom: 2.h, left: $(30), right: $(30)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                StringConstant.welcomeBack,
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
                title: StringConstant.email,
                iconRes: Images.ic_email,
                controller: emailController,
                inputAction: TextInputAction.next,
                showClear: true,
              ),
              SizedBox(height: $(16)),
              iconInput(
                title: StringConstant.password,
                iconRes: Images.ic_password,
                passwordIcon: Images.ic_password_hide,
                plainIcon: Images.ic_password_show,
                controller: passController,
                inputAction: TextInputAction.done,
                passwordInput: true,
              ),
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
                    child: TitleTextWidget(StringConstant.forgot_password, ColorConstant.BlueColor, FontWeight.w400, 12),
                  ),
                ],
              ),
              SizedBox(height: $(40)),
              TitleTextWidget(StringConstant.log_in, ColorConstant.White, FontWeight.w500, $(16))
                  .intoContainer(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: $(10)),
                      decoration: BoxDecoration(
                        color: ColorConstant.DiscoveryBtn,
                        borderRadius: BorderRadius.circular($(8)),
                      ))
                  .intoGestureDetector(onTap: () async {
                if (emailController.text.trim().isEmpty) {
                  CommonExtension().showToast(StringConstant.email_validation);
                } else if (passController.text.trim().isEmpty) {
                  CommonExtension().showToast(StringConstant.pass_validation);
                } else if (!CommonExtension().isValidEmail(emailController.text.trim())) {
                  CommonExtension().showToast(StringConstant.email_validation1);
                } else {
                  FocusManager.instance.primaryFocus?.unfocus();
                  showLoading().whenComplete(() async {
                    var baseEntity = await userManager.login(emailController.text.trim(), passController.text.trim());
                    if (baseEntity != null) {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setBool("isLogin", true);
                      logEvent(Events.login, eventValues: {"method": "email"});
                      onLoginSuccess(context);
                    }
                    if (mounted) {
                      hideLoading();
                    }
                  });
                }
              }),
              Container(
                margin: EdgeInsets.only(
                  left: $(20),
                  right: $(20),
                  top: $(80),
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
                    TitleTextWidget(StringConstant.or, ColorConstant.loginTitleColor, FontWeight.w500, 12),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Divider(
                        color: ColorConstant.DividerColor,
                        thickness: 0.1.h,
                      ),
                    ),
                  ],
                ),
              ),
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
                  TitleTextWidget(StringConstant.no_account, ColorConstant.White, FontWeight.w400, 12),
                  Text(
                    StringConstant.sign_up,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ColorConstant.BlueColor, fontWeight: FontWeight.w500, fontFamily: 'Poppins', fontSize: 12, decoration: TextDecoration.underline),
                  ).intoGestureDetector(
                    onTap: () {
                      GetStorage().write('signup_through', '');
                      if (prefixPage == 'signup') {
                        Navigator.pop(context);
                      } else {
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
          await loginBack(context);
        }
      });
    } else {
      await loginBack(context);
    }
  }
}
