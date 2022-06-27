import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_comment_list_entity.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_comments_list_card.dart';
import 'package:cartoonizer/views/input/input_screen.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class DiscoveryCommentsListScreen extends StatefulWidget {
  int socialPostId;
  String userName;
  DiscoveryCommentListEntity? parentComment;

  DiscoveryCommentsListScreen({
    Key? key,
    required this.socialPostId,
    required this.userName,
    this.parentComment,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DiscoveryCommentsListState();
}

class DiscoveryCommentsListState extends AppState<DiscoveryCommentsListScreen> {
  EasyRefreshController _refreshController = EasyRefreshController();
  List<DiscoveryCommentListEntity> dataList = [];
  late String userName;
  late int socialPostId;
  DiscoveryCommentListEntity? parentComment;
  int page = 0;
  int pageSize = 20;
  late CartoonizerApi api;

  DiscoveryCommentsListState() : super(canCancelOnLoading: false);

  @override
  void initState() {
    super.initState();
    api = CartoonizerApi().bindState(this);
    parentComment = widget.parentComment;
    socialPostId = widget.socialPostId;
    userName = widget.userName;
    delay(() => _refreshController.callRefresh());
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    _refreshController.dispose();
  }

  loadFirstPage() => api
          .listDiscoveryComments(
        page: 0,
        pageSize: pageSize,
        socialPostId: socialPostId,
        replySocialPostCommentId: parentComment?.id,
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
        socialPostId: socialPostId,
        replySocialPostCommentId: parentComment?.id,
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
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) => InputScreen(
            uniqueId: "${socialPostId}_${replySocialPostCommentId ?? ''}",
            hint: userName != null ? 'reply $userName' : '',
            callback: (text) async {
              return createComment(text, replySocialPostCommentId);
            },
          ),
        ));
  }

  Future<bool> createComment(String comment, int? replySocialPostCommentId) async {
    await showLoading();
    var baseEntity = await api.createDiscoveryComment(
      comment: comment,
      socialPostId: socialPostId,
      replySocialPostCommentId: replySocialPostCommentId,
    );
    await hideLoading();
    if (baseEntity != null) {
      _refreshController.callRefresh();
    }
    return baseEntity != null;
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
          parentComment != null
              ? DiscoveryCommentsListCard(
                  data: parentComment!,
                  isLast: true,
                  type: CommentsListCardType.header,
                )
              : Container(),
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
                    isTopComments: parentComment == null,
                    onTap: () {
                      onCreateCommentClick(
                        replySocialPostCommentId: dataList[index].id,
                        userName: dataList[index].userName,
                      );
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
          onCreateCommentClick(userName: userName, replySocialPostCommentId: parentComment?.id);
        })),
        Expanded(child: _function(context, Images.ic_discovery_like, StringConstant.discoveryLike, onTap: () {})),
      ],
    ).intoMaterial(elevation: 2, color: ColorConstant.BackgroundColor);
  }

  Widget _function(BuildContext context, String imgRes, String text, {GestureTapCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imgRes, width: $(18)),
        SizedBox(width: $(6)),
        TitleTextWidget(text, ColorConstant.White, FontWeight.normal, $(14)),
      ],
    ).intoContainer(padding: EdgeInsets.all($(16))).intoGestureDetector(onTap: onTap);
  }
}
