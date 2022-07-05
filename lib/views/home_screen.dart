import 'dart:ui';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';

import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int currentIndex = 0;
  List<AppRoleTabItem> tabItems = [];

  @override
  void initState() {
    logEvent(Events.homepage_loading);
    super.initState();
    initialTab(false);
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
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: AppTabBar(
                          items: createBottomItem(context),
                          activeColor: ColorConstant.BlueColor,
                          inactiveColor: ColorConstant.White,
                          // backgroundColor: ColorConstant.BackgroundColorBlur,
                          backgroundColor: Color.fromARGB(210, 0, 0, 0),
                          iconSize: $(24),
                          onTap: (pos) {
                            _setIndex(pos);
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

  @override
  bool get wantKeepAlive => true;
}
