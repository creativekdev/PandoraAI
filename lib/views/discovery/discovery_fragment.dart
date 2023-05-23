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
import 'package:cartoonizer/views/discovery/discovery_detail_screen.dart';
import 'package:cartoonizer/views/discovery/discovery_effect_detail_screen.dart';
import 'package:cartoonizer/views/discovery/discovery_list_controller.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_list_card.dart';
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
  DiscoveryListController listController = Get.find<DiscoveryListController>();
  late AppTabId tabId;

  double headerHeight = 0;
  double titleHeight = 0;

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
    headerHeight = ScreenUtil.getStatusBarHeight() + $(titleHeight) + $(48);
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

  onLikeTap(DiscoveryListEntity entity) {
    if (entity.likeId == null) {
      listController.api.discoveryLike(entity.id, source: 'discovery_page', style: getStyle(entity)).then((value) {});
    } else {
      listController.api.discoveryUnLike(entity.id, entity.likeId!).then((value) {
        hideLoading();
      });
    }
  }

  // onCommentTap(DiscoveryListEntity entity) {
  //   Navigator.push(
  //       context,
  //       PageRouteBuilder(
  //         opaque: false,
  //         pageBuilder: (context, animation, secondaryAnimation) => InputScreen(
  //           uniqueId: "${entity.id}}",
  //           hint: '${S.of(context).reply} ${entity.userName}',
  //           callback: (text) async {
  //             return createComment(entity, text);
  //           },
  //         ),
  //       ));
  // }

  Future<bool> createComment(DiscoveryListEntity entity, String comment) async {
    await showLoading();
    var baseEntity = await CartoonizerApi().createDiscoveryComment(
        comment: comment,
        source: DiscoverySort.newest.value(),
        style: getStyle(entity),
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
          TitleTextWidget(
            S.of(context).tabDiscovery,
            ColorConstant.BtnTextColor,
            FontWeight.w600,
            $(18),
          ).intoContainer(alignment: Alignment.center, height: titleHeight, padding: EdgeInsets.only(top: $(4))),
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
                    color: Color(0xff1b1b1b),
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
          ).intoContainer(height: $(48), alignment: Alignment.center, padding: EdgeInsets.only(bottom: $(8))),
        ],
      ),
    ).intoContainer(
      padding: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight()),
      height: headerHeight,
      color: ColorConstant.BackgroundColorBlur,
    )).intoGestureDetector(onTap: () {
      listController.scrollController.jumpTo(0);
    });
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
              return Obx(() => DiscoveryListCard(
                    data: data.data!,
                    liked: data.liked.value,
                    hasLine: index != 0,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => DiscoveryDetailScreen(discoveryEntity: data.data!, prePage: 'discovery', dataType: DiscoverySort.newest.value()),
                          settings: RouteSettings(name: "/DiscoveryDetailScreen"),
                        ),
                      );
                    },
                    onCommentTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              DiscoveryDetailScreen(discoveryEntity: data.data!, prePage: 'discovery', dataType: DiscoverySort.newest.value(), autoComment: true),
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
          },
          childCount: listController.dataList.length,
        ))
      ],
    ).intoContainer(margin: EdgeInsets.only(top: headerHeight));
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
