import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/views/msg/msg_list_screen.dart';

import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  int currentIndex = 0;
  List<AppRoleTabItem> tabItems = [];

  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late StreamSubscription onPaySuccessListener;

  @override
  void initState() {
    logEvent(Events.homepage_loading);
    super.initState();
    initialTab(false);
    onPaySuccessListener = EventBusHelper().eventBus.on<OnPaySuccessEvent>().listen((event) {
      userManager.rateNoticeOperator.onBuy(context);
    });
    delay(() {
      userManager.refreshUser(context: context).then((value) {
        if (userManager.lastLauncherLoginStatus) {
          if (!value.loginSuccess) {
            userManager.logout().then((value) {
              userManager.doOnLogin(context);
            });
          } else {
            delay(() {
              userManager.rateNoticeOperator.judgeAndShowNotice(context);
              AppDelegate.instance.getManager<MsgManager>().loadFirstPage();
              if (cacheManager.getBool(CacheManager.openToMsg)) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MsgListScreen()));
              }
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    onPaySuccessListener.cancel();
  }

  initialTab(bool needSetState) {
    tabItems.clear();
    var allTabItems = buildTabItem();
    for (var tabItem in allTabItems) {
      // 不做权限校验
      // if (userManager.hasRole(tabItem.roles)) {
      //有权限才创建item
      tabItem.createFragment();
      tabItems.add(tabItem);
      // }
    }
    currentIndex = 0;
    if (needSetState) {
      setState(() {});
    }
  }

  _setIndex(pos) {
    if (currentIndex != pos) {
      setState(() {
        currentIndex = pos;
        for (var i = 0; i < tabItems.length; i++) {
          var key = tabItems[i].key;
          if (i == currentIndex) {
            key.currentState?.onAttached();
          } else {
            key.currentState?.onDetached();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          IndexedStack(index: currentIndex, children: tabItems.map((e) => e.fragment).toList()).intoContainer(color: ColorConstant.BackgroundColor),
          Align(
            alignment: Alignment.bottomCenter,
            child: tabItems.length > 1
                ? ClipRect(
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: AppTabBar(
                          items: createBottomItem(context),
                          activeColor: ColorConstant.BlueColor,
                          inactiveColor: ColorConstant.White,
                          // backgroundColor: ColorConstant.BackgroundColorBlur,
                          backgroundColor: Color.fromARGB(180, 14, 16, 17),
                          iconSize: $(24),
                          onTap: (pos) {
                            _setIndex(pos);
                          },
                          onDoubleTap: (index) {
                            EventBusHelper().eventBus.fire(OnTabDoubleClickEvent(data: tabItems[index].id));
                          },
                          onLongPress: (index) {
                            EventBusHelper().eventBus.fire(OnTabLongPressEvent(data: tabItems[index].id));
                          },
                          currentIndex: currentIndex,
                          elevation: $(4),
                        )))
                : Container(),
          ),
        ],
      ).blankAreaIntercept(),
    );
  }

  List<BottomNavigationBarItem> createBottomItem(BuildContext context) {
    List<BottomNavigationBarItem> result = List.empty(growable: true);
    for (int i = 0; i < tabItems.length; i++) {
      var value = tabItems[i];
      result.add(BottomNavigationBarItem(
        icon: Image.asset(
          value.normalIcon,
          gaplessPlayback: true,
        ),
        activeIcon: Image.asset(
          value.selectedIcon,
          gaplessPlayback: true,
        ),
        label: value.titleBuilder(context),
      ));
    }
    return result;
  }


  //监听程序进入前后台的状态改变的方法
  /// dead code。
  /// 此方法不生效，因为push到homescreen的时候当前页面就被销毁了。所以之前的adContainer报错也是一直没有得到fix。
  /// 新实现在ThirdpartManager里，使用了google ads的AppStateEventNotifier
  /// 如果要使用此段代码，可以搬到home screen中，但是home screen在使用过程中还是会被重启，所以放在了ThirdpartManager中。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
    //进入应用时候不会触发该状态 应用程序处于可见状态，并且可以响应用户的输入事件。它相当于 Android 中Activity的onResume
      case AppLifecycleState.resumed:
        print("didChangeAppLifecycleState-------> 应用进入前台======");
        break;
    //应用状态处于闲置状态，并且没有用户的输入事件，
    // 注意：这个状态切换到 前后台 会触发，所以流程应该是先冻结窗口，然后停止UI
      case AppLifecycleState.inactive:
        print("didChangeAppLifecycleState-------> 应用处于闲置状态，这种状态的应用应该假设他们可能在任何时候暂停 切换到后台会触发======");
        break;
    //当前页面即将退出
      case AppLifecycleState.detached:
        print("didChangeAppLifecycleState-------> 当前页面即将退出======");
        break;
    // 应用程序处于不可见状态
      case AppLifecycleState.paused:
        print("didChangeAppLifecycleState-------> 应用处于不可见状态 后台======");
        break;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
