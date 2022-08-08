import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';

import '../ChangePasswordScreen.dart';
import '../PurchaseScreen.dart';
import '../StripeSubscriptionScreen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends AppState<SettingScreen> {
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();

  int totalSize = 0;

  @override
  void initState() {
    logEvent(Events.setting_page_loading);
    super.initState();
    getCacheSize();
  }

  Future<Null> getCacheSize() {
    return cacheManager.storageOperator.totalSize().then((value) {
      setState(() {
        totalSize = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstant.MineBackgroundColor,
        appBar: AppNavigationBar(backgroundColor: ColorConstant.BackgroundColor, middle: TitleTextWidget(StringConstant.settings, ColorConstant.White, FontWeight.w600, $(17))),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(height: $(12)),
              functions(StringConstant.change_password, onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: "/ChangePasswordScreen"),
                      builder: (context) => ChangePasswordScreen(),
                    ));
              }).offstage(offstage: userManager.user?.appleId != ""),
              Container(width: double.maxFinite, height: 1, color: Color(0xff323232))
                  .intoContainer(
                    padding: EdgeInsets.symmetric(horizontal: $(15)),
                    color: ColorConstant.BackgroundColor,
                  )
                  .offstage(offstage: userManager.user?.appleId != ""),
              functions(StringConstant.premium, onTap: () {
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
              Container(width: double.maxFinite, height: 1, color: Color(0xff323232))
                  .intoContainer(
                    padding: EdgeInsets.symmetric(horizontal: $(15)),
                    color: ColorConstant.BackgroundColor,
                  )
                  .offstage(offstage: userManager.isNeedLogin),
              functions(StringConstant.help, onTap: () {
                logEvent(Events.open_help_center);
                launchURL("https://socialbook.io/help/");
              }),
              Container(width: double.maxFinite, height: 1, color: Color(0xff323232)).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                color: ColorConstant.BackgroundColor,
              ),
              functions(StringConstant.term_condition, onTap: () {
                logEvent(Events.open_terms);
                launchURL("https://socialbook.io/terms");
              }),
              Container(width: double.maxFinite, height: 1, color: Color(0xff323232)).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                color: ColorConstant.BackgroundColor,
              ),
              functions(StringConstant.privacy_policy1, onTap: () {
                logEvent(Events.open_privacy);
                launchURL("https://socialbook.io/privacy");
              }),
              Container(width: double.maxFinite, height: 1, color: Color(0xff323232)).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                color: ColorConstant.BackgroundColor,
              ),
              functions(
                StringConstant.settingsClearCache,
                onTap: () {
                  if (totalSize == 0) {
                    return;
                  }
                  showClearCacheDialog().then((value) {
                    if (value ?? false) {
                      showLoading().whenComplete(() {
                        cacheManager.storageOperator.clearDirectory(cacheManager.storageOperator.videoDir).whenComplete(() {
                          hideLoading().whenComplete(() {
                            CommonExtension().showToast('Clear Success');
                            getCacheSize();
                          });
                        });
                      });
                    }
                  });
                },
                training: TitleTextWidget(
                  totalSize.fileSize,
                  ColorConstant.White,
                  FontWeight.normal,
                  $(13),
                ).marginOnly(right: $(15)),
              ),
              SizedBox(height: $(50)),
              TitleTextWidget(StringConstant.setting_my_delete_account, ColorConstant.White, FontWeight.normal, $(15))
                  .intoContainer(
                      width: double.maxFinite,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular($(6)), color: ColorConstant.BackgroundColor),
                      margin: EdgeInsets.only(left: $(15), right: $(15), top: $(20)),
                      padding: EdgeInsets.symmetric(vertical: $(10)))
                  .intoGestureDetector(onTap: () {
                showDeleteAccountDialog().then((value) {
                  if (value ?? false) {
                    showLoading().whenComplete(() {
                      deleteAccount().then((value) {
                        hideLoading().whenComplete(() {
                          if (value) {
                            showDeleteSuccessDialog();
                          }
                        });
                      });
                    });
                  }
                });
              }).offstage(offstage: userManager.isNeedLogin),
              TitleTextWidget(StringConstant.logout, ColorConstant.Red, FontWeight.normal, $(15))
                  .intoContainer(
                      width: double.maxFinite,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular($(6)), color: ColorConstant.BackgroundColor),
                      margin: EdgeInsets.only(left: $(15), right: $(15), top: $(20)),
                      padding: EdgeInsets.symmetric(vertical: $(10)))
                  .intoGestureDetector(onTap: () {
                showLogoutAlertDialog().whenComplete(() {
                  setState(() {});
                });
              }).offstage(offstage: userManager.isNeedLogin),
            ],
          ).intoContainer(margin: EdgeInsets.only(bottom: AppTabBarHeight)),
        ));
  }

  Widget functions(String title, {GestureTapCallback? onTap, Widget? training}) {
    if (training == null) {
      training = Image.asset(Images.ic_right_arrow, width: $(28));
    }
    return Row(
      children: [
        Expanded(
          child: TitleTextWidget(title, ColorConstant.White, FontWeight.w400, $(15)).intoContainer(alignment: Alignment.centerLeft),
        ),
        training,
      ],
    )
        .intoContainer(
          color: ColorConstant.BackgroundColor,
          padding: EdgeInsets.symmetric(vertical: $(10), horizontal: $(16)),
        )
        .intoGestureDetector(onTap: onTap);
  }

  Future<void> showLogoutAlertDialog() async {
    return showDialog(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Are you sure want to logout?',
            style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
            textAlign: TextAlign.center,
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
          Row(
            children: [
              Expanded(
                  child: Text(
                'Logout',
                style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.red),
              )
                      .intoContainer(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                            top: BorderSide(color: ColorConstant.LineColor, width: 1),
                            right: BorderSide(color: ColorConstant.LineColor, width: 1),
                          )))
                      .intoGestureDetector(onTap: () async {
                logEvent(Events.logout);
                await userManager.logout();
                Navigator.pop(context);
              })),
              Expanded(
                  child: Text(
                'Cancel',
                style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
              )
                      .intoContainer(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                            top: BorderSide(color: ColorConstant.LineColor, width: 1),
                          )))
                      .intoGestureDetector(onTap: () {
                Navigator.pop(context);
              })),
            ],
          ),
        ],
      )
          .intoMaterial(
            color: ColorConstant.EffectFunctionGrey,
            borderRadius: BorderRadius.circular($(16)),
          )
          .intoContainer(
            padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
            margin: EdgeInsets.symmetric(horizontal: $(35)),
          )
          .intoCenter(),
    );
  }

  Future<bool?> showDeleteAccountDialog() => showDialog<bool>(
        context: context,
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure to delete your account?',
              style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
              textAlign: TextAlign.center,
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
            Row(
              children: [
                Expanded(
                    child: Text(
                  'Delete',
                  style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.red),
                )
                        .intoContainer(
                            padding: EdgeInsets.all(10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border(
                              top: BorderSide(color: ColorConstant.LineColor, width: 1),
                              right: BorderSide(color: ColorConstant.LineColor, width: 1),
                            )))
                        .intoGestureDetector(onTap: () async {
                  Navigator.pop(context, true);
                })),
                Expanded(
                    child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
                )
                        .intoContainer(
                            padding: EdgeInsets.all(10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border(
                              top: BorderSide(color: ColorConstant.LineColor, width: 1),
                            )))
                        .intoGestureDetector(onTap: () {
                  Navigator.pop(context);
                })),
              ],
            ),
          ],
        )
            .intoMaterial(
              color: ColorConstant.EffectFunctionGrey,
              borderRadius: BorderRadius.circular($(16)),
            )
            .intoContainer(
              padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
              margin: EdgeInsets.symmetric(horizontal: $(35)),
            )
            .intoCenter(),
      );

  Future<void> showDeleteSuccessDialog() => showDialog<void>(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your account has been successfully deleted. We always welcome you to use our service again.',
              style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
              textAlign: TextAlign.center,
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
            Text(
              'OK',
              style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins', color: ColorConstant.BlueColor),
            )
                .intoContainer(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border(
                      top: BorderSide(color: ColorConstant.LineColor, width: 1),
                    )))
                .intoGestureDetector(onTap: () {
              Navigator.pop(context);
            }),
          ],
        )
            .intoMaterial(
              color: ColorConstant.EffectFunctionGrey,
              borderRadius: BorderRadius.circular($(16)),
            )
            .intoContainer(
              padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
              margin: EdgeInsets.symmetric(horizontal: $(35)),
            )
            .intoCenter(),
      );

  Future<bool> deleteAccount() async {
    var post = await API.post("/api/user/delete_account");
    if (post.statusCode == 200) {
      logEvent(Events.delete_account);
      userManager.logout();
      return true;
    }
    return false;
  }

  Future<bool?> showClearCacheDialog() => showDialog<bool>(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure to clear all cache?\n total: ${totalSize.fileSize}',
              style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
              textAlign: TextAlign.center,
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
            Row(
              children: [
                Expanded(
                    child: Text(
                  'Clear',
                  style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.red),
                )
                        .intoContainer(
                            padding: EdgeInsets.all(10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border(
                              top: BorderSide(color: ColorConstant.LineColor, width: 1),
                              right: BorderSide(color: ColorConstant.LineColor, width: 1),
                            )))
                        .intoGestureDetector(onTap: () async {
                  Navigator.pop(context, true);
                })),
                Expanded(
                    child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
                )
                        .intoContainer(
                            padding: EdgeInsets.all(10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border(
                              top: BorderSide(color: ColorConstant.LineColor, width: 1),
                            )))
                        .intoGestureDetector(onTap: () {
                  Navigator.pop(context);
                })),
              ],
            ),
          ],
        )
            .intoMaterial(
              color: ColorConstant.EffectFunctionGrey,
              borderRadius: BorderRadius.circular($(16)),
            )
            .intoContainer(
              padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
              margin: EdgeInsets.symmetric(horizontal: $(35)),
            )
            .intoCenter(),
      );
}
