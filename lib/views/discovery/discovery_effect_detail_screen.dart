import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/discovery_comment_list_entity.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_effect_detail_widget.dart';
import 'package:cartoonizer/views/input/input_screen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class DiscoveryEffectDetailScreen extends StatefulWidget {
  DiscoveryListEntity discoveryEntity;
  String prePage;
  String dataType;

  DiscoveryEffectDetailScreen({
    Key? key,
    required this.discoveryEntity,
    required this.prePage,
    required this.dataType,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DiscoveryEffectDetailScreenState();
}

class DiscoveryEffectDetailScreenState extends AppState<DiscoveryEffectDetailScreen> with LoadingAction {
  UserManager userManager = AppDelegate.instance.getManager();
  EasyRefreshController _refreshController = EasyRefreshController();
  List<DiscoveryCommentListEntity> dataList = [];
  late DiscoveryListEntity discoveryEntity;
  int page = 0;
  int pageSize = 20;
  late CartoonizerApi api;

  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  late StreamSubscription onDiscoveryLikeEventListener;
  late StreamSubscription onDiscoveryUnlikeEventListener;
  late StreamSubscription onCreateCommentListener;
  late ScrollController scrollController;
  late String prePage;
  late String dataType;
  bool enableLoad = false;
  String style = '';

  DiscoveryEffectDetailScreenState() : super(canCancelOnLoading: false);

  @override
  showLoadingBar() => showLoading();

  @override
  hideLoadingBar() => hideLoading();

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'discovery_detail_screen');
    prePage = widget.prePage;
    dataType = widget.dataType;
    scrollController = ScrollController();
    api = CartoonizerApi().bindState(this);
    discoveryEntity = widget.discoveryEntity.copy();
    onLoginEventListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (event.data ?? true) {
        _refreshController.callRefresh();
      } else {
        for (var value in dataList) {
          value.likeId = null;
        }
        setState(() {});
      }
    });
    onLikeEventListener = EventBusHelper().eventBus.on<OnCommentLikeEvent>().listen((event) {
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
    onUnlikeEventListener = EventBusHelper().eventBus.on<OnCommentUnlikeEvent>().listen((event) {
      for (var data in dataList) {
        if (data.id == event.data) {
          data.likeId = null;
          data.likes--;
          setState(() {});
        }
      }
    });
    onDiscoveryLikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryLikeEvent>().listen((event) {
      if (discoveryEntity.id == event.data!.key) {
        discoveryEntity.likes++;
        discoveryEntity.likeId = event.data!.value;
        setState(() {});
      }
    });
    onDiscoveryUnlikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryUnlikeEvent>().listen((event) {
      if (discoveryEntity.id == event.data) {
        discoveryEntity.likes--;
        discoveryEntity.likeId = null;
        setState(() {});
      }
    });
    onCreateCommentListener = EventBusHelper().eventBus.on<OnCreateCommentEvent>().listen((event) {
      if (event.data![0] == discoveryEntity.id) {
        discoveryEntity.comments++;
        setState(() {});
      } else if ((event.data?.length ?? 0) > 1) {
        for (var value in dataList) {
          if (value.id == event.data![1]) {
            value.comments++;
            break;
          }
        }
        setState(() {});
      }
    });
    logLoading();
    delay(() => loadFirstPage());
  }

  @override
  void dispose() {
    api.unbind();
    _refreshController.dispose();
    onUnlikeEventListener.cancel();
    onLikeEventListener.cancel();
    onLoginEventListener.cancel();
    onDiscoveryLikeEventListener.cancel();
    onDiscoveryUnlikeEventListener.cancel();
    onCreateCommentListener.cancel();
    super.dispose();
  }

  loadFirstPage() => api
          .listDiscoveryComments(
        from: 0,
        pageSize: pageSize,
        socialPostId: discoveryEntity.id,
      )
          .then((value) {
        _refreshController.finishRefresh();
        if (value != null) {
          page = 0;
          var list = value.getDataList<DiscoveryCommentListEntity>();
          if (mounted) {
            setState(() {
              dataList = list;
              enableLoad = dataList.length == pageSize;
            });
          }
          _refreshController.finishLoad(noMore: dataList.length != pageSize);
        }
      });

  loadMorePage() => api
          .listDiscoveryComments(
        from: (page + 1) * pageSize,
        pageSize: pageSize,
        socialPostId: discoveryEntity.id,
      )
          .then((value) {
        if (value == null) {
          _refreshController.finishLoad(noMore: false);
        } else {
          page++;
          var list = value.getDataList<DiscoveryCommentListEntity>();
          setState(() {
            dataList.addAll(list);
          });
          _refreshController.finishLoad(noMore: list.length != pageSize);
        }
      });

  onCreateCommentClick({int? replySocialPostCommentId, String? userName}) {
    userManager.doOnLogin(context, logPreLoginAction: 'pre_create_comment', callback: () {
      Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) => InputScreen(
              uniqueId: "${discoveryEntity.id}_${replySocialPostCommentId ?? ''}",
              hint: userName != null ? '${S.of(context).reply} $userName' : '',
              callback: (text) async {
                return createComment(text, replySocialPostCommentId);
              },
            ),
          ));
    });
  }

  Future<bool> createComment(String comment, int? replySocialPostCommentId) async {
    await showLoading();
    var baseEntity = await api.createDiscoveryComment(
        comment: comment,
        source: dataType,
        style: style,
        socialPostId: discoveryEntity.id,
        replySocialPostCommentId: replySocialPostCommentId,
        onUserExpired: () {
          userManager.doOnLogin(context, logPreLoginAction: 'token_expired');
        });
    await hideLoading();
    if (baseEntity != null) {
      CommonExtension().showToast('Comment posted');
      delay(() => _refreshController.callRefresh(), milliseconds: 64);
    }
    return baseEntity != null;
  }

  onCommentLikeTap(DiscoveryCommentListEntity entity) {
    userManager.doOnLogin(context, logPreLoginAction: entity.likeId == null ? 'pre_comment_like' : 'pre_comment_unlike', callback: () {
      showLoading().whenComplete(() {
        if (entity.likeId == null) {
          api.commentLike(entity.id).then((value) {
            hideLoading();
          });
        } else {
          api.commentUnLike(entity.id, entity.likeId!).then((value) {
            hideLoading();
          });
        }
      });
    }, autoExec: false);
  }

  onDiscoveryLikeTap() {
    userManager.doOnLogin(context, logPreLoginAction: discoveryEntity.likeId == null ? 'pre_discovery_like' : 'pre_discovery_unlike', callback: () {
      showLoading().whenComplete(() {
        if (discoveryEntity.likeId == null) {
          api
              .discoveryLike(
            discoveryEntity.id,
            style: style,
            source: dataType,
          )
              .then((value) {
            hideLoading();
          });
        } else {
          api.discoveryUnLike(discoveryEntity.id, discoveryEntity.likeId!).then((value) {
            hideLoading();
          });
        }
      });
    }, autoExec: false);
  }

  logLoading() {
    if (discoveryEntity.category == DiscoveryCategory.cartoonize.name) {
      EffectDataController effectDataController = Get.find();
      if (effectDataController.data == null) {
        return;
      }
      String key = discoveryEntity.cartoonizeKey;
      int tabPos = effectDataController.data!.tabPos(key);
      if (tabPos == -1) {
        CommonExtension().showToast(S.of(context).template_not_available);
        return;
      }
      EffectCategory effectModel = effectDataController.data!.findCategory(key)!;
      EffectItem effectItem = effectModel.effects.pick((t) => t.key == key)!;
      style = 'facetoon-${effectItem.key}';
    } else if (discoveryEntity.category == DiscoveryCategory.ai_avatar.name) {
      style = 'avatar';
    } else if (discoveryEntity.category == DiscoveryCategory.another_me.name) {
      style = 'metaverse';
    } else if (discoveryEntity.category == DiscoveryCategory.txt2img.name) {
      style = 'txt2img';
    }
    if (TextUtil.isEmpty(style)) {
      return;
    }
    Events.discoveryDetailLoading(source: dataType, style: style);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppNavigationBar(
        backgroundColor: Colors.black,
        middle: TitleTextWidget(S.of(context).discoveryDetails, ColorConstant.BtnTextColor, FontWeight.w600, $(18)),
        trailing: TitleTextWidget(S.of(context).delete, ColorConstant.BtnTextColor, FontWeight.w600, $(15)).intoGestureDetector(onTap: () {
          showDeleteDialog();
        }).visibility(visible: userManager.user?.id == discoveryEntity.userId),
      ),
      body: Column(
        children: [
          Expanded(
              child: EasyRefresh.custom(
            controller: _refreshController,
            scrollController: scrollController,
            enableControlFinishRefresh: true,
            enableControlFinishLoad: enableLoad,
            onRefresh: () async => loadFirstPage(),
            onLoad: enableLoad ? () async => loadMorePage() : null,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (i == 0) {
                      return DiscoveryEffectDetailWidget(
                        data: discoveryEntity,
                        loadingAction: this,
                        onCommentTap: () {
                          onCreateCommentClick();
                        },
                        source: prePage + '-discovery',
                        dataType: dataType,
                        style: style,
                      );
                    } else {
                      var index = i - 1;
                      return Container();
                      // return DiscoveryCommentsListCard(
                      //   data: dataList[index],
                      //   isLast: index == dataList.length - 1,
                      //   isTopComments: true,
                      //   onTap: () {
                      //     onCreateCommentClick(
                      //       replySocialPostCommentId: dataList[index].id,
                      //       userName: dataList[index].userName,
                      //     );
                      //   },
                      //   onLikeTap: () {
                      //     onCommentLikeTap(dataList[index]);
                      //   },
                      //   onCommentTap: () {
                      //
                      //   },
                      // ).intoContainer(margin: EdgeInsets.only(top: index == 0 ? $(8) : 0));
                    }
                  },
                  childCount: dataList.length + 1,
                ),
              )
            ],
          ).intoContainer(color: Colors.black)),
          footer(context),
        ],
      ),
    );
  }

  Widget footer(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _function(context, Images.ic_discovery_comment, S.of(context).discoveryComment, onTap: () {
          onCreateCommentClick(userName: discoveryEntity.userName);
        })),
        Expanded(
            child: _function(
          context,
          discoveryEntity.likeId == null ? Images.ic_discovery_like : Images.ic_discovery_liked,
          discoveryEntity.likeId == null ? S.of(context).discoveryLike : S.of(context).discoveryUnlike,
          iconColor: discoveryEntity.likeId == null ? ColorConstant.White : ColorConstant.Red,
          onTap: () {
            onDiscoveryLikeTap();
          },
        )),
      ],
    )
        .intoContainer(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        )
        .intoMaterial(elevation: 2, color: ColorConstant.DiscoveryCommentBackground);
  }

  Widget _function(BuildContext context, String imgRes, String text, {GestureTapCallback? onTap, Color iconColor = ColorConstant.White}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          imgRes,
          width: $(18),
          color: iconColor,
        ),
        SizedBox(width: $(6)),
        TitleTextWidget(text, ColorConstant.White, FontWeight.normal, $(14)),
      ],
    ).intoContainer(padding: EdgeInsets.all($(16))).intoGestureDetector(onTap: onTap);
  }

  showDeleteDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(context).are_you_sure_to_delete_this_post,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: ColorConstant.White),
                ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      S.of(context).delete,
                      style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.red),
                    )
                            .intoContainer(
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border(
                                  top: BorderSide(color: ColorConstant.LineColor, width: 1),
                                  right: BorderSide(color: ColorConstant.LineColor, width: 1),
                                )))
                            .intoGestureDetector(onTap: () async {
                      Navigator.pop(context);
                      delete();
                    })),
                    Expanded(
                        child: Text(
                      S.of(context).cancel,
                      style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
                    )
                            .intoContainer(
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border(
                                  top: BorderSide(color: ColorConstant.LineColor, width: 1),
                                )))
                            .intoGestureDetector(onTap: () {
                      Navigator.pop(context);
                    })),
                  ],
                ),
              ],
            )
                .intoMaterial(
                  color: ColorConstant.EffectFunctionGrey,
                  borderRadius: BorderRadius.circular($(16)),
                )
                .intoContainer(
                  padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
                  margin: EdgeInsets.symmetric(horizontal: $(35)),
                )
                .intoCenter());
  }

  delete() {
    showLoading().whenComplete(() {
      api.deleteDiscovery(discoveryEntity.id).then((value) {
        hideLoading().whenComplete(() {
          if (value != null) {
            CommonExtension().showToast(S.of(context).delete_succeed);
            Navigator.of(context).pop();
          }
        });
      });
    });
  }
}

abstract class LoadingAction {
  Future<void> showLoadingBar();

  Future<void> hideLoadingBar();
}
