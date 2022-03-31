import 'dart:convert';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/utils.dart';
import 'package:cartoonizer/Model/UserModel.dart';
import 'package:cartoonizer/api.dart';
import 'package:http/http.dart';
import 'package:cartoonizer/config.dart';

import '../Common/Extension.dart';
import '../Common/sToken.dart';
import '../Model/JsonValueModel.dart';
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
    return Stack(
      children: [
        Image.asset(
          ImagesConstant.ic_background,
          fit: BoxFit.cover,
          height: 100.h,
          width: 100.w,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: LoadingOverlay(
              isLoading: isLoading,
              child: SingleChildScrollView(
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
                            margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => {Navigator.pop(context)},
                                  child: Image.asset(
                                    ImagesConstant.ic_back,
                                    height: 10.w,
                                    width: 10.w,
                                  ),
                                ),
                                TitleTextWidget(StringConstant.sign_up, ColorConstant.White, FontWeight.w600, 14.sp),
                                SizedBox(
                                  height: 10.w,
                                  width: 10.w,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TitleTextWidget(StringConstant.set_password, ColorConstant.TextBlack, FontWeight.w600, 16.sp),
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
                            Map<String, dynamic> tokenBody = {
                              "token": widget.token ?? "",
                              "password": passController.text,
                            };
                            final tokenResponse = await post(Uri.parse("${Config.instance.host}/password_reset"), body: tokenBody);
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

                              UserModel user = await API.getLogin(true);
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
                            Map<String, dynamic> lBody = {
                              "email": emailController.text,
                              "password": passController.text,
                              "channel": widget.channel,
                            };
                            final access_response = await post(Uri.parse("${Config.instance.apiHost}/user/signup_with_social_media"), headers: headers, body: lBody);
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

                              UserModel user = await API.getLogin(true);
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
                            List<JsonValueModel> params = [];
                            params.add(JsonValueModel("email", emailController.text));
                            params.add(JsonValueModel("Password", passController.text));
                            params.add(JsonValueModel("type", "app_cartoonizer"));
                            Map<String, dynamic> lBody = {"email": emailController.text, "Password": passController.text, "type": "app_cartoonizer", "s": sToken(params)};
                            final appleResponse = await post(Uri.parse("${Config.instance.apiHost}/user/signup/simple"), body: lBody);
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
                              await loginBack(context);
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
      ],
    );
  }
}
