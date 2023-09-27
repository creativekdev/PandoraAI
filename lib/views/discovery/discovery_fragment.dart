import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
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
  late DiscoveriesController discoveryListController = DiscoveriesController();
  Rx<bool> discoveryVisible = true.obs;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'discovery_fragment');
    tabController = TabController(length: tabs.length, vsync: this);
    pageController = PageController(keepPage: true);
    tabId = widget.tabId;
    discoveryListController = DiscoveriesController()..onInit();
    children = [
      DiscoveryListPageWidget(
        tabId: tabId,
        controller: discoveryListController,
      ),
      DiscoveryMetagramPage(tabId: tabId),
    ];
    refreshDVisible(tabController.index);
  }

  refreshDVisible(int index) => discoveryVisible.value = index == 0;

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
      body: Stack(
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
              refreshDVisible(index);
              tabController.animateTo(index, duration: Duration(milliseconds: 300));
            },
            children: children,
          ).intoContainer(
            height: ScreenUtil.screenSize.height - headerHeight,
            width: ScreenUtil.screenSize.width,
            margin: EdgeInsets.only(top: headerHeight),
          ),
          GetBuilder(
            builder: <DiscoveriesController>(controller) {
              return Obx(() => Container(
                    height: 52.dp,
                    width: ScreenUtil.screenSize.width,
                    child: discoveryListTag(controller),
                    margin: EdgeInsets.only(top: headerHeight),
                  ).offstage(offstage: !discoveryVisible.value));
            },
            init: discoveryListController,
          ),
        ],
      ).intoContainer(
        height: ScreenUtil.screenSize.height,
        width: ScreenUtil.screenSize.width,
      ),
    );
  }

  Widget discoveryListTag(DiscoveriesController controller) {
    return Stack(
      children: [
        Listener(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: ClampingScrollPhysics(),
            controller: controller.tagController,
            padding: EdgeInsets.only(left: 15.dp, right: 30.dp),
            child: Row(
              children: controller.tags.transfer((e, index) {
                bool checked = controller.currentTag == e;
                return Text(
                  e.tagTitle(),
                  style: TextStyle(
                    color: checked ? Color(0xff3e60ff) : Colors.white.withOpacity(0.8),
                    fontSize: 13.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                  ),
                )
                    .intoContainer(
                  margin: EdgeInsets.only(left: index == 0 ? 0 : 4.dp),
                  padding: EdgeInsets.symmetric(horizontal: 8.dp, vertical: 7.dp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: checked ? Colors.transparent : Color(0xFF37373B),
                    border: Border.all(color: checked ? ColorConstant.DiscoveryBtn : Colors.transparent, width: 1),
                  ),
                )
                    .intoGestureDetector(onTap: () {
                  if (controller.listLoading) {
                    return;
                  }
                  if (controller.currentTag == e) {
                    controller.currentTag = null;
                  } else {
                    controller.currentTag = e;
                  }
                  controller.easyRefreshController.callRefresh();
                });
              }),
            ),
          ).intoContainer(padding: EdgeInsets.only(top: 8)),
          onPointerDown: (details) {
            controller.isTagScrolling = true;
          },
          onPointerCancel: (details) {
            controller.isTagScrolling = false;
          },
          onPointerUp: (details) {
            controller.isTagScrolling = false;
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Image.asset(
            Images.ic_discovery_tag_more,
            width: 16.dp,
          )
              .intoContainer(
            padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 6.dp),
            margin: EdgeInsets.only(top: 8.dp),
            color: ColorConstant.BackgroundColor,
          )
              .intoGestureDetector(onTap: () {
            controller.tagController.animateTo(controller.tagController.offset + ScreenUtil.screenSize.width, duration: Duration(milliseconds: 300), curve: Curves.linear);
          }).visibility(visible: !controller.isTagScrolling && !controller.isScrollEnd),
        ),
      ],
    )
        .intoContainer(
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 8.dp),
        )
        // .blur()
        .ignore(ignoring: controller.listLoading);
  }

  @override
  bool get wantKeepAlive => true;
}
