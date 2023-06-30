import 'dart:convert';
import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/album_controller.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/notification_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/main.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/activity/activity_fragment.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';
import 'package:cartoonizer/views/discovery/discovery_list_controller.dart';
import 'package:cartoonizer/views/mine/refcode/refcode_controller.dart';
import 'package:cartoonizer/views/mine/refcode/submit_invited_code_screen.dart';
import 'package:cartoonizer/views/msg/msg_list_controller.dart';
import 'package:common_utils/common_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:photo_manager/photo_manager.dart';

import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int currentIndex = 0;
  List<AppRoleTabItem> tabItems = [];

  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late StreamSubscription onPaySuccessListener;
  late StreamSubscription onTabSwitchListener;
  late StreamSubscription onHomeConfigListener;
  late StreamSubscription onNewInvitationCodeListener;
  late StreamSubscription onUserStateChangeListener;
  EffectDataController dataController = Get.put(EffectDataController());
  RecentController recentController = Get.put(RecentController());
  AlbumController albumController = Get.put(AlbumController());
  MsgListController msgController = Get.put(MsgListController());
  DiscoveryListController discoveryListController = Get.put(DiscoveryListController());

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    initialTab(false);
    discoveryListController.onScrollChange = (scrollDown) {
      if (scrollDown) {
        animationController.forward();
      } else if (!scrollDown) {
        animationController.reverse();
      }
    };
    onPaySuccessListener = EventBusHelper().eventBus.on<OnPaySuccessEvent>().listen((event) {
      userManager.rateNoticeOperator.onBuy(context);
    });
    onTabSwitchListener = EventBusHelper().eventBus.on<OnTabSwitchEvent>().listen((event) {
      var data = event.data![0];
      for (int i = 0; i < tabItems.length; i++) {
        var tabItem = tabItems[i];
        if (tabItem.id == data) {
          _setIndex(i);
        }
      }
    });
    onHomeConfigListener = EventBusHelper().eventBus.on<OnHomeConfigGetEvent>().listen((event) {
      initialTab(true);
    });
    onUserStateChangeListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (event.data ?? false) {
        delay(() => judgeInvitationCode(), milliseconds: 2000);
      }
    });
    onNewInvitationCodeListener = EventBusHelper().eventBus.on<OnNewInvitationCodeReceiveEvent>().listen((event) {
      var currentRoute = MyApp.routeObserver.currentRoute;
      var currentName = currentRoute?.settings.name;
      if (currentName == '/HomeScreen') {
        SubmitInvitedCodeScreen.push(context, code: event.data);
      } else if (currentName == '/SubmitInvitedCodeScreen') {
        try {
          var controller = Get.find<RefCodeController>();
          if (TextUtil.isEmpty(controller.inputText)) {
            controller.inputText = event.data ?? '';
          }
        } catch (e) {}
      }
    });
    delay(() {
      userManager.refreshUser(context: context).then((value) {
        if (userManager.lastLauncherLoginStatus) {
          if (!value.loginSuccess) {
            userManager.logout().then((value) {
              userManager.doOnLogin(context, logPreLoginAction: 'token_expired', callback: () {
                afterAccountChecked();
              }, autoExec: true);
            });
          } else {
            delay(() {
              afterAccountChecked();
            });
          }
        } else {
          delay(() {
            afterAccountChecked();
          }, milliseconds: 1000);
        }
      });
    });
    PhotoManager.clearFileCache();
  }

  void afterAccountChecked() {
    delay(
        () => cacheManager.featureOperator.judgeAndOpenFeaturePage(context).then((value) {
              if (!value) {
                judgeInvitationCode();
              }
            }),
        milliseconds: 1000);
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null) {
        AppDelegate.instance.getManager<NotificationManager>().onHandleNotificationClick(value);
      }
    });
  }

  @override
  void dispose() {
    onPaySuccessListener.cancel();
    onTabSwitchListener.cancel();
    onHomeConfigListener.cancel();
    onNewInvitationCodeListener.cancel();
    onUserStateChangeListener.cancel();
    animationController.dispose();
    super.dispose();
  }

  initialTab(bool needSetState) {
    tabItems.clear();
    var allTabItems = buildTabItem();
    for (var tabItem in allTabItems) {
      tabItem.createFragment();
      tabItems.add(tabItem);
    }
    if (!allTabItems.exist((t) => t.id == AppTabId.ACTIVITY.id())) {
      var tab = dataController.data?.campaignTab;
      if (tab != null) {
        var appRoleTabItem = AppRoleTabItem(
          id: AppTabId.ACTIVITY.id(),
          titleBuilder: (context) => tab.title,
          keyBuilder: () => GlobalKey<ActivityFragmentState>(),
          fragmentBuilder: (key) => ActivityFragment(
            tabId: AppTabId.ACTIVITY,
            key: key,
          ),
          normalIcon: 'base64:${tab.image}',
          selectedIcon: 'base64:${tab.imageSelected}',
        );
        appRoleTabItem.createFragment();
        tabItems.insert(1, appRoleTabItem);
      }
      if (needSetState) {
        setState(() {});
      }
    }
  }

  _setIndex(pos) {
    if (currentIndex != pos) {
      setState(() {
        currentIndex = pos;
        for (var i = 0; i < tabItems.length; i++) {
          var key = tabItems[i].key;
          if (i == currentIndex) {
            key!.currentState?.onAttached();
          } else {
            key!.currentState?.onDetached();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          IndexedStack(index: currentIndex, children: tabItems.map((e) => e.fragment!).toList()).intoContainer(color: ColorConstant.BackgroundColor),
          Align(
            alignment: Alignment.bottomCenter,
            child: tabItems.length > 1 ? buildBottomBar(context) : Container(),
          ),
        ],
      ).blankAreaIntercept(),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, animationController.value * (55 + ScreenUtil.getBottomPadding(context))),
            child: ClipRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: AppTabBar(
                      items: createBottomItem(context),
                      activeColor: ColorConstant.BlueColor,
                      inactiveColor: ColorConstant.White,
                      // backgroundColor: ColorConstant.BackgroundColorBlur,
                      backgroundColor: Color.fromARGB(180, 14, 16, 17),
                      iconSize: $(22),
                      onTap: (pos) {
                        if (tabItems[pos].id == AppTabId.AI.id()) {
                          AnotherMe.checkPermissions().then((value) {
                            if (value) {
                              AnotherMe.open(context, source: 'home_page');
                            } else {
                              AnotherMe.permissionDenied(context);
                            }
                          });
                        } else {
                          _setIndex(pos);
                        }
                      },
                      onDoubleTap: (index) {
                        EventBusHelper().eventBus.fire(OnTabDoubleClickEvent(data: tabItems[index].id));
                      },
                      onLongPress: (index) {
                        EventBusHelper().eventBus.fire(OnTabLongPressEvent(data: tabItems[index].id));
                      },
                      currentIndex: currentIndex,
                      elevation: $(4),
                    ))),
          );
        });
  }

  List<BottomNavigationBarItem> createBottomItem(BuildContext context) {
    List<BottomNavigationBarItem> result = List.empty(growable: true);
    for (int i = 0; i < tabItems.length; i++) {
      var value = tabItems[i];
      Image normalIcon;
      Image selectedIcon;
      if (value.normalIcon.startsWith('base64:')) {
        var image = value.normalIcon.replaceAll('base64:', '');
        var imageUint8List = base64Decode(image);
        normalIcon = Image.memory(
          imageUint8List,
          gaplessPlayback: true,
        );
      } else {
        normalIcon = Image.asset(
          value.normalIcon,
          gaplessPlayback: true,
        );
      }
      if (value.selectedIcon.startsWith('base64:')) {
        var image = value.selectedIcon.replaceAll('base64:', '');
        var imageUint8List = base64Decode(image);
        selectedIcon = Image.memory(
          imageUint8List,
          gaplessPlayback: true,
        );
      } else {
        selectedIcon = Image.asset(
          value.selectedIcon,
          gaplessPlayback: true,
        );
      }
      result.add(BottomNavigationBarItem(
        icon: normalIcon,
        activeIcon: selectedIcon,
        label: value.titleBuilder(context),
      ));
    }
    return result;
  }
}
