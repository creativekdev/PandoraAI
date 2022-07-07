import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/admob/card_ads_holder.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache_manager.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';
import 'package:cartoonizer/utils/utils.dart';
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
  List<_ListData> dataList = [];
  Size? navbarSize;
  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  late AppTabId tabId;

  late List<DiscoveryFilterTab> tabList;
  late TabController tabController;
  bool listLoading = false;
  late DiscoveryFilterTab currentTab;
  late CardAdsMap cardAdsMap;
  double cardWidth = 150;
  late ScrollController scrollController;
  double tabBarOffset = 0;

  @override
  void initState() {
    super.initState();
    api = CartoonizerApi().bindState(this);
    tabId = widget.tabId;
    cardWidth = (ScreenUtil.screenSize.width - $(38)) / 2;
    onLoginEventListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (event.data ?? true) {
        _easyRefreshController.callRefresh();
      } else {
        for (var value in dataList) {
          if (!value.isAd) {
            value.data!.likeId = null;
          }
        }
        setState(() {});
      }
    });
    onLikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryLikeEvent>().listen((event) {
      var id = event.data!.key;
      var likeId = event.data!.value;
      for (var data in dataList) {
        if (!data.isAd) {
          if (data.data!.id == id) {
            data.data!.likeId = likeId;
            data.data!.likes++;
            setState(() {});
          }
        }
      }
    });
    onUnlikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryUnlikeEvent>().listen((event) {
      for (var data in dataList) {
        if (!data.isAd) {
          if (data.data!.id == event.data) {
            data.data!.likeId = null;
            data.data!.likes--;
            setState(() {});
          }
        }
      }
    });
    tabList = [
      DiscoveryFilterTab(sort: DiscoverySort.likes, title: 'Popular'),
      DiscoveryFilterTab(sort: DiscoverySort.newest, title: 'Newest'),
    ];
    currentTab = tabList[0];
    tabController = TabController(length: tabList.length, vsync: this);
    cardAdsMap = CardAdsMap(
        width: cardWidth,
        onUpdated: () {
          setState(() {});
        },
        scale: 1);
    cardAdsMap.init();
    delay(() {
      _easyRefreshController.callRefresh();
    });
    scrollController = ScrollController();
    scrollController.addListener(() {
      print(scrollController.offset);
      var top = MediaQuery.of(context).padding.top;
      if (scrollController.offset > top) {
        if (scrollController.offset < top + $(36)) {
          var d = scrollController.offset - top;
          setState(() {
            tabBarOffset = d;
          });
        } else {
          setState(() {
            tabBarOffset = $(36);
          });
        }
      } else {
        setState(() {
          tabBarOffset = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    cardAdsMap.dispose();
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
    currentTab = tabList[index];
    _easyRefreshController.callRefresh();
  }

  addToDataList(int page, List<DiscoveryListEntity> list) {
    if (!cardAdsMap.hasAdHolder(page + 2)) {
      cardAdsMap.addAdsCard(page + 2);
    }
    if (list.length > 4) {
      dataList.addAll(list.sublist(0, 4).map((e) => _ListData(data: e, page: page)));
      dataList.add(_ListData(isAd: true, page: page));
      dataList.addAll(list.sublist(4).map((e) => _ListData(data: e, page: page)));
    } else {
      dataList.addAll(list.map((e) => _ListData(data: e, page: page)));
    }
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
          dataList.clear();
          addToDataList(value.page, list);
        });
        _easyRefreshController.finishLoad(noMore: list.length != pageSize);
      }
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
          addToDataList(value.page, list);
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
      body: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
          SliverAppBar(
            collapsedHeight: $(36),
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
              titlePadding: EdgeInsets.only(bottom: $(0)),
            ),
            backgroundColor: ColorConstant.BackgroundColor,
            toolbarHeight: $(36),
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
                  tabs: tabList.map((e) => Text(e.title).intoContainer(padding: EdgeInsets.symmetric(vertical: $(6)))).toList(),
                  onTap: (index) {
                    onTabClick(index);
                  },
                  padding: EdgeInsets.zero,
                ).intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(4)),
                  height: $(44),
                  color: Colors.transparent,
                ),
                height: $(44) + tabBarOffset,
              ),
              pinned: true,
              floating: true,
            ),
          ),
        ],
        body: buildRefreshList(),
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
        child: WaterfallFlow.custom(
          cacheExtent: 1.0,
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: $(8),
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) {
              var data = dataList[index];
              if (data.isAd) {
                return _buildMERCAd(data.page);
              }
              return DiscoveryListCard(
                data: data.data!,
                width: cardWidth,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => DiscoveryEffectDetailScreen(data: data.data!),
                    settings: RouteSettings(name: "/DiscoveryEffectDetailScreen"),
                  ),
                ),
                onLikeTap: () {
                  userManager.doOnLogin(context, callback: () {
                    onLikeTap(data.data!);
                  }, autoExec: false);
                },
              ).intoContainer(margin: EdgeInsets.only(top: $(8)));
            },
            childCount: dataList.length,
          ),
        )).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)));
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

  Widget _buildMERCAd(int page) {
    var showAds = isShowAdsNew();

    if (showAds) {
      var result = cardAdsMap.buildBannerAd(page);
      if (result != null) {
        return result.intoContainer(margin: EdgeInsets.only(top: $(8)));
      }
    }
    return Container();
  }
}

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget widget;
  final double height;

  const SliverTabBarDelegate(this.widget, {this.height = 44});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            child: Theme(
                data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget,
                  ],
                )),
            color: ColorConstant.BackgroundColorBlur,
          )),
    );
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

class _ListData {
  bool isAd;
  int page;
  DiscoveryListEntity? data;

  _ListData({
    this.isAd = false,
    this.data,
    required this.page,
  });
}
