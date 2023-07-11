import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/indicator/line_tab_indicator.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/views/discovery/discovery_detail_screen.dart';
import 'package:cartoonizer/views/discovery/discovery_list_controller.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_list_card.dart';
import 'package:cartoonizer/views/discovery/widget/showReportMenu.dart';
import 'package:cartoonizer/views/social/metagram.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'widget/discovery_mg_list_card.dart';

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
  EasyRefreshController easyRefreshController = EasyRefreshController();
  DiscoveryListController listController = Get.find<DiscoveryListController>();
  late AppTabId tabId;

  double headerHeight = 0;
  double titleHeight = 0;

  late StreamSubscription onTabDoubleClickListener;
  late StreamSubscription onSwitchTabListener;
  late TabController tabController;
  final List<String> tabs = ['Discovery', 'Metagram'];

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'discovery_fragment');
    tabController = TabController(length: tabs.length, vsync: this);
    tabId = widget.tabId;
    onSwitchTabListener = EventBusHelper().eventBus.on<OnTabSwitchEvent>().listen((event) {
      if ((event.data?.length ?? 0) == 2) {
        if (event.data!.first == tabId.id()) {
          var pos = event.data!.last;
          tabController.index = pos;
          listController.isMetagram = pos == 1;
          easyRefreshController.callRefresh();
          calculateHeaderHeight();
          if (mounted) {
            setState(() {});
          }
        }
      }
    });
    onTabDoubleClickListener = EventBusHelper().eventBus.on<OnTabDoubleClickEvent>().listen((event) {
      if (tabId.id() == event.data && !listController.listLoading) {
        easyRefreshController.callRefresh();
      }
    });
    titleHeight = $(36);
    calculateHeaderHeight();
  }

  void calculateHeaderHeight() {
    if (listController.isMetagram) {
      headerHeight = ScreenUtil.getStatusBarHeight() + $(titleHeight) + $(6);
    } else {
      headerHeight = ScreenUtil.getStatusBarHeight() + $(titleHeight) + $(50);
    }
  }

  @override
  void onAttached() {
    super.onAttached();
    userManager.refreshUser();
  }

  @override
  dispose() {
    easyRefreshController.dispose();
    onTabDoubleClickListener.cancel();
    super.dispose();
  }

  onLikeTap(DiscoveryListEntity entity) {
    if (entity.likeId == null) {
      listController.api.discoveryLike(entity.id, source: 'discovery_page', style: getStyle(entity)).then((value) {});
    } else {
      listController.api.discoveryUnLike(entity.id, entity.likeId!).then((value) {
        hideLoading();
      });
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
      backgroundColor: Color(0xff161719),
      body: GetBuilder<DiscoveryListController>(
        init: Get.find<DiscoveryListController>(),
        builder: (listController) {
          return Stack(
            children: [
              buildRefreshList(listController),
              buildHeader(listController),
            ],
          ).intoContainer(
            height: ScreenUtil.screenSize.height,
            width: ScreenUtil.screenSize.width,
          );
        },
      ),
    );
  }

  Widget buildHeader(DiscoveryListController listController) {
    return ClipRect(
        child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Column(
        children: [
          Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: TabBar(
              isScrollable: true,
              indicator: LineTabIndicator(
                borderSide: BorderSide(width: 4.0, color: ColorConstant.DiscoveryBtn),
                strokeCap: StrokeCap.round,
                width: $(90),
              ),
              labelColor: Colors.white,
              labelStyle: TextStyle(fontWeight: FontWeight.w500),
              unselectedLabelColor: Colors.grey.shade400,
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
              tabs: tabs
                  .map((e) => Text(
                        e,
                        style: TextStyle(fontSize: $(18)),
                      ))
                  .toList(),
              padding: EdgeInsets.only(left: $(12), top: $(8), right: $(12), bottom: $(8)),
              controller: tabController,
              onTap: (index) {
                if (tabController.index != index) {
                  Events.discoveryTabClick(tab: tabs[index]);
                }
                listController.isMetagram = index == 1;
                easyRefreshController.callRefresh();
                setState(() {
                  calculateHeaderHeight();
                });
              },
            ),
          ).intoContainer(width: ScreenUtil.screenSize.width, alignment: Alignment.center),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: $(15)),
            child: Row(
              children: listController.tags.transfer((e, index) {
                bool checked = listController.currentTag == e;
                return Text(
                  e.title,
                  style: TextStyle(
                    color: checked ? Color(0xff3e60ff) : Colors.white,
                    fontSize: $(13),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                )
                    .intoContainer(
                  margin: EdgeInsets.only(left: index == 0 ? 0 : $(6)),
                  padding: EdgeInsets.symmetric(horizontal: $(12), vertical: $(7)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: checked ? Colors.transparent : Color(0xFF37373B),
                    border: Border.all(color: checked ? ColorConstant.DiscoveryBtn : Colors.transparent, width: 1),
                  ),
                )
                    .intoGestureDetector(onTap: () {
                  if (listController.listLoading) {
                    return;
                  }
                  if (listController.currentTag == e) {
                    listController.currentTag = null;
                  } else {
                    listController.currentTag = e;
                  }
                  easyRefreshController.callRefresh();
                });
              }),
            ),
          ).intoContainer(height: $(44), alignment: Alignment.center, padding: EdgeInsets.only(bottom: $(8))).visibility(visible: !listController.isMetagram),
        ],
      ),
    ).intoContainer(
      padding: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight()),
      height: headerHeight,
      color: ColorConstant.BackgroundColorBlur,
    )).ignore(ignoring: listController.listLoading);
    // .intoGestureDetector(onTap: () {
    //   listController.scrollController.jumpTo(0);
    // });
  }

  Widget buildRefreshList(DiscoveryListController listController) {
    return EasyRefresh.custom(
      controller: easyRefreshController,
      scrollController: listController.scrollController,
      enableControlFinishRefresh: true,
      enableControlFinishLoad: false,
      cacheExtent: 1000,
      emptyWidget: listController.dataList.isEmpty ? TitleTextWidget('There are no posts yet', ColorConstant.White, FontWeight.normal, $(16)).intoCenter() : null,
      onRefresh: () async {
        listController.onLoadFirstPage().then((value) {
          easyRefreshController.finishRefresh();
          easyRefreshController.finishLoad(noMore: value);
        });
      },
      onLoad: () async {
        listController.onLoadMorePage().then((value) {
          easyRefreshController.finishLoad(noMore: value);
        });
      },
      slivers: [
        (listController.isMetagram)
            ? SliverWaterfallFlow(
                gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: $(15),
                  // mainAxisSpacing: $(15),
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var data = listController.dataList[index];
                    if (data.data is SocialPostPageEntity) {
                      return DiscoveryMgListCard(
                        width: (ScreenUtil.screenSize.width - $(45)) / 2,
                        data: data.data! as SocialPostPageEntity,
                        onTap: () {
                          Metagram.open(context, source: 'discovery_page', socialPostPage: data.data!);
                        },
                      ).marginOnly(top: $(15));
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                  childCount: listController.dataList.length,
                ))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var data = listController.dataList[index];
                  if (data.data is DiscoveryListEntity) {
                    if (data.visible) {
                      return Obx(() => DiscoveryListCard(
                            data: data.data! as DiscoveryListEntity,
                            liked: data.liked.value,
                            hasLine: index != 0,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => DiscoveryDetailScreen(discoveryEntity: data.data!, prePage: 'discovery'),
                                  settings: RouteSettings(name: "/DiscoveryDetailScreen"),
                                ),
                              );
                            },
                            longPressCallback: (olpdt) async {
                              PopmenuUtil.showPopMenu(
                                  context,
                                  olpdt,
                                  LongPressItem(
                                      text: S.of(context).Report,
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        listController.onLongPressAction(data.data, context);
                                      }));
                            },
                            onCommentTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => DiscoveryDetailScreen(discoveryEntity: data.data!, prePage: 'discovery', autoComment: true),
                                  settings: RouteSettings(name: "/DiscoveryDetailScreen"),
                                ),
                              );
                            },
                            onLikeTap: (liked) async {
                              if (userManager.isNeedLogin) {
                                userManager.doOnLogin(context, logPreLoginAction: data.data!.likeId == null ? 'pre_discovery_like' : 'pre_discovery_unlike');
                                return liked;
                              }
                              bool result;
                              listController.likeLocalAddAlready.value = true;
                              if (liked) {
                                data.data!.likes--;
                                listController.api.discoveryUnLike(data.data!.id, data.data!.likeId!).then((value) {
                                  if (value == null) {
                                    listController.likeLocalAddAlready.value = false;
                                  }
                                });
                                result = false;
                                data.liked.value = false;
                              } else {
                                data.data!.likes++;
                                listController.api.discoveryLike(data.data!.id, source: 'discovery_page', style: getStyle(data.data!)).then((value) {
                                  if (value == null) {
                                    listController.likeLocalAddAlready.value = false;
                                  }
                                });
                                result = true;
                                data.liked.value = true;
                              }
                              return result;
                            },
                            ignoreLikeBtn: listController.likeLocalAddAlready.value,
                          ));
                    } else {
                      return SizedBox.shrink();
                    }
                  } else {
                    return SizedBox.shrink();
                  }
                },
                childCount: listController.dataList.length,
              )),
      ],
    ).intoContainer(
      margin: EdgeInsets.only(
        top: headerHeight,
        left: ((listController.isMetagram) ? $(15) : 0),
        right: ((listController.isMetagram) ? $(15) : 0),
      ),
    );
  }

  String getStyle(
    DiscoveryListEntity discoveryEntity,
  ) {
    var style = discoveryEntity.getStyle(context);
    return style ?? '';
  }

  @override
  bool get wantKeepAlive => true;
}
