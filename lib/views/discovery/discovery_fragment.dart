import 'dart:ui';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/discovery_list_controller.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/admob/card_ads_widget.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/enums/ad_type.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/discovery/discovery_effect_detail_screen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
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
  UserManager userManager = AppDelegate.instance.getManager();
  EffectManager effectManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();
  late DiscoveryListController listController;

  double headerHeight = 0;
  double tabBarHeight = 0;
  double titleHeight = 0;
  late bool nsfwOpen;

  late AnimationController animationController;
  MyVerticalDragGestureRecognizer dragGestureRecognizer = MyVerticalDragGestureRecognizer();
  bool canBeDragged = true;
  late bool lastDragDirection = true;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'discovery_fragment');
    initAnimator();
    nsfwOpen = cacheManager.getBool(CacheManager.nsfwOpen);
    listController = Get.put(DiscoveryListController(
      ticker: this,
      tabId: widget.tabId,
    ));
    delay(
      () {
        listController.tabList = [
          DiscoveryFilterTab(sort: DiscoverySort.newest, title: S.of(context).newest),
          DiscoveryFilterTab(sort: DiscoverySort.likes, title: S.of(context).popular),
        ];
        listController.update();
      },
    );
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
    animationController.dispose();
  }

  @override
  void onAttached() {
    super.onAttached();
    userManager.refreshUser();
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    cacheManager.setInt('${CacheManager.keyLastTabAttached}_${listController.tabId.id()}', currentTime);
    var nsfw = cacheManager.getBool(CacheManager.nsfwOpen);
    if (nsfwOpen != nsfw) {
      setState(() {
        nsfwOpen = nsfw;
      });
    }
  }

  onLikeTap(DiscoveryListEntity entity) {
    if (entity.likeId == null) {
      listController.api.discoveryLike(entity.id, source: listController.currentTab.sort.value(), style: getStyle(entity)).then((value) {
        hideLoading();
      });
    } else {
      listController.api.discoveryUnLike(entity.id, entity.likeId!).then((value) {
        hideLoading();
      });
    }
  }

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
      body: GetBuilder<DiscoveryListController>(
        init: listController,
        builder: (listController) {
          return SingleChildScrollView(
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
                          Transform.translate(offset: Offset(0, -dy), child: buildRefreshList(listController)),
                          buildHeader(listController),
                        ],
                      ));
                },
              ),
            ).intoContainer(height: ScreenUtil.screenSize.height + titleHeight),
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
                AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return Opacity(opacity: 1 - animationController.value, child: child);
                  },
                  child: TitleTextWidget(
                    S.of(context).tabDiscovery,
                    ColorConstant.BtnTextColor,
                    FontWeight.w600,
                    $(18),
                  ).intoContainer(height: titleHeight, padding: EdgeInsets.only(top: $(8))),
                ),
                buildTabBar(listController),
              ],
            ).intoContainer(padding: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight()), height: headerHeight, color: ColorConstant.BackgroundColorBlur)));
  }

  Widget buildTabBar(DiscoveryListController listController) {
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
              controller: listController.tabController,
              tabs: listController.tabList.map((e) => Text(e.title).intoContainer(padding: EdgeInsets.symmetric(vertical: $(6)))).toList(),
              onTap: (index) {
                listController.onTabClick(index);
              },
              padding: EdgeInsets.zero,
            ))
        .intoContainer(
          padding: EdgeInsets.symmetric(vertical: $(4)),
          height: $(44),
        )
        .ignore(ignoring: listController.listLoading);
  }

  Widget buildRefreshList(DiscoveryListController listController) {
    return EasyRefresh(
        controller: listController.easyRefreshController,
        scrollController: listController.scrollController,
        enableControlFinishRefresh: true,
        enableControlFinishLoad: false,
        emptyWidget: listController.dataList.isEmpty ? TitleTextWidget('There are no posts yet', ColorConstant.White, FontWeight.normal, $(16)).intoCenter() : null,
        onRefresh: () async => listController.onLoadFirstPage(),
        onLoad: () async => listController.onLoadMorePage(),
        child: WaterfallFlow.builder(
          cacheExtent: ScreenUtil.screenSize.height,
          addAutomaticKeepAlives: false,
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: $(8),
          ),
          itemBuilder: (context, index) {
            var data = listController.dataList[index];
            if (data.isAd) {
              return _buildMERCAd(listController, data.page);
            }
            if (data.data?.removed ?? false) {
              return Container();
            }
            return DiscoveryListCard(
              nsfwShown: effectManager.effectNsfw(data.data!.cartoonizeKey) && !nsfwOpen,
              data: data.data!,
              width: listController.cardWidth,
              onNsfwTap: () {
                showOpenNsfwDialog(context).then((result) {
                  if (result ?? false) {
                    setState(() {
                      nsfwOpen = true;
                      cacheManager.setBool(CacheManager.nsfwOpen, true);
                    });
                  }
                });
              },
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      DiscoveryEffectDetailScreen(discoveryEntity: listController.dataList[index].data!, prePage: 'discovery', dataType: listController.currentTab.sort.value()),
                  settings: RouteSettings(name: "/DiscoveryEffectDetailScreen"),
                ),
              ),
              onLikeTap: () => userManager
                  .doOnLogin(context, logPreLoginAction: listController.dataList[index].data!.likeId == null ? 'pre_discovery_like' : 'pre_discovery_unlike', callback: () {
                onLikeTap(listController.dataList[index].data!);
              }, autoExec: false),
            )
                .intoContainer(
                  margin: EdgeInsets.only(top: index < 2 ? $(16) : $(8)),
                )
                .offstage(offstage: !data.visible);
          },
          itemCount: listController.dataList.length,
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

  Widget _buildMERCAd(DiscoveryListController listController, int page) {
    var showAds = isShowAdsNew(type: AdType.card);

    if (showAds) {
      var appBackground = thirdpartManager.appBackground;
      if (appBackground) {
        return const SizedBox();
      } else {
        return CardAdsWidget(type: 'discovery', width: listController.cardWidth, height: listController.cardWidth, page: page);
      }
    }
    return Container();
  }

  String getStyle(
    DiscoveryListEntity discoveryEntity,
  ) {
    if (discoveryEntity.category == DiscoveryCategory.cartoonize.name) {
      EffectDataController effectDataController = Get.find();
      if (effectDataController.data == null) {
        return '';
      }
      String key = discoveryEntity.cartoonizeKey;
      int tabPos = effectDataController.data!.tabPos(key);
      if (tabPos == -1) {
        CommonExtension().showToast(S.of(context).template_not_available);
        return '';
      }
      var targetSeries = effectDataController.data!.targetSeries(key)!;
      EffectModel? effectModel;
      EffectItem? effectItem;
      int index = 0;
      for (int i = 0; i < targetSeries.value.length; i++) {
        if (effectModel != null) {
          break;
        }
        var model = targetSeries.value[i];
        var list = model.effects.values.toList();
        for (int j = 0; j < list.length; j++) {
          var item = list[j];
          if (item.key == key) {
            effectModel = model;
            effectItem = item;
            index = i;
            break;
          }
        }
      }
      if (effectItem == null) {
        CommonExtension().showToast(S.of(context).template_not_available);
        return '';
      }
      return 'facetoon-${effectItem.key}';
    } else if (discoveryEntity.category == DiscoveryCategory.ai_avatar.name) {
      return 'avatar';
    } else if (discoveryEntity.category == DiscoveryCategory.another_me.name) {
      return 'metaverse';
    }
    return '';
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
