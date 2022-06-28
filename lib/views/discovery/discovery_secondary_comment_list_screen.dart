import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_comment_list_entity.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_comments_list_card.dart';
import 'package:cartoonizer/views/input/input_screen.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class DiscoverySecondaryCommentsListScreen extends StatefulWidget {
  DiscoveryCommentListEntity parentComment;

  DiscoverySecondaryCommentsListScreen({
    Key? key,
    required this.parentComment,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DiscoverySecondaryCommentsListState();
}

class DiscoverySecondaryCommentsListState extends AppState<DiscoverySecondaryCommentsListScreen> {
  UserManager userManager = AppDelegate.instance.getManager();
  EasyRefreshController _refreshController = EasyRefreshController();
  List<DiscoveryCommentListEntity> dataList = [];
  late DiscoveryCommentListEntity parentComment;
  int page = 0;
  int pageSize = 20;
  late CartoonizerApi api;

  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;

  DiscoverySecondaryCommentsListState() : super(canCancelOnLoading: false);

  @override
  void initState() {
    super.initState();
    api = CartoonizerApi().bindState(this);
    parentComment = widget.parentComment;
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
    delay(() => _refreshController.callRefresh());
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    _refreshController.dispose();
    onUnlikeEventListener.cancel();
    onLikeEventListener.cancel();
    onLoginEventListener.cancel();
  }

  loadFirstPage() => api
          .listDiscoveryComments(
        page: 0,
        pageSize: pageSize,
        socialPostId: parentComment.socialPostId,
        replySocialPostCommentId: parentComment.id,
      )
          .then((value) {
        _refreshController.finishRefresh();
        if (value != null) {
          page = 0;
          var list = value.getDataList<DiscoveryCommentListEntity>();
          setState(() {
            dataList = list;
          });
          _refreshController.finishLoad(noMore: dataList.length != pageSize);
        }
      });

  loadMorePage() => api
          .listDiscoveryComments(
        page: page + 1,
        pageSize: pageSize,
        socialPostId: parentComment.socialPostId,
        replySocialPostCommentId: parentComment.id,
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
    userManager.doOnLogin(context, callback: () {
      Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) => InputScreen(
              uniqueId: "${parentComment.socialPostId}_${replySocialPostCommentId ?? ''}",
              hint: userName != null ? 'reply $userName' : '',
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
      socialPostId: parentComment.socialPostId,
      replySocialPostCommentId: replySocialPostCommentId,
    );
    await hideLoading();
    if (baseEntity != null) {
      _refreshController.callRefresh();
    }
    return baseEntity != null;
  }

  onCommentLikeTap(DiscoveryCommentListEntity entity) {
    userManager.doOnLogin(context, callback: () {
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

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        heroTag: "comments_app_bar",
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(StringConstant.discoveryComments, ColorConstant.BtnTextColor, FontWeight.w600, $(18)),
      ),
      body: Column(
        children: [
          DiscoveryCommentsListCard(
            data: parentComment,
            isLast: true,
            type: CommentsListCardType.header,
            onLikeTap: () {
              onCommentLikeTap(parentComment);
            },
          ),
          Expanded(
              child: EasyRefresh.custom(
            controller: _refreshController,
            enableControlFinishRefresh: true,
            enableControlFinishLoad: false,
            onRefresh: () async => loadFirstPage(),
            onLoad: () async => loadMorePage(),
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => DiscoveryCommentsListCard(
                    data: dataList[index],
                    isLast: index == dataList.length - 1,
                    isTopComments: false,
                    onTap: () {
                      onCreateCommentClick(
                        replySocialPostCommentId: dataList[index].id,
                        userName: dataList[index].userName,
                      );
                    },
                    onLikeTap: () {
                      onCommentLikeTap(dataList[index]);
                    },
                  ).intoContainer(margin: EdgeInsets.only(top: index == 0 ? $(8) : 0)),
                  childCount: dataList.length,
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
            child: _function(context, Images.ic_discovery_comment, StringConstant.discoveryComment, onTap: () {
          onCreateCommentClick(userName: parentComment.userName, replySocialPostCommentId: parentComment.id);
        })),
        Expanded(
            child: _function(
          context,
          parentComment.likeId == null ? Images.ic_discovery_like : Images.ic_discovery_liked,
          parentComment.likeId == null ? StringConstant.discoveryLike : StringConstant.discoveryUnlike,
          iconColor: parentComment.likeId == null ? ColorConstant.White : ColorConstant.Red,
          onTap: () {
            onCommentLikeTap(parentComment);
          },
        )),
      ],
    ).intoMaterial(elevation: 2, color: ColorConstant.BackgroundColor);
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
}
