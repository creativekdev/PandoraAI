import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache_manager.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';
import 'package:cartoonizer/views/discovery/discovery_effect_detail_screen.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../Widgets/indicator/line_tab_indicator.dart';
import 'widget/discovery_list_card.dart';

class DiscoveryFragment extends StatefulWidget {
  AppTabId tabId;

  DiscoveryFragment({
    Key? key,
    required this.tabId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DiscoveryFragmentState();
}

class DiscoveryFragmentState extends AppState<DiscoveryFragment> with AutomaticKeepAliveClientMixin, AppTabState, SingleTickerProviderStateMixin {
  EasyRefreshController _easyRefreshController = EasyRefreshController();
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  int page = 0;
  int pageSize = 10;
  late CartoonizerApi api;
  List<DiscoveryListEntity> dataList = [];
  Size? navbarSize;
  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  late AppTabId tabId;

  late List<DiscoveryFilterTab> tabList;
  late TabController tabController;
  bool listLoading = false;
  late DiscoveryFilterTab currentTab;

  @override
  void initState() {
    super.initState();
    api = CartoonizerApi().bindState(this);
    tabId = widget.tabId;
    delay(() {
      _easyRefreshController.callRefresh();
    });
    onLoginEventListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (event.data ?? true) {
        _easyRefreshController.callRefresh();
      } else {
        for (var value in dataList) {
          value.likeId = null;
        }
        setState(() {});
      }
    });
    onLikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryLikeEvent>().listen((event) {
      var id = event.data!.key;
      var likeId = event.data!.value;
      for (var data in dataList) {
        if (data.id == id) {
          data.likeId = likeId;
          data.likes++;
          setState(() {});
        }
      }
    });
    onUnlikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryUnlikeEvent>().listen((event) {
      for (var data in dataList) {
        if (data.id == event.data) {
          data.likeId = null;
          data.likes--;
          setState(() {});
        }
      }
    });
    tabList = [
      DiscoveryFilterTab(sort: DiscoverySort.likes, title: 'Popular'),
      DiscoveryFilterTab(sort: DiscoverySort.newest, title: 'Newest'),
    ];
    currentTab = tabList[0];
    tabController = TabController(length: tabList.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    _easyRefreshController.dispose();
    onLoginEventListener.cancel();
    onLikeEventListener.cancel();
    onUnlikeEventListener.cancel();
  }

  @override
  void onAttached() {
    super.onAttached();
    userManager.refreshUser();
    var lastTime = cacheManager.getInt('${CacheManager.keyLastTabAttached}_${tabId.id()}');
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - lastTime > 5000) {
      logEvent(Events.tab_discovery_loading);
    }
    cacheManager.setInt('${CacheManager.keyLastTabAttached}_${tabId.id()}', currentTime);
  }

  onTabClick(index) {
    // if (currentTab != tabList[index]) {
    currentTab = tabList[index];
    _easyRefreshController.callRefresh();
    // }
  }

  onLoadFirstPage() {
    setState(() => listLoading = true);
    api
        .listDiscovery(
      page: 0,
      pageSize: pageSize,
      sort: currentTab.sort,
    )
        .then((value) {
      setState(() => listLoading = false);
      _easyRefreshController.finishRefresh();
      if (value != null) {
        page = 0;
        var list = value.getDataList<DiscoveryListEntity>();
        setState(() {
          dataList = list;
        });
      }
      _easyRefreshController.finishLoad(noMore: dataList.length != pageSize);
    });
  }

  onLoadMorePage() {
    setState(() => listLoading = true);
    api
        .listDiscovery(
      page: page + 1,
      pageSize: pageSize,
      sort: currentTab.sort,
    )
        .then((value) {
      setState(() => listLoading = false);
      if (value == null) {
        _easyRefreshController.finishLoad(noMore: false);
      } else {
        page++;
        var list = value.getDataList<DiscoveryListEntity>();
        setState(() {
          dataList.addAll(list);
        });
        _easyRefreshController.finishLoad(noMore: list.length != pageSize);
      }
    });
  }

  onLikeTap(DiscoveryListEntity entity) => showLoading().whenComplete(() {
        if (entity.likeId == null) {
          api.discoveryLike(entity.id).then((value) {
            hideLoading();
          });
        } else {
          api.discoveryUnLike(entity.id, entity.likeId!).then((value) {
            hideLoading();
          });
        }
      });

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return build2(context);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
            SliverAppBar(
              floating: false,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                expandedTitleScale: 1,
                title: TitleTextWidget(
                  StringConstant.tabDiscovery,
                  ColorConstant.BtnTextColor,
                  FontWeight.w600,
                  $(18),
                ),
                titlePadding: EdgeInsets.only(bottom: $(8)),
              ),
              backgroundColor: ColorConstant.BackgroundColor,
              toolbarHeight: $(44),
            ),
            SliverIgnorePointer(
              ignoring: listLoading,
              sliver: SliverPersistentHeader(
                delegate: SliverTabBarDelegate(
                  TabBar(
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: LineTabIndicator(
                      width: $(20),
                      strokeCap: StrokeCap.butt,
                      borderSide: BorderSide(width: $(3), color: ColorConstant.BlueColor),
                    ),
                    labelColor: ColorConstant.PrimaryColor,
                    labelPadding: EdgeInsets.only(left: $(5), right: $(5)),
                    labelStyle: TextStyle(fontSize: $(14), fontWeight: FontWeight.bold),
                    unselectedLabelColor: ColorConstant.PrimaryColor,
                    unselectedLabelStyle: TextStyle(fontSize: $(14), fontWeight: FontWeight.w500),
                    controller: tabController,
                    tabs: tabList.map((e) => Text(e.title).intoContainer(padding: EdgeInsets.symmetric(vertical: $(8)))).toList(),
                    onTap: (index) {
                      onTabClick(index);
                    },
                    padding: EdgeInsets.zero,
                  ).intoContainer(
                    padding: EdgeInsets.symmetric(vertical: $(4)),
                    color: ColorConstant.BackgroundColor,
                  ),
                ),
                pinned: true,
                floating: true,
              ),
            ),
          ],
          body: buildRefreshList(),
        ),
      ),
    );
  }

  Widget buildRefreshList() {
    return EasyRefresh(
      controller: _easyRefreshController,
      enableControlFinishRefresh: true,
      enableControlFinishLoad: false,
      emptyWidget: dataList.isEmpty ? TitleTextWidget('Don\'t found any Discovery yet', ColorConstant.White, FontWeight.normal, $(16)).intoCenter() : null,
      onRefresh: () async => onLoadFirstPage(),
      onLoad: () async => onLoadMorePage(),
      child: WaterfallFlow.builder(
        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: $(8),
          mainAxisSpacing: $(8),
        ),
        itemBuilder: (context, index) => DiscoveryListCard(
          data: dataList[index],
          width: (ScreenUtil.screenSize.width - $(36)) / 2,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => DiscoveryEffectDetailScreen(data: dataList[index]),
              settings: RouteSettings(name: "/DiscoveryEffectDetailScreen"),
            ),
          ),
          onLikeTap: () {
            userManager.doOnLogin(context, callback: () {
              onLikeTap(dataList[index]);
            }, autoExec: false);
          },
        ).intoContainer(margin: EdgeInsets.only(top: $(index < 2 ? 10 : 0))),
        itemCount: dataList.length,
      ),
    ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)));
  }

  Widget navbar(BuildContext context) => ClipRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppNavigationBar(
                    showBackItem: false,
                    blurAble: true,
                    backgroundColor: ColorConstant.BackgroundColorBlur,
                    middle: TitleTextWidget(
                      StringConstant.tabDiscovery,
                      ColorConstant.BtnTextColor,
                      FontWeight.w600,
                      $(18),
                    )).listenSizeChanged(onSizeChanged: (size) {
                  setState(() => navbarSize = size);
                }),
              ],
            )),
      );

  @override
  bool get wantKeepAlive => true;
}

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget widget;
  final double height;

  const SliverTabBarDelegate(this.widget, {this.height = 44});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Theme(data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent), child: widget);
  }

  @override
  bool shouldRebuild(SliverTabBarDelegate oldDelegate) {
    return false;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;
}

class DiscoveryFilterTab {
  String title;
  DiscoverySort sort;

  DiscoveryFilterTab({required this.sort, required this.title});
}
