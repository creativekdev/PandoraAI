import 'dart:ui';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';
import 'package:cartoonizer/views/discovery/discovery_effect_detail_screen.dart';
import 'package:cartoonizer/views/discovery/discovery_list_controller.dart';
import 'package:cartoonizer/views/discovery/widget/new_discovery_list_card.dart';
import 'package:cartoonizer/views/input/input_screen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
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
  EasyRefreshController easyRefreshController = EasyRefreshController();
  DiscoveryListController listController = Get.put(DiscoveryListController());
  late AppTabId tabId;

  double headerHeight = 0;
  double titleHeight = 0;

  late AnimationController animationController;
  MyVerticalDragGestureRecognizer dragGestureRecognizer = MyVerticalDragGestureRecognizer();
  bool canBeDragged = true;
  late bool lastDragDirection = true;
  late StreamSubscription onTabDoubleClickListener;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'discovery_fragment');
    tabId = widget.tabId;
    // If the tab ID matches the event data and the list is not loading, call the EasyRefresh controller's callRefresh() method.
    onTabDoubleClickListener = EventBusHelper().eventBus.on<OnTabDoubleClickEvent>().listen((event) {
      if (tabId.id() == event.data && !listController.listLoading) {
        easyRefreshController.callRefresh();
      }
    });
    initAnimator();
  }

  void initAnimator() {
    titleHeight = $(36);
    headerHeight = ScreenUtil.getStatusBarHeight() + $(titleHeight);
    dragGestureRecognizer.onDragStart = onDragStart;
    dragGestureRecognizer.onDragUpdate = onDragUpdate;
    dragGestureRecognizer.onDragEnd = onDragEnd;
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
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
    // animationController.dispose();
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

  onLikeTap(DiscoveryListEntity entity) {
    if (entity.likeId == null) {
      listController.api.discoveryLike(entity.id, source: 'discovery_page', style: getStyle(entity)).then((value) {});
    } else {
      listController.api.discoveryUnLike(entity.id, entity.likeId!).then((value) {
        hideLoading();
      });
    }
  }

  onCommentTap(DiscoveryListEntity entity) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) => InputScreen(
            uniqueId: "${entity.id}}",
            hint: '${S.of(context).reply} ${entity.userName}',
            callback: (text) async {
              return createComment(entity, text);
            },
          ),
        ));
  }

  Future<bool> createComment(DiscoveryListEntity entity, String comment) async {
    await showLoading();
    var baseEntity = await CartoonizerApi().createDiscoveryComment(
        comment: comment,
        source: DiscoverySort.newest.value(),
        style: getStyle(entity) ?? '',
        socialPostId: entity.id,
        onUserExpired: () {
          userManager.doOnLogin(context, logPreLoginAction: 'token_expired');
        });
    await hideLoading();
    if (baseEntity != null) {
      CommonExtension().showToast('Comment posted');
      setState(() {
        entity.comments++;
      });
    }
    return baseEntity != null;
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
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Opacity(opacity: 1 - animationController.value, child: child);
              },
              child: TitleTextWidget(
                S.of(context).tabDiscovery,
                ColorConstant.BtnTextColor,
                FontWeight.w600,
                $(18),
              ).intoContainer(alignment: Alignment.center, height: titleHeight, padding: EdgeInsets.only(top: $(4))),
            ).intoContainer(padding: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight()), height: headerHeight, color: ColorConstant.BackgroundColorBlur)));
  }

  Widget buildRefreshList(DiscoveryListController listController) {
    return EasyRefresh.custom(
      controller: easyRefreshController,
      scrollController: listController.scrollController,
      enableControlFinishRefresh: true,
      enableControlFinishLoad: false,
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
        SliverList(
            delegate: SliverChildBuilderDelegate(
          (context, index) {
            var data = listController.dataList[index];
            if (data.visible) {
              return NewDiscoveryListCard(
                data: data.data!,
                hasLine: index != 0,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          DiscoveryEffectDetailScreen(discoveryEntity: listController.dataList[index].data!, prePage: 'discovery', dataType: DiscoverySort.newest.value()),
                      settings: RouteSettings(name: "/DiscoveryEffectDetailScreen"),
                    ),
                  );
                },
                onCommentTap: () => userManager
                    .doOnLogin(context, logPreLoginAction: listController.dataList[index].data!.likeId == null ? 'pre_discovery_like' : 'pre_discovery_unlike', callback: () {
                  onCommentTap(listController.dataList[index].data!);
                }, autoExec: true),
                onLikeTap: () => userManager
                    .doOnLogin(context, logPreLoginAction: listController.dataList[index].data!.likeId == null ? 'pre_discovery_like' : 'pre_discovery_unlike', callback: () {
                  onLikeTap(listController.dataList[index].data!);
                }, autoExec: false),
              );
            } else {
              return SizedBox.shrink();
            }
          },
          childCount: listController.dataList.length,
        ))
      ],
    ).intoContainer(
        margin: EdgeInsets.only(
      top: headerHeight,
      bottom: $(30),
    ));
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
    } else if (discoveryEntity.category == DiscoveryCategory.txt2img.name) {
      return 'txt2img';
    }
    return '';
  }

  @override
  bool get wantKeepAlive => true;
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
