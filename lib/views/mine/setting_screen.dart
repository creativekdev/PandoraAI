import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/app/user/widget/feedback_dialog.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../Widgets/dialog/dialog_widget.dart';
import '../ChangePasswordScreen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends AppState<SettingScreen> {
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();

  int totalSize = 0;

  bool get nsfwOpen => cacheManager.getBool(CacheManager.nsfwOpen);

  set nsfwOpen(bool value) {
    cacheManager.setBool(CacheManager.nsfwOpen, value);
  }

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
                launchURL("https://socialbook.io/privacy/cartoonizer");
              }),
              Container(width: double.maxFinite, height: 1, color: Color(0xff323232)).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                color: ColorConstant.BackgroundColor,
              ),
              functions(StringConstant.feedback, onTap: () {
                logEvent(Events.feed_back_loading);
                showDialog<bool>(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => FeedbackDialog(),
                );
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
                        cacheManager.storageOperator.clearDirectories([
                          cacheManager.storageOperator.videoDir,
                          cacheManager.storageOperator.imageDir,
                          cacheManager.storageOperator.tempDir,
                          cacheManager.storageOperator.pushDir,
                          cacheManager.storageOperator.recentDir,
                        ]).whenComplete(() {
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
              Container(width: double.maxFinite, height: 1, color: Color(0xff323232)).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                color: ColorConstant.BackgroundColor,
              ),
              functions('Scary content alert!',
                  training: FlutterSwitch(
                    value: nsfwOpen,
                    onToggle: (value) {
                      if (value) {
                        showOpenNsfwDialog(context).then((result) {
                          if (result ?? false) {
                            setState(() {
                              nsfwOpen = true;
                            });
                          }
                        });
                      } else {
                        setState(() {
                          nsfwOpen = value;
                        });
                      }
                    },
                    activeColor: ColorConstant.BlueColor,
                    inactiveColor: ColorConstant.EffectGrey,
                    width: $(50),
                    height: $(24),
                  ).intoContainer(margin: EdgeInsets.only(right: $(12)))),
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
                showLogoutAlertDialog().then((value) {
                  setState(() {});
                  if (value ?? false) {
                    userManager.doOnLogin(context);
                  }
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

  Future<bool?> showLogoutAlertDialog() async {
    return showDialog<bool>(
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
                Navigator.pop(context, false);
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
    var result = await CartoonizerApi().deleteAccount();
    if (result != null) {
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
