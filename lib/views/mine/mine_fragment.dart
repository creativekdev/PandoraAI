import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/EditProfileScreen.dart';
import 'package:cartoonizer/views/LoginScreen.dart';
import 'package:cartoonizer/views/PurchaseScreen.dart';
import 'package:cartoonizer/views/StripeSubscriptionScreen.dart';
import 'package:cartoonizer/views/discovery/my_discovery_screen.dart';
import 'package:cartoonizer/views/mine/setting_screen.dart';
import 'package:share_plus/share_plus.dart';

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
    var lastTime = cacheManager.getInt('${CacheManager.keyLastTabAttached}_${tabId.id()}');
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - lastTime > 5000) {
      logEvent(Events.tab_me_loading);
    }
    cacheManager.setInt('${CacheManager.keyLastTabAttached}_${tabId.id()}', currentTime);
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
                  GetStorage().write('login_back_page', '/HomeScreen');
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(), settings: RouteSettings(name: "/LoginScreen"))).then((value) async {
                    // if (await _getIsLogin()) {
                    //   await API.getLogin(needLoad: true, context: context);
                    // }
                    setState(() {});
                  });
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
              ImageTextBarWidget(
                StringConstant.setting_my_discovery,
                Images.ic_setting_my_discovery,
                true,
              ).intoGestureDetector(onTap: () {
                logEvent(Events.open_my_discovery);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: "/UserDiscoveryScreen"),
                      builder: (context) => MyDiscoveryScreen(
                        userId: userManager.user!.id,
                        title: StringConstant.setting_my_discovery,
                      ),
                    )).then((value) async {
                  return;
                });
              }).offstage(offstage: userManager.isNeedLogin),
              Container(
                width: double.maxFinite,
                height: 1,
                color: Color(0xff323232),
              )
                  .intoContainer(
                    padding: EdgeInsets.symmetric(horizontal: $(15)),
                    color: ColorConstant.BackgroundColor,
                  )
                  .offstage(offstage: userManager.isNeedLogin),
              ImageTextBarWidget(StringConstant.share_app, ImagesConstant.ic_share_app, true).intoGestureDetector(onTap: () async {
                logEvent(Events.share_app);
                final box = context.findRenderObject() as RenderBox?;
                var appLink = Config.getStoreLink();
                await Share.share(appLink, sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
              }),
              Container(
                width: double.maxFinite,
                height: 1,
                color: Color(0xff323232),
              ).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                color: ColorConstant.BackgroundColor,
              ),
              ImageTextBarWidget(Platform.isAndroid ? StringConstant.rate_us1 : StringConstant.rate_us, ImagesConstant.ic_rate_us, true).intoGestureDetector(
                onTap: () async {
                  logEvent(Events.rate_us);
                  var url = Config.getStoreLink();
                  launchURL(url);
                },
              ),
              Container(
                width: double.maxFinite,
                height: 1,
                color: Color(0xff323232),
              ).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                color: ColorConstant.BackgroundColor,
              ),
              ImageTextBarWidget(StringConstant.premium, Images.ic_premium, true).intoGestureDetector(onTap: () {
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
              Container(height: $(12)),
              ImageTextBarWidget(StringConstant.settings, Images.ic_settings, true).intoGestureDetector(
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
        ).intoContainer(color: ColorConstant.MineBackgroundColor)),
      ],
    );
  }
}
