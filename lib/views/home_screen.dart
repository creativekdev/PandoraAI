import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
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
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        visible: false,
        backgroundColor: ColorConstant.BackgroundColor,
      ),
      body: IndexedStack(index: currentIndex, children: tabItems.map((e) => e.fragment).toList()),
      bottomNavigationBar: tabItems.length > 1
          ? AppTabBar(
              items: createBottomItem(context),
              activeColor: ColorConstant.BlueColor,
              inactiveColor: ColorConstant.White,
              backgroundColor: ColorConstant.TabBackground,
              iconSize: $(25),
              onTap: (pos) {
                _setIndex(pos);
              },
              currentIndex: currentIndex,
              elevation: $(4),
            )
          : null,
    );
  }

  List<BottomNavigationBarItem> createBottomItem(BuildContext context) {
    List<BottomNavigationBarItem> result = List.empty(growable: true);
    for (var value in tabItems) {
      result.add(BottomNavigationBarItem(
        icon: value.normalIcon,
        activeIcon: value.selectedIcon,
        label: value.titleBuilder(context),
      ));
    }
    return result;
  }

  @override
  bool get wantKeepAlive => true;
}
