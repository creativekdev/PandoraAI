import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/admob/card_ads_holder.dart';
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
import 'package:flutter/gestures.dart';
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

class DiscoveryFragmentState extends AppState<DiscoveryFragment> with AutomaticKeepAliveClientMixin, AppTabState, TickerProviderStateMixin {
  late AppTabId tabId;
  EasyRefreshController _easyRefreshController = EasyRefreshController();
  UserManager userManager = AppDelegate.instance.getManager();
  EffectManager effectManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();
  late TabController tabController;
  late List<DiscoveryFilterTab> tabList = [
    DiscoveryFilterTab(sort: DiscoverySort.newest, title: 'Newest'),
    DiscoveryFilterTab(sort: DiscoverySort.likes, title: 'Popular'),
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
  late StreamSubscription onNewPostEventListener;

  bool listLoading = false;

  late CardAdsMap cardAdsMap;
  double cardWidth = 150;

  late ScrollController scrollController;
  double headerHeight = 0;
  double tabBarHeight = 0;
  double titleHeight = 0;
  bool firstLoad = true;
  late bool nsfwOpen;

  late AnimationController animationController;
  MyVerticalDragGestureRecognizer dragGestureRecognizer = MyVerticalDragGestureRecognizer();
  bool canBeDragged = true;
  late bool lastDragDirection = true;

  @override
  void initState() {
    super.initState();
    initAnimator();
    nsfwOpen = cacheManager.getBool(CacheManager.nsfwOpen);
    api = CartoonizerApi().bindState(this);
    tabId = widget.tabId;
    cardWidth = (ScreenUtil.screenSize.width - $(38)) / 2;
    onNsfwChangeListener = EventBusHelper().eventBus.on<OnEffectNsfwChangeEvent>().listen((event) {
      if (!mounted) return;
      setState(() {});
    });
    onLoginEventListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (!mounted) return;
      if (event.data ?? true && !listLoading) {
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
      if (!mounted) return;
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
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() {});
    });
    onTabDoubleClickListener = EventBusHelper().eventBus.on<OnTabDoubleClickEvent>().listen((event) {
      if (!mounted) return;
      if (tabId.id() == event.data && !listLoading) {
        _easyRefreshController.callRefresh();
      }
    });
    onCreateCommentListener = EventBusHelper().eventBus.on<OnCreateCommentEvent>().listen((event) {
      if (!mounted) return;
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
      if (!mounted) return;
      for (var value in dataList) {
        if (value.isAd && value.data!.id == event.data) {
          value.data!.removed = true;
          break;
        }
      }
      setState(() {});
    });
    onNewPostEventListener = EventBusHelper().eventBus.on<OnNewPostEvent>().listen((event) {
      if (!mounted) return;
      _easyRefreshController.callRefresh();
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
      scale: 1,
    );
    cardAdsMap.init();
    scrollController = ScrollController();
    delay(() => _easyRefreshController.callRefresh());
  }

  void initAnimator() {
    titleHeight = $(36);
    headerHeight = ScreenUtil.getStatusBarHeight() + $(80);
    dragGestureRecognizer.onDragStart = onDragStart;
    dragGestureRecognizer.onDragUpdate = onDragUpdate;
    dragGestureRecognizer.onDragEnd = onDragEnd;
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
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
    onNewPostEventListener.cancel();
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
    if (listLoading) {
      return;
    }
    currentTab = tabList[index];
    _easyRefreshController.callRefresh();
  }

  Future<void> addToDataList(int page, List<DiscoveryListEntity> list) async {
    if (!cardAdsMap.hasAdHolder(page + 1)) {
      cardAdsMap.addAdsCard(page + 1);
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
      }, milliseconds: 1000);
      _easyRefreshController.finishRefresh();
      if (value != null) {
        page = 0;
        dataList.clear();
        var list = value.getDataList<DiscoveryListEntity>();
        addToDataList(page, list).whenComplete(() {
          if (mounted) {
            setState(() {});
          }
        });
        _easyRefreshController.finishLoad(noMore: list.length != pageSize);
      }
      if (firstLoad) {
        if (mounted) {
          scrollController.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.linear);
        }
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

  onDragStart(DragStartDetails details) {
    canBeDragged = animationController.isDismissed || animationController.isCompleted;
  }

  onDragUpdate(DragUpdateDetails details) {
    if (canBeDragged) {
      double value = -details.primaryDelta! / titleHeight;
      if (value != 0) {
        lastDragDirection = value < 0;
      }
      animationController.value += value;
    }
  }

  onDragEnd(DragEndDetails details) {
    if (animationController.isDismissed || animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dy.abs() > 200) {
      double visualVelocity = details.velocity.pixelsPerSecond.dy / ScreenUtil.screenSize.height;
      animationController.fling(velocity: -visualVelocity);
    } else {
      if (lastDragDirection) {
        animationController.reverse();
      } else {
        animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return build2(context);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Listener(
          onPointerDown: (pointer) {
            dragGestureRecognizer.addPointer(pointer);
          },
          child: AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              double dy = titleHeight * animationController.value;
              return Transform.translate(
                  offset: Offset(0, -dy),
                  child: Stack(
                    children: [
                      Transform.translate(offset: Offset(0, -dy), child: buildRefreshList()),
                      buildHeader(),
                    ],
                  ));
            },
          ),
        ).intoContainer(height: ScreenUtil.screenSize.height + titleHeight),
      ),
    );
  }

  Widget buildHeader() {
    return ClipRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return Opacity(opacity: 1 - animationController.value, child: child);
                  },
                  child: TitleTextWidget(
                    StringConstant.tabDiscovery,
                    ColorConstant.BtnTextColor,
                    FontWeight.w600,
                    $(18),
                  ).intoContainer(height: titleHeight, padding: EdgeInsets.only(top: $(8))),
                ),
                buildTabBar(),
              ],
            ).intoContainer(padding: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight()), height: headerHeight, color: ColorConstant.BackgroundColorBlur)));
  }

  Widget buildTabBar() {
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
            ))
        .intoContainer(
          padding: EdgeInsets.symmetric(vertical: $(4)),
          height: $(44),
        )
        .ignore(ignoring: listLoading);
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
            collectGarbage: (List<int> list) {
              for (var value in list) {
                var data = dataList[value];
                if (data.isAd) {
                  cardAdsMap.disposeOne(data.page);
                }
              }
            },
          ),
          itemBuilder: (context, index) {
            var data = dataList[index];
            if (data.isAd) {
              return _buildMERCAd(data.page);
            }
            return DiscoveryListCard(
              nsfwShown: effectManager.effectNsfw(data.data!.cartoonizeKey) && !nsfwOpen,
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
                  margin: EdgeInsets.only(top: index < 2 ? $(16) : $(8)),
                )
                .offstage(offstage: !data.visible);
          },
          itemCount: dataList.length,
        )).intoContainer(
        margin: EdgeInsets.only(
      left: $(15),
      right: $(15),
      top: headerHeight,
      bottom: $(30),
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

class MyVerticalDragGestureRecognizer extends VerticalDragGestureRecognizer {
  bool needDrag = true;
  GestureDragStartCallback? onDragStart;
  GestureDragUpdateCallback? onDragUpdate;
  GestureDragEndCallback? onDragEnd;

  MyVerticalDragGestureRecognizer() {
    this.onStart = (details) {
      if (needDrag) {
        onDragStart?.call(details);
      }
    };
    this.onUpdate = (details) {
      if (needDrag) {
        onDragUpdate?.call(details);
      }
    };
    this.onEnd = (details) {
      if (needDrag) {
        onDragEnd?.call(details);
      }
    };
  }

  @override
  rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
