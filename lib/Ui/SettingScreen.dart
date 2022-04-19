import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/utils.dart';
import 'package:cartoonizer/Model/UserModel.dart';
import 'package:cartoonizer/Ui/LoginScreen.dart';
import 'package:cartoonizer/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cartoonizer/api.dart';

import 'ChangePasswordScreen.dart';
import 'EditProfileScreen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late SharedPreferences sharedPrefs;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => {Navigator.pop(context)},
                    child: Image.asset(
                      ImagesConstant.ic_back_dark,
                      height: 10.w,
                      width: 10.w,
                    ),
                  ),
                  TitleTextWidget(StringConstant.setting, ColorConstant.BtnTextColor, FontWeight.w600, 14.sp),
                  SizedBox(
                    height: 10.w,
                    width: 10.w,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                      child: FutureBuilder(
                        future: _getIsLogin(),
                        builder: (context, snapshot) {
                          if (((snapshot.data != null ? snapshot.data as bool : true) || isLoading)) {
                            return FutureBuilder(
                              future: API.getLogin(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  return Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Image.asset(
                                            ImagesConstant.ic_ring,
                                            width: 25.w,
                                            height: 25.w,
                                          ),
                                          Positioned(
                                            top: 5.w,
                                            left: 5.w,
                                            child: SimpleShadow(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(15.w),
                                                child: CachedNetworkImage(
                                                  imageUrl: (snapshot.hasData) ? (snapshot.data as UserModel).avatar : "",
                                                  fit: BoxFit.fill,
                                                  width: 15.w,
                                                  height: 15.w,
                                                  placeholder: (context, url) {
                                                    return Image.asset(
                                                      ImagesConstant.ic_demo1,
                                                      fit: BoxFit.fill,
                                                      width: 15.w,
                                                      height: 15.w,
                                                    );
                                                  },
                                                  errorWidget: (context, url, error) {
                                                    return Image.asset(
                                                      ImagesConstant.ic_demo1,
                                                      fit: BoxFit.fill,
                                                      width: 15.w,
                                                      height: 15.w,
                                                    );
                                                  },
                                                ),
                                              ),
                                              sigma: 5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              TitleTextWidget((snapshot.hasData) ? (snapshot.data as UserModel).email : "", ColorConstant.TextBlack, FontWeight.w500, 12.sp,
                                                  align: TextAlign.start),
                                              TitleTextWidget((snapshot.hasData) ? (snapshot.data as UserModel).name : "", ColorConstant.LightTextColor, FontWeight.w400, 12.sp,
                                                  align: TextAlign.start),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            );
                          } else {
                            return GestureDetector(
                              onTap: () => {
                                GetStorage().write('login_back_page', '/SettingScreen'),
                                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(), settings: RouteSettings(name: "/LoginScreen"))).then((value) async {
                                  if (await _getIsLogin()) {
                                    API.getLogin(needLoad: true, context: context);
                                    setState(() {
                                      isLoading = true;
                                    });
                                  }

                                  if (value != null) {}
                                })
                              },
                              child: ButtonWidget(StringConstant.login),
                            );
                          }
                        },
                      ),
                    ),
                    FutureBuilder(
                      future: _getIsLogin(),
                      builder: (context, snapshot) {
                        if (((snapshot.data != null ? snapshot.data as bool : true) || isLoading)) {
                          return Column(
                            children: [
                              SizedBox(
                                height: 1.h,
                              ),
                              GestureDetector(
                                onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        settings: RouteSettings(name: "/EditProfileScreen"),
                                        builder: (context) => EditProfileScreen(),
                                      )).then((value) async {
                                    API.getLogin(needLoad: true);
                                    if (value != null) {
                                      setState(() {
                                        isLoading = value as bool;
                                      });
                                    }
                                  })
                                },
                                child: ImageTextBarWidget(StringConstant.edit_profile, ImagesConstant.ic_edit_profile, false),
                              ),
                            ],
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                    FutureBuilder(
                      future: _getIsLogin(),
                      builder: (context, snapshot) {
                        if (((snapshot.data != null ? snapshot.data as bool : true) || isLoading)) {
                          return FutureBuilder(
                              future: API.getLogin(),
                              builder: (context, snapshot) {
                                var user = snapshot.hasData ? (snapshot.data as UserModel) : null;
                                if (user?.apple_id == "") {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      GestureDetector(
                                        onTap: () => {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                settings: RouteSettings(name: "/ChangePasswordScreen"),
                                                builder: (context) => ChangePasswordScreen(),
                                              )).then((value) async {
                                            _getIsLogin();
                                            if (value != null) {
                                              setState(() {
                                                isLoading = value as bool;
                                              });
                                            }
                                          })
                                        },
                                        child: ImageTextBarWidget(StringConstant.change_password, ImagesConstant.ic_change_password, false),
                                      ),
                                    ],
                                  );
                                } else {
                                  return SizedBox();
                                }
                              });
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        var url = Config.getStoreLink();
                        _launchURL(url);
                      },
                      child: ImageTextBarWidget(Platform.isAndroid ? StringConstant.rate_us1 : StringConstant.rate_us, ImagesConstant.ic_rate_us, false),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final box = context.findRenderObject() as RenderBox?;
                        var appLink = Config.getStoreLink();
                        await Share.share(appLink, sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
                      },
                      child: ImageTextBarWidget(StringConstant.share_app, ImagesConstant.ic_share_app, false),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        _launchURL("https://socialbook.io/help/");
                      },
                      child: ImageTextBarWidget(StringConstant.help, ImagesConstant.ic_help, true),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        _launchURL("https://socialbook.io/terms");
                      },
                      child: ImageTextBarWidget(StringConstant.term_condition, ImagesConstant.ic_term, true),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        _launchURL("https://socialbook.io/privacy");
                      },
                      child: ImageTextBarWidget(StringConstant.privacy_policy1, ImagesConstant.ic_policy, true),
                    ),
                    FutureBuilder(
                      future: _getIsLogin(),
                      builder: (context, snapshot) {
                        if (((snapshot.data != null ? snapshot.data as bool : true) || isLoading)) {
                          return Column(
                            children: [
                              SizedBox(
                                height: 2.h,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  showAlertDialog(context);
                                },
                                child: ImageTextBarWidget(StringConstant.logout, ImagesConstant.ic_logout, false),
                              ),
                            ],
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
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
                          TitleTextWidget(StringConstant.connect_with_us, ColorConstant.BtnTextColor, FontWeight.w500, 12.sp),
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.5.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              _launchURL("https://www.facebook.com/SocialBook.io");
                            },
                            child: Image.asset(
                              ImagesConstant.ic_share_facebook,
                              height: 14.w,
                              width: 14.w,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              _launchURL("https://www.instagram.com/socialbook.io/");
                            },
                            child: Image.asset(
                              ImagesConstant.ic_share_instagram,
                              height: 14.w,
                              width: 14.w,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              _launchURL("https://twitter.com/SocialBookdotio");
                            },
                            child: Image.asset(
                              ImagesConstant.ic_share_twitter,
                              height: 14.w,
                              width: 14.w,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              _launchURL("https://tiktok.com/@socialbook.io");
                            },
                            child: Image.asset(
                              ImagesConstant.ic_share_tiktok,
                              height: 14.w,
                              width: 14.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        content: Text(
          'Are you sure want to logout?',
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          CupertinoDialogAction(
              child: Text(
                'Logout',
                style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins', color: Colors.red),
              ),
              onPressed: () async {
                var sharedPrefs = await SharedPreferences.getInstance();
                sharedPrefs.clear();
                Navigator.pop(context);
                Navigator.pop(context);
              }),
          CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }

  Future<bool> _getIsLogin() async {
    sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getBool("isLogin") ?? false;
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
