import 'dart:io';
import 'dart:ui';

import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/EditProfileScreen.dart';
import 'package:cartoonizer/views/ai/avatar/avatar.dart';
import 'package:cartoonizer/views/discovery/my_discovery_screen.dart';
import 'package:cartoonizer/views/effect/effect_recent_screen.dart';
import 'package:cartoonizer/views/mine/refcode/submit_invited_code_screen.dart';
import 'package:cartoonizer/views/mine/setting_screen.dart';
import 'package:cartoonizer/views/payment/payment.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../print/print_order_screen.dart';
import 'widget/user_base_info_widget.dart';

class MineFragment extends StatefulWidget {
  AppTabId tabId;

  MineFragment({Key? key, required this.tabId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MineFragmentState();
}

class MineFragmentState extends AppState<MineFragment> with AutomaticKeepAliveClientMixin, AppTabState {
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late AppTabId tabId;
  late StreamSubscription userLoginEventListener;
  late StreamSubscription userChangeEventListener;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'mine_fragment');
    tabId = widget.tabId;
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
  bool get wantKeepAlive => true;

  @override
  void onAttached() {
    super.onAttached();
    userManager.refreshUser();
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    cacheManager.setInt('${CacheManager.keyLastTabAttached}_${tabId.id()}', currentTime);
    EventBusHelper().eventBus.fire(OnHomeScrollEvent(data: false));
  }

  @override
  void onDetached() {
    super.onDetached();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: buildWidget(context),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Column(
      children: [
        AppNavigationBar(visible: false, backgroundColor: ColorConstant.BackgroundColor),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            children: [
              UserBaseInfoWidget(userInfo: userManager.user).intoGestureDetector(onTap: () {
                if (userManager.isNeedLogin) {
                  userManager.doOnLogin(context, logPreLoginAction: 'loginNormal', currentPageRoute: '/HomeScreen', callback: () {
                    EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.HOME.id()]));
                    setState(() {});
                  }, autoExec: true);
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(name: "/EditProfileScreen"),
                        builder: (context) => EditProfileScreen(),
                      ));
                }
              }),
              Container(height: $(12)),
              ImageTextBarWidget(S.of(context).ppmPro, Images.ic_premium, true).intoGestureDetector(onTap: () {
                AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
                PaymentUtils.pay(context, 'my_page').then((value) {
                  AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
                });
              }).offstage(offstage: userManager.isNeedLogin),
              line(context).offstage(offstage: userManager.isNeedLogin),
              ImageTextBarWidget(S.of(context).recently, Images.ic_recently, true, color: Color(0xfff95f5f)).intoGestureDetector(onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: "/EffectRecentScreen"),
                      builder: (context) => EffectRecentScreen(),
                    ));
              }),
              line(context),
              ImageTextBarWidget(
                S.of(context).setting_my_discovery,
                Images.ic_setting_my_discovery,
                true,
              ).intoGestureDetector(onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: "/UserDiscoveryScreen"),
                      builder: (context) => MyDiscoveryScreen(
                        userId: userManager.user!.id,
                        title: S.of(context).setting_my_discovery,
                      ),
                    )).then((value) async {
                  return;
                });
              }).offstage(offstage: userManager.isNeedLogin),
              line(context).offstage(offstage: userManager.isNeedLogin),
              ImageTextBarWidget(S.of(context).orders, Images.ic_my_orders, true, color: Color(0xfff95f5f)).intoGestureDetector(onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: "/PrintOrderScreen"),
                      builder: (context) => PrintOrderScreen(source: 'home_screen_mine'),
                    ));
              }).offstage(offstage: userManager.isNeedLogin),
              line(context).offstage(offstage: userManager.isNeedLogin),
              ImageTextBarWidget(S.of(context).share_app, ImagesConstant.ic_share_app, true).intoGestureDetector(onTap: () async {
                AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
                Events.shareApp();
                final box = context.findRenderObject() as RenderBox?;
                var file = File(cacheManager.storageOperator.tempDir.path + 'appQR.png');
                if (!file.existsSync()) {
                  var imageInfo = await SyncAssetImage(assets: Images.ic_share_app_image).getImage();
                  var byteData = await imageInfo.image.toByteData(format: ImageByteFormat.png);
                  file.writeAsBytes(byteData!.buffer.asUint8List());
                }
                await Share.shareXFiles([XFile(file.path)], subject: APP_TITLE, sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
                AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
              }),
              line(context),
              ImageTextBarWidget(Platform.isAndroid ? S.of(context).rate_us1 : S.of(context).rate_us, ImagesConstant.ic_rate_us, true).intoGestureDetector(
                onTap: () async {
                  AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
                  rateApp().then((value) {
                    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
                  });
                },
              ),
              line(context),
              ImageTextBarWidget((userManager.user?.isReferred ?? false) ? S.of(context).invited_code : S.of(context).input_invited_code, Images.ic_ref_code, true)
                  .intoGestureDetector(
                onTap: () {
                  SubmitInvitedCodeScreen.push(context);
                },
              ).offstage(offstage: userManager.isNeedLogin),
              line(context).offstage(offstage: userManager.isNeedLogin),
              ImageTextBarWidget('Pandora Avatar', Images.ic_avatar_ai, true).intoGestureDetector(
                onTap: () async {
                  Avatar.open(context, source: 'my_page');
                },
              ).visibility(visible: false),
              // line(context),
              Container(height: $(12)),
              ImageTextBarWidget(S.of(context).settings, Images.ic_settings, true).intoGestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(name: "/SettingScreen"),
                        builder: (context) => SettingScreen(),
                      ));
                },
              ),
              SizedBox(height: $(48)),
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
                    TitleTextWidget(S.of(context).connect_with_us, ColorConstant.BtnTextColor, FontWeight.w500, 12.sp),
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
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: $(25)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          launchURL("https://www.facebook.com/pandoraaiapp/");
                        },
                        child: Image.asset(
                          Images.ic_facebook,
                          width: double.maxFinite,
                        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(10))),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          launchURL("https://www.instagram.com/pandoraai.app/");
                        },
                        child: Image.asset(
                          Images.ic_share_instagram,
                          width: double.maxFinite,
                        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(10))),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          launchURL("https://twitter.com/PandoraAI_App");
                        },
                        child: Image.asset(
                          Images.ic_share_twitter,
                          width: double.maxFinite,
                        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(10))),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          launchURL("https://www.tiktok.com/@pandoraapp");
                        },
                        child: Image.asset(
                          Images.ic_share_tiktok,
                          width: double.maxFinite,
                        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(10))),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ).intoContainer(margin: EdgeInsets.only(bottom: AppTabBarHeight)),
        ).intoContainer(color: ColorConstant.MineBackgroundColor)),
      ],
    );
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

  Widget line(BuildContext context) => Container(
        width: double.maxFinite,
        height: 1,
        color: Color(0xff323232),
      ).intoContainer(
        padding: EdgeInsets.symmetric(horizontal: $(15)),
        color: ColorConstant.BackgroundColor,
      );
}
