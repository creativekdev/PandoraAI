import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/views/discovery/discovery_list_controller.dart';
import 'package:cartoonizer/views/discovery/pages/discovery_list_page.dart';
import 'package:cartoonizer/views/discovery/pages/discovery_metagram_page.dart';
import 'package:cartoonizer/widgets/indicator/line_tab_indicator.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class DiscoveryFragment extends StatefulWidget {
  AppTabId tabId;

  DiscoveryFragment({
    Key? key,
    required this.tabId,
  }) : super(key: key);

  @override
  State<DiscoveryFragment> createState() => DiscoveryFragmentState();
}

class DiscoveryFragmentState extends AppState<DiscoveryFragment> with AutomaticKeepAliveClientMixin, AppTabState, TickerProviderStateMixin {
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late AppTabId tabId;

  double headerHeight = ScreenUtil.getStatusBarHeight() + 50.dp;

  late TabController tabController;
  late PageController pageController;
  final List<String> tabs = ['Discovery', 'Metagram'];

  late List<Widget> children;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'discovery_fragment');
    tabController = TabController(length: tabs.length, vsync: this);
    pageController = PageController(keepPage: true);
    tabId = widget.tabId;
    children = [
      DiscoveryListPageWidget(tabId: tabId),
      DiscoveryMetagramPage(tabId: tabId),
    ];
  }

  @override
  void onAttached() {
    super.onAttached();
    userManager.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return build2(context);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff161719),
      body: GetBuilder<DiscoveryListController>(
        init: Get.find<DiscoveryListController>(),
        builder: (listController) {
          return Column(
            children: [
              Theme(
                data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
                child: TabBar(
                  isScrollable: true,
                  indicator: LineTabIndicator(
                    borderSide: BorderSide(width: 4.0, color: ColorConstant.DiscoveryBtn),
                    strokeCap: StrokeCap.round,
                    width: 90.dp,
                  ),
                  padding: EdgeInsets.only(bottom: 4.dp),
                  labelColor: Colors.white,
                  labelStyle: TextStyle(fontWeight: FontWeight.normal),
                  unselectedLabelColor: Colors.grey.shade400,
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                  tabs: tabs
                      .map((e) => Text(e, style: TextStyle(fontSize: 18.dp)).intoContainer(
                            color: Colors.transparent,
                            padding: EdgeInsets.only(left: 0, top: 8.dp, right: 0, bottom: 8.dp),
                          ))
                      .toList(),
                  controller: tabController,
                  onTap: (index) {
                    if (tabController.index != index) {
                      Events.discoveryTabClick(tab: tabs[index]);
                    }
                    pageController.jumpToPage(index);
                  },
                ),
              ).intoContainer(width: ScreenUtil.screenSize.width, alignment: Alignment.center).intoContainer(
                    padding: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight()),
                    height: headerHeight,
                    color: ColorConstant.BackgroundColorBlur,
                  ),
              PageView(
                controller: pageController,
                onPageChanged: (index) {
                  tabController.animateTo(index, duration: Duration(milliseconds: 300));
                },
                children: children,
              ).intoContainer(
                height: ScreenUtil.screenSize.height - headerHeight,
                width: ScreenUtil.screenSize.width,
              ),
            ],
          ).intoContainer(
            height: ScreenUtil.screenSize.height,
            width: ScreenUtil.screenSize.width,
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
