import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/EditProfileScreen.dart';
import 'package:cartoonizer/views/LoginScreen.dart';
import 'package:cartoonizer/views/discovery/user_discovery_screen.dart';
import 'package:cartoonizer/views/mine/setting_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';

import 'user_profile_screen.dart';
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
                    }).intoContainer(padding: EdgeInsets.only(left: $(16), right: $(16), top: $(54), bottom: $(16)), color: ColorConstant.BackgroundColor)
                  : UserBaseInfoWidget(userInfo: userManager.user!).intoGestureDetector(onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: RouteSettings(name: "/EditProfileScreen"),
                            builder: (context) => EditProfileScreen(),
                          ));
                    })),
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
                      builder: (context) => UserDiscoveryScreen(
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
            ],
          ).intoContainer(margin: EdgeInsets.only(bottom: AppTabBarHeight)),
        ).intoContainer(color: ColorConstant.MineBackgroundColor)),
      ],
    );
  }
}
