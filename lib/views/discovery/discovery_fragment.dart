import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/admob/card_ads_holder.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
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
  late AppTabId tabId;
  EasyRefreshController _easyRefreshController = EasyRefreshController();
  UserManager userManager = AppDelegate.instance.getManager();
  EffectManager effectManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();
  late TabController tabController;
  late List<DiscoveryFilterTab> tabList = [
    DiscoveryFilterTab(sort: DiscoverySort.likes, title: 'Popular'),
    DiscoveryFilterTab(sort: DiscoverySort.newest, title: 'Newest'),
  ];
  late DiscoveryFilterTab currentTab;
  int page = 0;
  int pageSize = 10;
  late CartoonizerApi api;
  List<_ListData> dataList = [];
  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  late StreamSubscription onAppStateListener;
  late StreamSubscription onTabDoubleClickListener;
  late StreamSubscription onCreateCommentListener;
  late StreamSubscription onDeleteListener;
  late StreamSubscription onNsfwChangeListener;

  bool listLoading = false;

  late CardAdsMap cardAdsMap;
  double cardWidth = 150;
  final double adScale = 1.55;

  late ScrollController scrollController;
  late ScrollController headerScrollController;
  double headerHeight = 0;
  double tabBarHeight = 0;
  double lastOffset = 0;
  bool maskVisible = true;
  bool firstLoad = true;
  Map<int, GlobalKey<FutureLoadingImageState>> keyMap = {};
  late bool nsfwOpen;

  @override
  void initState() {
    super.initState();
    nsfwOpen = cacheManager.getBool(CacheManager.nsfwOpen);
    api = CartoonizerApi().bindState(this);
    tabId = widget.tabId;
    cardWidth = (ScreenUtil.screenSize.width - $(38)) / 2;
    onNsfwChangeListener = EventBusHelper().eventBus.on<OnEffectNsfwChangeEvent>().listen((event) {
      setState(() {});
    });
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
    onAppStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      setState(() {});
    });
    onTabDoubleClickListener = EventBusHelper().eventBus.on<OnTabDoubleClickEvent>().listen((event) {
      if (tabId.id() == event.data) {
        _easyRefreshController.callRefresh();
      }
    });
    onCreateCommentListener = EventBusHelper().eventBus.on<OnCreateCommentEvent>().listen((event) {
      if (event.data?.length == 1) {
        for (var value in dataList) {
          if (!value.isAd) {
            if (value.data!.id == event.data![0]) {
              value.data!.comments++;
              break;
            }
          }
        }
        setState(() {});
      }
    });
    onDeleteListener = EventBusHelper().eventBus.on<OnDeleteDiscoveryEvent>().listen((event) {
      for (var value in dataList) {
        if (value.isAd && value.data!.id == event.data) {
          value.data!.removed = true;
          break;
        }
      }
      setState(() {});
    });
    currentTab = tabList[0];
    tabController = TabController(length: tabList.length, vsync: this);
    cardAdsMap = CardAdsMap(
      width: cardWidth,
      onUpdated: () {
        if (mounted) {
          setState(() {});
        }
      },
      scale: adScale,
      autoHeight: true,
    );
    cardAdsMap.init();
    scrollController = ScrollController();
    headerScrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.offset > 0) {
        var range = headerHeight - MediaQuery.of(context).padding.top;
        if (scrollController.offset < range) {
          lastOffset = scrollController.offset;
          headerScrollController.jumpTo(scrollController.offset);
          if (!maskVisible) {
            maskVisible = true;
          }
          setState(() {});
        } else {
          if (lastOffset != range) {
            lastOffset = range;
            headerScrollController.jumpTo(lastOffset);
            setState(() {
              maskVisible = false;
            });
          }
        }
      } else {
        if (lastOffset != 0) {
          lastOffset = 0;
          headerScrollController.jumpTo(lastOffset);
          setState(() {
            maskVisible = true;
          });
        }
      }
    });
    delay(() => _easyRefreshController.callRefresh());
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
    onAppStateListener.cancel();
    onTabDoubleClickListener.cancel();
    onCreateCommentListener.cancel();
    onDeleteListener.cancel();
    onNsfwChangeListener.cancel();
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
    var nsfw = cacheManager.getBool(CacheManager.nsfwOpen);
    if (nsfwOpen != nsfw) {
      setState(() {
        nsfwOpen = nsfw;
      });
    }
  }

  onTabClick(index) {
    currentTab = tabList[index];
    _easyRefreshController.callRefresh();
  }

  Future<void> addToDataList(int page, List<DiscoveryListEntity> list) async {
    if (!cardAdsMap.hasAdHolder(page + 2)) {
      cardAdsMap.addAdsCard(page + 2);
    }
    for (int i = 0; i < list.length; i++) {
      var data = list[i];
      dataList.add(_ListData(
        page: page,
        data: data,
        visible: dataList.pick((t) => t.data?.id == data.id) == null,
      ));
      if (i == 4) {
        dataList.add(_ListData(isAd: true, page: page));
      }
    }
  }

  onLoadFirstPage() {
    setState(() => listLoading = true);
    cardAdsMap.init();
    api
        .listDiscovery(
      from: 0,
      pageSize: pageSize,
      sort: currentTab.sort,
    )
        .then((value) {
      delay(() {
        if (mounted) {
          setState(() => listLoading = false);
        }
      }, milliseconds: 1500);
      _easyRefreshController.finishRefresh();
      if (value != null) {
        page = 0;
        dataList.clear();
        var list = value.getDataList<DiscoveryListEntity>();
        addToDataList(page, list).whenComplete(() {
          setState(() {});
        });
        _easyRefreshController.finishLoad(noMore: list.length != pageSize);
      }
      if (firstLoad) {
        scrollController.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.linear);
        firstLoad = false;
      }
    });
  }

  onLoadMorePage() {
    setState(() => listLoading = true);
    api
        .listDiscovery(
      from: (page + 1) * pageSize,
      pageSize: pageSize,
      sort: currentTab.sort,
    )
        .then((value) {
      delay(() => setState(() => listLoading = false), milliseconds: 1500);
      if (value == null) {
        _easyRefreshController.finishLoad(noMore: false);
      } else {
        page++;
        var list = value.getDataList<DiscoveryListEntity>();
        addToDataList(page, list).whenComplete(() {
          setState(() {});
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          buildRefreshList().intoContainer(margin: EdgeInsets.only(top: headerHeight)),
          SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            controller: headerScrollController,
            child: Column(children: [
              TitleTextWidget(
                StringConstant.tabDiscovery,
                ColorConstant.BtnTextColor,
                FontWeight.w600,
                $(18),
              )
                  .visibility(
                    visible: maskVisible,
                    maintainState: true,
                    maintainSize: true,
                    maintainAnimation: true,
                  )
                  .intoContainer(margin: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight()))
                  .listenSizeChanged(onSizeChanged: (size) {
                setState(() {
                  headerHeight = size.height;
                });
              }),
              (maskVisible
                      ? buildTabBar()
                      : ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: buildTabBar(),
                          ),
                        ))
                  .listenSizeChanged(onSizeChanged: (size) {
                setState(() {
                  tabBarHeight = size.height;
                });
              }),
              SizedBox(height: headerHeight, width: 0),
            ]),
          ).intoContainer(height: headerHeight + tabBarHeight, color: Colors.transparent),
          Container(
            height: MediaQuery.of(context).padding.top,
            color: ColorConstant.BackgroundColor,
          ).visibility(visible: maskVisible),
        ],
      ),
    );
  }

  Container buildTabBar() {
    return Theme(
        data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
        child: TabBar(
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
        )).intoContainer(
      padding: EdgeInsets.symmetric(vertical: $(4)),
      height: $(44),
      color: Colors.transparent,
    );
  }

  Widget buildRefreshList() {
    return EasyRefresh(
        controller: _easyRefreshController,
        scrollController: scrollController,
        enableControlFinishRefresh: true,
        enableControlFinishLoad: false,
        emptyWidget: dataList.isEmpty ? TitleTextWidget('There are no posts yet', ColorConstant.White, FontWeight.normal, $(16)).intoCenter() : null,
        onRefresh: () async => onLoadFirstPage(),
        onLoad: () async => onLoadMorePage(),
        child: WaterfallFlow.builder(
          cacheExtent: ScreenUtil.screenSize.height,
          addAutomaticKeepAlives: false,
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: $(8),
          ),
          itemBuilder: (context, index) {
            var data = dataList[index];
            if (data.isAd) {
              return _buildMERCAd(data.page);
            }
            if (keyMap[index] == null) {
              keyMap[index] = GlobalKey<FutureLoadingImageState>();
            }
            return DiscoveryListCard(
              nsfwShown: effectManager.effectNsfw(data.data!.cartoonizeKey) && !nsfwOpen,
              imageKey: keyMap[index],
              data: data.data!,
              width: cardWidth,
              onNsfwTap: () => showOpenNsfwDialog(context).then((result) {
                if (result ?? false) {
                  setState(() {
                    nsfwOpen = true;
                    cacheManager.setBool(CacheManager.nsfwOpen, true);
                  });
                }
              }),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => DiscoveryEffectDetailScreen(discoveryEntity: dataList[index].data!),
                  settings: RouteSettings(name: "/DiscoveryEffectDetailScreen"),
                ),
              ),
              onLikeTap: () => userManager.doOnLogin(context, callback: () {
                onLikeTap(dataList[index].data!);
              }, autoExec: false),
            )
                .intoContainer(
                  margin: EdgeInsets.only(top: $(8)),
                )
                .offstage(offstage: !data.visible);
          },
          itemCount: dataList.length,
        )).intoContainer(
        margin: EdgeInsets.only(
      left: $(15),
      right: $(15),
      top: lastOffset != 0 ? tabBarHeight - lastOffset : tabBarHeight,
    ));
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildMERCAd(int page) {
    var showAds = isShowAdsNew();

    if (showAds) {
      var appBackground = thirdpartManager.appBackground;
      if (appBackground) {
        return const SizedBox();
      } else {
        var result = cardAdsMap.buildBannerAd(page);
        if (result != null) {
          return result.intoContainer(
            margin: EdgeInsets.only(top: $(8), bottom: $(8)),
            width: cardWidth,
            // height: cardWidth * adScale,
          );
        }
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
  bool visible;

  _ListData({
    this.isAd = false,
    this.data,
    required this.page,
    this.visible = true,
  });
}
