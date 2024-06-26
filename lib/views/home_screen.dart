import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/notification_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/controller/album_controller.dart';
import 'package:cartoonizer/controller/effect_data_controller.dart';
import 'package:cartoonizer/controller/recent/recent_controller.dart';
import 'package:cartoonizer/main.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/mine/refcode/refcode_controller.dart';
import 'package:cartoonizer/views/mine/refcode/submit_invited_code_screen.dart';
import 'package:cartoonizer/views/msg/msg_list_controller.dart';
import 'package:cartoonizer/widgets/tabbar/app_tab_bar.dart';
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

  AnimationController? animationController;

  late StreamSubscription onHomeScrollListener;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    initialTab(false);
    onHomeScrollListener = EventBusHelper().eventBus.on<OnHomeScrollEvent>().listen((event) {
      var scrollDown = event.data;
      if (scrollDown == null || !mounted) {
        return;
      }
      if (animationController == null) {
        return;
      }
      if (scrollDown) {
        animationController?.forward();
      } else if (!scrollDown) {
        animationController?.reverse();
      }
    });
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
                if (Platform.isAndroid) {
                  judgeInvitationCode();
                }
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
    onHomeScrollListener.cancel();
    animationController?.dispose();
    super.dispose();
  }

  initialTab(bool needSetState) {
    tabItems.clear();
    var allTabItems = buildTabItem();
    for (var tabItem in allTabItems) {
      tabItem.createFragment();
      tabItems.add(tabItem);
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
        animation: animationController!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, animationController!.value * (AppTabBarHeight + ScreenUtil.getBottomPadding())),
            child: ClipRect(
                child: AppTabBar(
              items: createBottomItem(context),
              activeColor: ColorConstant.BlueColor,
              inactiveColor: ColorConstant.White,
              // backgroundColor: ColorConstant.BackgroundColorBlur,
              backgroundColor: Color.fromARGB(180, 14, 16, 17),
              iconSize: $(22),
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
            ).blur()),
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
