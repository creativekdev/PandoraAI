import 'dart:convert';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/models/UserModel.dart';
import 'package:cartoonizer/api/api.dart';

import '../common/Extension.dart';
import './EmailVerificationScreen.dart';

class SocialSignUpScreen extends StatefulWidget {
  final additionalUserInfo;
  final token, tokenId, channel;

  const SocialSignUpScreen({Key? key, required this.additionalUserInfo, required this.token, required this.tokenId, required this.channel}) : super(key: key);

  @override
  _SocialSignUpScreenState createState() => _SocialSignUpScreenState();
}

class _SocialSignUpScreenState extends State<SocialSignUpScreen> {
  bool isShow = true;
  bool isLoading = false;
  final emailController = TextEditingController();
  final passController = TextEditingController();
  UserManager userManager = AppDelegate.instance.getManager();

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.additionalUserInfo != null && widget.channel != 'tiktok') {
      emailController.text = widget.additionalUserInfo.profile!['email'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BlueColor,
      body: LoadingOverlay(
        isLoading: isLoading,
        child: SafeArea(
          // top:false,
          bottom: false,
          child: Container(
            height: 100.h,
            color: ColorConstant.BackgroundColor,
            child: SingleChildScrollView(
              child: Container(
                color: ColorConstant.BackgroundColor,
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
                            margin: EdgeInsets.only(top: 14.5.h),
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
                          Container(
                            margin: EdgeConstants.TopBarEdgeInsets,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => {Navigator.pop(context)},
                                  child: Image.asset(
                                    ImagesConstant.ic_back,
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                                TitleTextWidget(StringConstant.sign_up, ColorConstant.White, FontWeight.w600, FontSizeConstants.topBarTitle),
                                SizedBox(
                                  height: 30,
                                  width: 30,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TitleTextWidget(StringConstant.set_password, ColorConstant.White, FontWeight.w600, 20),
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
                    SizedBox(
                      height: 1.5.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (emailController.text.trim().isEmpty) {
                          CommonExtension().showToast(StringConstant.email_validation);
                        } else if (!CommonExtension().isValidEmail(emailController.text.trim())) {
                          CommonExtension().showToast(StringConstant.email_validation1);
                        } else if (passController.text.trim().isEmpty) {
                          CommonExtension().showToast(StringConstant.pass_validation);
                        } else {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            isLoading = true;
                          });
                          if (widget.channel == "google") {
                            Map<String, String> tokenBody = {
                              "token": widget.token ?? "",
                              "password": passController.text,
                            };
                            final tokenResponse = await API.post("/password_reset", body: tokenBody);
                            print(tokenResponse.body);
                            setState(() {
                              isLoading = false;
                            });
                            if (tokenResponse.statusCode == 200) {
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

                              UserModel user = await API.getLogin(needLoad: true);
                              logEvent(Events.signup, eventValues: {"method": "google", "signup_through": GetStorage().read('signup_through') ?? ""});

                              if (user.status != "activated") {
                                Navigator.pushReplacement<void, void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) => EmailVerificationScreen(emailController.text),
                                  ),
                                );
                              } else {
                                await loginBack(context);
                              }
                            }
                          } else if (widget.channel == "youtube" || widget.channel == "instagram" || (widget.channel == "tiktok" && widget.additionalUserInfo['no_post'] != true)) {
                            final headers = {"cookie": "bst_social_signup=${widget.tokenId}"};
                            Map<String, String> body = {
                              "email": emailController.text,
                              "password": passController.text,
                              "channel": widget.channel ?? "",
                              "type": APP_TYPE,
                            };
                            final access_response = await API.post("/api/user/signup_with_social_media", headers: headers, body: body);

                            print(access_response.statusCode);
                            print(access_response.body);
                            setState(() {
                              isLoading = false;
                            });
                            if (access_response.statusCode == 200) {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String cookie = access_response.headers.toString();
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

                              UserModel user = await API.getLogin(needLoad: true);

                              logEvent(Events.signup, eventValues: {"method": widget.channel, "signup_through": GetStorage().read('signup_through') ?? ""});
                              if (user.status != "activated") {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => EmailVerificationScreen(emailController.text),
                                  ),
                                );
                              }

                              // await loginBack(context);
                            } else {
                              final Map parsed = json.decode(access_response.body.toString());
                              CommonExtension().showToast(parsed['message']);
                            }
                          } else if (widget.channel == "tiktok" && widget.additionalUserInfo['no_post'] == true) {
                            setState(() {
                              isLoading = true;
                            });
                            Map<String, String> body = {"email": emailController.text, "password": passController.text, "type": APP_TYPE};
                            final appleResponse = await API.post("/api/user/signup/simple", body: body);

                            setState(() {
                              isLoading = false;
                            });
                            if (appleResponse.statusCode == 200) {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String cookie = appleResponse.headers.toString();
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

                              logEvent(Events.signup, eventValues: {"method": widget.channel, "signup_through": GetStorage().read('signup_through') ?? ""});
                            } else {
                              final Map parsed = json.decode(appleResponse.body.toString());
                              CommonExtension().showToast(parsed['message']);
                            }
                          }
                        }
                      },
                      child: ButtonWidget(StringConstant.sign_up),
                    ),
                    SizedBox(
                      height: 1.5.h,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
