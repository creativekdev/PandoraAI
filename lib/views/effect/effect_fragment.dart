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
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/views/PurchaseScreen.dart';
import 'package:cartoonizer/views/StripeSubscriptionScreen.dart';
import 'package:cartoonizer/views/ai/avatar/avatar.dart';
import 'package:cartoonizer/views/effect/effect_face_fragment.dart';
import 'package:cartoonizer/views/effect/effect_full_body_fragment.dart';
import 'package:cartoonizer/views/effect/effect_random_fragment.dart';
import 'package:cartoonizer/views/effect/effect_tab_state.dart';
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

class EffectFragmentState extends State<EffectFragment> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, AppTabState, EffectTabState {
  final Connectivity _connectivity = Connectivity();
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  EffectDataController dataController = Get.find();
  RecentController recentController = Get.find();
  late AppTabId tabId;

  int currentIndex = 0;
  PageController? _pageController;
  TabController? _tabController;
  List<HomeTabConfig> tabConfig = [];
  late StreamSubscription onUserStateChangeListener;
  late StreamSubscription onUserLoginListener;
  late StreamSubscription onPushDataListener;
  bool proVisible = false;
  double headerHeight = 0;
  bool hasHashTag = false;
  bool hashTagBlurOpen = false;
  int? selectedTagIndex;

  String? get selectedTag => selectedTagIndex == null ? null : dataController.tagList[selectedTagIndex!];

  setSelectedTagIndex(int? index) {
    setState(() {
      if (index == null) {
        selectedTagIndex = null;
      } else {
        selectedTagIndex = index;
      }
    });
    EventBusHelper().eventBus.fire(OnHashTagChangeEvent(data: selectedTag));
  }

  @override
  void initState() {
    super.initState();
    tabId = widget.tabId;
    _connectivity.onConnectivityChanged.listen((event) {
      if (!mounted) return;
      if (event == ConnectivityResult.mobile || event == ConnectivityResult.wifi /* || event == ConnectivityResult.none*/) {
        if (dataController.data == null) {
          dataController.loadData();
        }
      }
    });
    onUserStateChangeListener = EventBusHelper().eventBus.on<UserInfoChangeEvent>().listen((event) {
      if (!mounted) return;
      setState(() {
        refreshProVisible();
      });
    });
    onUserLoginListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (!mounted) return;
      setState(() {
        refreshProVisible();
      });
    });
    onPushDataListener = EventBusHelper().eventBus.on<OnEffectPushClickEvent>().listen((event) {
      if (!mounted) return;
      var pushExtraEntity = event.data!;
      for (int i = 0; i < tabConfig.length; i++) {
        var config = tabConfig[i];
        if (config.tabString == pushExtraEntity.tab) {
          _tabController?.index = i;
          setIndex(i);
          onEffectClick(pushExtraEntity);
        }
      }
    });
    refreshProVisible();
  }

  @override
  void onAttached() {
    super.onAttached();
    if (tabConfig.isNotEmpty) {
      tabConfig[currentIndex].key.currentState?.onAttached();
    }
    var lastTime = cacheManager.getInt('${CacheManager.keyLastTabAttached}_${tabId.id()}');
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - lastTime > 5000) {
      logEvent(Events.tab_effect_loading);
    }
    cacheManager.setInt('${CacheManager.keyLastTabAttached}_${tabId.id()}', currentTime);
  }

  @override
  void onDetached() {
    super.onDetached();
    if (tabConfig.isNotEmpty) {
      tabConfig[currentIndex].key.currentState?.onDetached();
    }
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
    _pageController?.dispose();
    _tabController?.dispose();
    onUserStateChangeListener.cancel();
  }

  void _pageChange(int index) {
    if (currentIndex != index) {
      currentIndex = index;
      for (var i = 0; i < tabConfig.length; i++) {
        var key = tabConfig[i].key;
        if (i == currentIndex) {
          if (tabConfig[i].tabString == 'template') {
            openHashTagBlur();
          }
          key.currentState?.onAttached();
        } else {
          if (tabConfig[i].tabString == 'template') {
            hideHashTagBlur();
          }
          key.currentState?.onDetached();
        }
      }
    }
    _tabController?.index = currentIndex;
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
    if (currentIndex != index) {
      _pageController?.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  openHashTagBlur() {
    if (hasHashTag && !hashTagBlurOpen) {
      setState(() {
        hashTagBlurOpen = true;
      });
    }
  }

  hideHashTagBlur() {
    if (hashTagBlurOpen) {
      setState(() {
        hashTagBlurOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            hasHashTag = !dataController.tagList.isEmpty;
            for (var value in _.data!.data.keys) {
              var key = GlobalKey<AppTabState>();
              if (value == 'face') {
                tabConfig.add(
                  HomeTabConfig(
                    key: key,
                    item: EffectFaceFragment(
                      key: key,
                      tabId: tabId.id(),
                      dataList: _.data!.effectList(value),
                      recentController: recentController,
                      tabString: value,
                      headerHeight: headerHeight,
                    ),
                    title: _.data!.localeName(value),
                    tabString: value,
                  ),
                );
              } else if (value == 'full_body') {
                tabConfig.add(
                  HomeTabConfig(
                    key: key,
                    item: EffectFullBodyFragment(
                      key: key,
                      tabId: tabId.id(),
                      dataList: _.data!.effectList(value),
                      recentController: recentController,
                      tabString: value,
                      headerHeight: headerHeight,
                    ),
                    title: _.data!.localeName(value),
                    tabString: value,
                  ),
                );
              } else if (value == 'template') {
                tabConfig.add(HomeTabConfig(
                  key: key,
                  item: EffectRandomFragment(
                    key: key,
                    tabString: value,
                    tabId: tabId.id(),
                    recentController: recentController,
                    dataController: dataController,
                    headerHeight: headerHeight,
                    selectedTag: selectedTag,
                  ),
                  title: _.data!.localeName(value),
                  tabString: value,
                ));
              } else {
                tabConfig.add(
                  HomeTabConfig(
                    key: key,
                    item: EffectFaceFragment(
                      key: key,
                      tabId: tabId.id(),
                      dataList: _.data!.effectList(value),
                      recentController: recentController,
                      hasOriginalFace: false,
                      tabString: value,
                      headerHeight: headerHeight,
                    ),
                    title: _.data!.localeName(value),
                    tabString: value,
                  ),
                );
              }
            }
            _pageController = PageController(initialPage: currentIndex, keepPage: true);
            _tabController = TabController(length: tabConfig.length, vsync: this, initialIndex: currentIndex);
            hashTagBlurOpen = tabConfig[currentIndex].tabString == 'template';
            return Stack(
              children: [
                PageView(
                  onPageChanged: _pageChange,
                  controller: _pageController,
                  children: tabConfig.map((e) => e.item).toList(),
                ),
                header(context),
                Positioned(
                  child: ClipRect(
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: TitleTextWidget('Pandora Avatar', ColorConstant.White, FontWeight.w500, $(17))
                              .intoContainer(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: ColorConstant.BlueColor, borderRadius: BorderRadius.circular($(6))),
                                  height: $(44),
                                  width: ScreenUtil.screenSize.width - $(30),
                                  padding: EdgeInsets.symmetric(vertical: $(8)),
                                  margin: EdgeInsets.only(left: $(15), right: $(15), top: $(12))).intoGestureDetector(onTap: (){
                                    Avatar.openFromHome(context);
                          })
                              .intoContainer(
                                  height: $(56),
                                  margin: EdgeInsets.only(bottom: AppTabBarHeight + MediaQuery.of(context).padding.bottom),
                                  color: ColorConstant.BackgroundColorBlur))),
                  bottom: 0,
                ),
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
            Column(
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
                      isScrollable: tabConfig.length > 4,
                      labelColor: ColorConstant.PrimaryColor,
                      labelPadding: EdgeInsets.symmetric(horizontal: 0),
                      labelStyle: TextStyle(fontSize: $(15), fontWeight: FontWeight.bold),
                      unselectedLabelColor: ColorConstant.PrimaryColor,
                      unselectedLabelStyle: TextStyle(fontSize: $(15), fontWeight: FontWeight.w500),
                      controller: _tabController,
                      onTap: (index) {
                        setIndex(index);
                      },
                      tabs: tabConfig.map((e) => Text(e.title).intoContainer(padding: EdgeInsets.symmetric(vertical: $(8), horizontal: $(0)))).toList(),
                    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(12)))),
                SizedBox(height: $(8))
              ],
            ).listenSizeChanged(onSizeChanged: (size) {
              setState(() {
                headerHeight = size.height;
              });
            }),
            Container(width: double.maxFinite, height: hashTagBlurOpen ? $(44) : $(0), child: buildHashTagList(dataController)),
          ],
        ).intoContainer(color: ColorConstant.BackgroundColorBlur).intoGestureDetector(
            onTap: () {},
            onDoubleTap: Platform.isIOS
                ? () {
                    EventBusHelper().eventBus.fire(OnTabDoubleClickEvent(data: tabId.id()));
                  }
                : null),
      ));

  Widget buildHashTagList(EffectDataController dataController) {
    if (dataController.tagList.isEmpty) {
      return Container(height: 0);
    }
    return ScrollablePositionedList.builder(
        scrollDirection: Axis.horizontal,
        initialScrollIndex: 0,
        padding: EdgeInsets.only(left: $(8), right: $(8)),
        physics: ClampingScrollPhysics(),
        itemCount: dataController.tagList.length,
        itemBuilder: (context, index) {
          var selected = index == selectedTagIndex;
          return (selected
                  ? ShaderMask(
                      shaderCallback: (Rect bounds) => LinearGradient(
                        colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomRight,
                      ).createShader(Offset.zero & bounds.size),
                      blendMode: BlendMode.srcATop,
                      child: Text(
                        '# ${dataController.tagList[index]}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: ColorConstant.White,
                          fontSize: $(13),
                        ),
                      ),
                    )
                  : Text(
                      '# ${dataController.tagList[index]}',
                      style: TextStyle(
                        fontSize: $(13),
                        fontFamily: 'Poppins',
                        color: ColorConstant.BlueColor,
                      ),
                    ))
              .intoContainer(padding: EdgeInsets.symmetric(vertical: $(10), horizontal: $(10)))
              .intoGestureDetector(onTap: () {
            if (selected) {
              setSelectedTagIndex(null);
            } else {
              setSelectedTagIndex(index);
            }
          });
        }).intoContainer(
      height: $(44),
      alignment: Alignment.center,
      color: Colors.transparent,
    );
  }

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
              ).intoContainer(margin: EdgeInsets.only(left: $(10))).offstage(offstage: !proVisible),
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
