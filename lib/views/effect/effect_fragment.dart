import 'dart:io';
import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/badge.dart';
import 'package:cartoonizer/Widgets/indicator/line_tab_indicator.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/views/PurchaseScreen.dart';
import 'package:cartoonizer/views/StripeSubscriptionScreen.dart';
import 'package:cartoonizer/views/effect/effect_face_fragment.dart';
import 'package:cartoonizer/views/effect/effect_full_body_fragment.dart';
import 'package:cartoonizer/views/effect/effect_recent_screen.dart';
import 'package:cartoonizer/views/msg/msg_list_screen.dart';

class EffectFragment extends StatefulWidget {
  AppTabId tabId;

  EffectFragment({
    Key? key,
    required this.tabId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => EffectFragmentState();
}

class EffectFragmentState extends AppState<EffectFragment> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, AppTabState {
  final Connectivity _connectivity = Connectivity();
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  EffectDataController dataController = Get.put(EffectDataController());
  RecentController recentController = Get.put(RecentController());
  late AppTabId tabId;

  int currentIndex = 0;
  late PageController _pageController;
  late TabController _tabController;
  List<HomeTabConfig> tabConfig = [];
  late StreamSubscription onUserStateChangeListener;
  late StreamSubscription onUserLoginListener;
  bool proVisible = false;

  @override
  void initState() {
    super.initState();
    tabId = widget.tabId;
    _connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.mobile || event == ConnectivityResult.wifi /* || event == ConnectivityResult.none*/) {
        dataController.loadData();
        userManager.refreshUser();
        setState(() {});
      }
    });
    onUserStateChangeListener = EventBusHelper().eventBus.on<UserInfoChangeEvent>().listen((event) {
      refreshProVisible();
      setState(() {});
    });
    onUserLoginListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      refreshProVisible();
      setState(() {});
    });
    refreshProVisible();
  }

  @override
  void onAttached() {
    super.onAttached();
    var lastTime = cacheManager.getInt('${CacheManager.keyLastTabAttached}_${tabId.id()}');
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - lastTime > 5000) {
      logEvent(Events.tab_effect_loading);
    }
    cacheManager.setInt('${CacheManager.keyLastTabAttached}_${tabId.id()}', currentTime);
  }

  refreshProVisible() {
    if (userManager.isNeedLogin) {
      proVisible = true;
    } else {
      if (userManager.user!.userSubscription.isEmpty) {
        proVisible = true;
      } else {
        proVisible = false;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    onUserStateChangeListener.cancel();
  }

  void _pageChange(int index) {
    setState(() {
      if (currentIndex != index) {
        currentIndex = index;
        _tabController.index = currentIndex;
      }
    });
    var title = tabConfig[index].title;
    var lastTime = cacheManager.getInt('${CacheManager.keyLastEffectTabAttached}_${title}');
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - lastTime > 5000) {
      logEvent(Events.effect_child_tab_switch, eventValues: {
        'type': title,
      });
    }
    cacheManager.setInt('${CacheManager.keyLastEffectTabAttached}_${title}', currentTime);
  }

  void setIndex(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return super.build2(context);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return GetBuilder<EffectDataController>(
      init: dataController,
      builder: (_) {
        if (_.loading) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (_.data == null) {
            return FutureBuilder(
                future: getConnectionStatus(),
                builder: (context, snapshot1) {
                  return Center(
                    child: TitleTextWidget((snapshot1.hasData && (snapshot1.data as bool)) ? StringConstant.empty_msg : StringConstant.no_internet_msg, ColorConstant.BtnTextColor,
                        FontWeight.w400, 12.sp),
                  ).intoGestureDetector(onTap: () {
                    _.loadData();
                    userManager.refreshUser();
                  });
                });
          } else {
            recentController.updateOriginData(_.data!.allEffectList());
            tabConfig.clear();
            for (var value in _.data!.data.keys) {
              if (value == 'face') {
                tabConfig.add(
                  HomeTabConfig(
                    item: EffectFaceFragment(
                      tabId: tabId.id(),
                      dataList: _.data!.effectList(value),
                      recentController: recentController,
                      tabString: value,
                    ),
                    title: _.data!.localeName(value),
                  ),
                );
              } else if (value == 'full_body') {
                tabConfig.add(
                  HomeTabConfig(
                      item: EffectFullBodyFragment(
                        tabId: tabId.id(),
                        dataList: _.data!.effectList(value),
                        recentController: recentController,
                        tabString: value,
                      ),
                      title: _.data!.localeName(value)),
                );
              } else {
                tabConfig.add(
                  HomeTabConfig(
                    item: EffectFaceFragment(
                      tabId: tabId.id(),
                      dataList: _.data!.effectList(value),
                      recentController: recentController,
                      hasOriginalFace: false,
                      tabString: value,
                    ),
                    title: _.data!.localeName(value),
                  ),
                );
              }
            }
            _pageController = PageController(initialPage: currentIndex);
            _tabController = TabController(length: tabConfig.length, vsync: this, initialIndex: currentIndex);
            return Stack(
              children: [
                PageView.builder(
                  onPageChanged: _pageChange,
                  controller: _pageController,
                  itemBuilder: (BuildContext context, int index) {
                    return tabConfig[index].item;
                  },
                  itemCount: tabConfig.length,
                ),
                header(context),
              ],
            );
          }
        }
      },
    ).intoContainer(color: Colors.black);
  }

  Widget header(BuildContext context) => ClipRect(
          child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            navbar(context),
            SizedBox(height: $(10)),
            Theme(
                data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: LineTabIndicator(
                    width: $(20),
                    strokeCap: StrokeCap.butt,
                    borderSide: BorderSide(width: $(3), color: ColorConstant.BlueColor),
                  ),
                  isScrollable: tabConfig.length < 4,
                  labelColor: ColorConstant.PrimaryColor,
                  labelPadding: EdgeInsets.only(left: $(5), right: $(5)),
                  labelStyle: TextStyle(fontSize: $(14), fontWeight: FontWeight.bold),
                  unselectedLabelColor: ColorConstant.PrimaryColor,
                  unselectedLabelStyle: TextStyle(fontSize: $(14), fontWeight: FontWeight.w500),
                  controller: _tabController,
                  onTap: (index) {
                    setIndex(index);
                  },
                  tabs: tabConfig.map((e) => Text(e.title).intoContainer(padding: EdgeInsets.symmetric(vertical: $(8), horizontal: $(4)))).toList(),
                ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(12)))),
            SizedBox(height: $(8)),
          ],
        ).intoContainer(color: ColorConstant.BackgroundColorBlur).intoGestureDetector(
            onTap: () {},
            onDoubleTap: Platform.isIOS
                ? () {
                    EventBusHelper().eventBus.fire(OnTabDoubleClickEvent(data: tabId.id()));
                  }
                : null),
      ));

  Widget navbar(BuildContext context) => Container(
        // margin: EdgeInsets.only(top: $(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppNavigationBar(
              backgroundColor: Colors.transparent,
              showBackItem: false,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    StringConstant.pro,
                    style: TextStyle(fontSize: $(14), color: Color(0xffffffff), fontWeight: FontWeight.w700),
                  )
                      .intoContainer(
                          width: $(45),
                          padding: EdgeInsets.symmetric(vertical: $(4)),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular($(6)),
                            gradient: LinearGradient(
                              colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ))
                      .intoGestureDetector(onTap: () {
                    userManager.doOnLogin(context, callback: () {
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
                    });
                  }),
                ],
              ).intoContainer(margin: EdgeInsets.only(left: $(4))).offstage(offstage: !proVisible),
              middle: TitleTextWidget(StringConstant.home, ColorConstant.BtnTextColor, FontWeight.w600, $(18)),
              trailing: Obx(() => BadgeView(
                    type: BadgeType.fill,
                    count: AppDelegate.instance.getManager<MsgManager>().unreadCount.value,
                    child: Image.asset(
                      Images.ic_msg_icon,
                      width: $(26),
                      color: Colors.white,
                    ),
                  )).intoContainer(padding: EdgeInsets.all(4)).intoGestureDetector(onTap: () {
                userManager.doOnLogin(context, callback: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: "/MsgListScreen"),
                      builder: (context) => MsgListScreen(),
                    ),
                  );
                }, autoExec: true);
              }),
            ),
          ],
        ),
      );

  Future<bool> getConnectionStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return (connectivityResult != ConnectivityResult.none);
  }

  @override
  bool get wantKeepAlive => true;
}
