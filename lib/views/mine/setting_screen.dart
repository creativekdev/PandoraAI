import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/mine/submit_invited_code_screen.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:cartoonizer/app/user/widget/feedback_dialog.dart';
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

  late StreamSubscription onUserChangeListen;
  late StreamSubscription onLoginStateChangeListen;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'setting_screen');
    onUserChangeListen = EventBusHelper().eventBus.on<UserInfoChangeEvent>().listen((event) {
      setState(() {});
    });
    onLoginStateChangeListen = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      setState(() {});
    });
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
    onUserChangeListen.cancel();
    onLoginStateChangeListen.cancel();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstant.MineBackgroundColor,
        appBar: AppNavigationBar(backgroundColor: ColorConstant.BackgroundColor, middle: TitleTextWidget(S.of(context).settings, ColorConstant.White, FontWeight.w600, $(17))),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(height: $(12)),
              functions(S.of(context).change_password, onTap: () {
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
              functions(S.of(context).input_invited_code, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SubmitInvitedCodeScreen()));
              }).offstage(
                offstage: userManager.isNeedLogin || (userManager.user?.isReferred ?? false),
              ),
              Container(width: double.maxFinite, height: 1, color: Color(0xff323232))
                  .intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15)), color: ColorConstant.BackgroundColor)
                  .offstage(
                    offstage: userManager.isNeedLogin || (userManager.user?.isReferred ?? false),
                  ),
              functions(S.of(context).help, onTap: () {
                launchURL("https://socialbook.io/help/");
              }),
              Container(width: double.maxFinite, height: 1, color: Color(0xff323232)).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                color: ColorConstant.BackgroundColor,
              ),
              functions(S.of(context).term_condition, onTap: () {
                launchURL("https://socialbook.io/terms");
              }),
              Container(width: double.maxFinite, height: 1, color: Color(0xff323232)).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                color: ColorConstant.BackgroundColor,
              ),
              functions(S.of(context).privacy_policy1, onTap: () {
                launchURL("https://socialbook.io/privacy/cartoonizer");
              }),
              Container(width: double.maxFinite, height: 1, color: Color(0xff323232)).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                color: ColorConstant.BackgroundColor,
              ),
              functions(S.of(context).feedback, onTap: () {
                FeedbackUtils.open(context);
              }),
              Container(width: double.maxFinite, height: 1, color: Color(0xff323232)).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                color: ColorConstant.BackgroundColor,
              ),
              functions(
                S.of(context).settingsClearCache,
                onTap: () {
                  if (totalSize == 0) {
                    return;
                  }
                  showClearCacheDialog().then((value) {
                    if (value ?? false) {
                      showLoading().whenComplete(() {
                        cacheManager.setJson(CacheManager.photoSourceFace, null);
                        cacheManager.setJson(CacheManager.photoSourceOther, null);
                        cacheManager.storageOperator.clearDirectories([
                          cacheManager.storageOperator.videoDir,
                          cacheManager.storageOperator.imageDir,
                          cacheManager.storageOperator.tempDir,
                          cacheManager.storageOperator.pushDir,
                          cacheManager.storageOperator.recentDir,
                        ]).whenComplete(() {
                          EventBusHelper().eventBus.fire(OnClearCacheEvent());
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
              functions(
                S.of(context).current_version,
                training: FutureBuilder<String>(
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return TitleTextWidget(
                          snapshot.data ?? '',
                          ColorConstant.White,
                          FontWeight.normal,
                          $(13),
                        ).marginOnly(right: $(15));
                      }
                      return SizedBox.shrink();
                    },
                    future: appVersion()),
              ),
              Container(width: double.maxFinite, height: 1, color: Color(0xff323232)).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                color: ColorConstant.BackgroundColor,
              ),
              functions(S.of(context).scary_content_alert,
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
                      ).intoContainer(margin: EdgeInsets.only(right: $(12))))
                  .visibility(visible: false),
              SizedBox(height: $(35)),
              TitleTextWidget(S.of(context).logout, ColorConstant.Red, FontWeight.normal, $(18))
                  .intoContainer(
                      width: double.maxFinite,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular($(6)), color: ColorConstant.BackgroundColor),
                      margin: EdgeInsets.only(left: $(15), right: $(15), top: $(20)),
                      padding: EdgeInsets.symmetric(vertical: $(10)))
                  .intoGestureDetector(onTap: () {
                showLogoutAlertDialog().then((value) {
                  setState(() {});
                  if (value ?? false) {
                    userManager.doOnLogin(context, logPreLoginAction: 'logout_after');
                  }
                });
              }).offstage(offstage: userManager.isNeedLogin),
              SizedBox(height: $(10)),
              TitleTextWidget(S.of(context).setting_my_delete_account, ColorConstant.White, FontWeight.normal, $(15))
                  .intoContainer(
                      width: double.maxFinite,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular($(6)), color: Colors.transparent),
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
            ],
          ).intoContainer(margin: EdgeInsets.only(bottom: AppTabBarHeight)),
        ));
  }

  Future<String> appVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version} (${packageInfo.buildNumber})';
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
            S.of(context).logout_tips,
            style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
            textAlign: TextAlign.center,
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
          Row(
            children: [
              Expanded(
                  child: Text(
                S.of(context).logout,
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
                await userManager.logout();
                Navigator.pop(context, true);
              })),
              Expanded(
                  child: Text(
                S.of(context).cancel,
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
              S.of(context).delete_account_tips,
              style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
              textAlign: TextAlign.center,
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
            Row(
              children: [
                Expanded(
                    child: Text(
                  S.of(context).delete,
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
                  S.of(context).cancel,
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
              S.of(context).delete_account_successfully_tips,
              style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
              textAlign: TextAlign.center,
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
            Text(
              S.of(context).ok,
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
              S.of(context).clear_cache_tips.replaceAll('%d', '${totalSize.fileSize}'),
              style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
              textAlign: TextAlign.center,
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
            Row(
              children: [
                Expanded(
                    child: Text(
                  S.of(context).clear,
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
                  S.of(context).cancel,
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
