import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache_manager.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/LoginScreen.dart';
import 'package:cartoonizer/views/discovery/user_discovery_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';

import 'ChangePasswordScreen.dart';
import 'EditProfileScreen.dart';
import 'PurchaseScreen.dart';
import 'StripeSubscriptionScreen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends AppState<SettingScreen> {
  UserManager userManager = AppDelegate.instance.getManager();
  late StreamSubscription userLoginEventListener;
  late StreamSubscription userChangeEventListener;

  @override
  void initState() {
    logEvent(Events.profile_page_loading);
    super.initState();
    userLoginEventListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      setState(() {});
    });
    userChangeEventListener = EventBusHelper().eventBus.on<UserInfoChangeEvent>().listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    userLoginEventListener.cancel();
    userChangeEventListener.cancel();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          (userManager.isNeedLogin
                  ? ButtonWidget(StringConstant.login).intoGestureDetector(onTap: () {
                      GetStorage().write('login_back_page', '/HomeScreen');
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(), settings: RouteSettings(name: "/LoginScreen"))).then((value) async {
                        // if (await _getIsLogin()) {
                        //   await API.getLogin(needLoad: true, context: context);
                        // }
                        setState(() {});
                        if (value != null) {}
                      });
                    })
                  : Row(
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
                                    imageUrl: userManager.user?.avatar ?? "",
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
                                TitleTextWidget(userManager.user?.email ?? '', Colors.white, FontWeight.w500, 12.sp, align: TextAlign.start),
                                TitleTextWidget(userManager.user?.name ?? '', Colors.white, FontWeight.w400, 12.sp, align: TextAlign.start),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ))
              .intoContainer(padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h)),
          ImageTextBarWidget(StringConstant.edit_profile, ImagesConstant.ic_edit_profile, false)
              .intoGestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: "/EditProfileScreen"),
                      builder: (context) => EditProfileScreen(),
                    )).then((value) async {
                  API.getLogin(needLoad: true);
                }),
              )
              .intoContainer(margin: EdgeInsets.only(top: 1.h))
              .offstage(offstage: userManager.isNeedLogin),
          ImageTextBarWidget(StringConstant.change_password, ImagesConstant.ic_change_password, false).intoGestureDetector(onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: "/ChangePasswordScreen"),
                  builder: (context) => ChangePasswordScreen(),
                ));
          }).offstage(offstage: userManager.isNeedLogin || userManager.user?.appleId != ""),
          ImageTextBarWidget(StringConstant.premium, ImagesConstant.ic_premium, false).intoGestureDetector(onTap: () {
            if (Platform.isIOS) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: "/PurchaseScreen"),
                  builder: (context) => PurchaseScreen(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: "/StripeSubscriptionScreen"),
                  builder: (context) => StripeSubscriptionScreen(),
                ),
              );
            }
          }).offstage(offstage: userManager.isNeedLogin),
          ImageTextBarWidget(StringConstant.setting_my_discovery, Images.ic_setting_my_discovery, false).intoGestureDetector(onTap: () {
            logEvent(Events.open_my_discovery);
            Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: "/UserDiscoveryScreen"),
                  builder: (context) => UserDiscoveryScreen(
                    userId: userManager.user!.id,
                    title: StringConstant.setting_my_discovery,
                  ),
                )).then((value) async {
              return;
            });
          }).offstage(offstage: userManager.isNeedLogin),
          ImageTextBarWidget(Platform.isAndroid ? StringConstant.rate_us1 : StringConstant.rate_us, ImagesConstant.ic_rate_us, false).intoGestureDetector(
            onTap: () async {
              logEvent(Events.rate_us);
              var url = Config.getStoreLink();
              launchURL(url);
            },
          ),
          ImageTextBarWidget(StringConstant.share_app, ImagesConstant.ic_share_app, false).intoGestureDetector(onTap: () async {
            logEvent(Events.share_app);
            final box = context.findRenderObject() as RenderBox?;
            var appLink = Config.getStoreLink();
            await Share.share(appLink, sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
          }),
          ImageTextBarWidget(StringConstant.help, ImagesConstant.ic_help, true).intoGestureDetector(onTap: () {
            logEvent(Events.open_help_center);
            launchURL("https://socialbook.io/help/");
          }),
          ImageTextBarWidget(StringConstant.term_condition, ImagesConstant.ic_term, true).intoGestureDetector(onTap: () {
            logEvent(Events.open_terms);
            launchURL("https://socialbook.io/terms");
          }),
          ImageTextBarWidget(StringConstant.privacy_policy1, ImagesConstant.ic_policy, true).intoGestureDetector(onTap: () {
            logEvent(Events.open_privacy);
            launchURL("https://socialbook.io/privacy");
          }),
          ImageTextBarWidget(StringConstant.setting_my_delete_account, Images.ic_setting_my_delete_account, false)
              .intoGestureDetector(
                  onTap: () => showDeleteAccountDialog(context).then((value) {
                        if (value ?? false) {
                          showLoading().whenComplete(() {
                            deleteAccount().then((value) {
                              hideLoading().whenComplete(() {
                                if (value) {
                                  showDeleteSuccessDialog(context);
                                }
                              });
                            });
                          });
                        }
                      }))
              .offstage(offstage: userManager.isNeedLogin),
          ImageTextBarWidget(StringConstant.logout, ImagesConstant.ic_logout, false)
              .intoGestureDetector(
                  onTap: () => showAlertDialog(context).whenComplete(() {
                        setState(() {});
                      }))
              .offstage(offstage: userManager.isNeedLogin),
          SizedBox(height: 2.h),
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
                SizedBox(width: 3.w),
                TitleTextWidget(StringConstant.connect_with_us, ColorConstant.BtnTextColor, FontWeight.w500, 12.sp),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    logEvent(Events.contact_socialmedia, eventValues: {"channel": "facebook"});
                    launchURL("https://www.facebook.com/SocialBook.io");
                  },
                  child: Image.asset(
                    ImagesConstant.ic_share_facebook,
                    height: 14.w,
                    width: 14.w,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    logEvent(Events.contact_socialmedia, eventValues: {"channel": "instagram"});
                    launchURL("https://www.instagram.com/socialbook.io/");
                  },
                  child: Image.asset(
                    ImagesConstant.ic_share_instagram,
                    height: 14.w,
                    width: 14.w,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    logEvent(Events.contact_socialmedia, eventValues: {"channel": "twitter"});
                    launchURL("https://twitter.com/SocialBookdotio");
                  },
                  child: Image.asset(
                    ImagesConstant.ic_share_twitter,
                    height: 14.w,
                    width: 14.w,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    logEvent(Events.contact_socialmedia, eventValues: {"channel": "tiktok"});
                    launchURL("https://tiktok.com/@socialbook.io");
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
      ).intoContainer(margin: EdgeInsets.only(bottom: AppTabBarHeight)),
    );
  }

  Future<void> showAlertDialog(BuildContext context) async {
    return showDialog(
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
                logEvent(Events.logout);
                await userManager.logout();
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

  Future<bool?> showDeleteAccountDialog(BuildContext context) => showDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
            content: Text(
              'Are you sure to delete your account?',
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'Poppins',
              ),
            ),
            actions: [
              CupertinoDialogAction(
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              CupertinoDialogAction(
                  child: Text(
                    'Delete',
                    style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins', color: Colors.red),
                  ),
                  onPressed: () async {
                    Navigator.pop(context, true);
                  }),
            ],
          ));

  Future<void> showDeleteSuccessDialog(BuildContext context) => showDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
            content: Text(
              'Your account has been successfully deleted. We always welcome you to use our service again.',
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'Poppins',
              ),
            ),
            actions: [
              CupertinoDialogAction(
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins', color: ColorConstant.BlueColor),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  }),
            ],
          ));

  Future<bool> deleteAccount() async {
    var post = await API.post("/api/user/delete_account");
    if (post.statusCode == 200) {
      logEvent(Events.delete_account);
      AppDelegate.instance.getManager<CacheManager>().clear();
      return true;
    }
    return false;
  }
}
