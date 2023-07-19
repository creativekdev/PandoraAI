import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_comment_list_entity.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_comments_list_card.dart';
import 'package:cartoonizer/views/input/input_screen.dart';
import 'package:cartoonizer/views/social/comments/metagram_comments_controller.dart';
import 'package:like_button/like_button.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'metagram_comment_header.dart';

class MetagramCommentsScreen extends StatefulWidget {
  MetagramItemEntity data;

  MetagramCommentsScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<MetagramCommentsScreen> createState() => _MetagramCommentsScreenState();
}

class _MetagramCommentsScreenState extends AppState<MetagramCommentsScreen> {
  UserManager userManager = AppDelegate.instance.getManager();
  late MetagramCommentsController controller;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'metagram_item_comments_screen');
    controller = Get.put(MetagramCommentsController(data: widget.data));
  }

  @override
  void dispose() {
    Get.delete<MetagramCommentsController>();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppNavigationBar(
        backgroundColor: Colors.black,
      ),
      body: GetBuilder<MetagramCommentsController>(
          builder: (controller) {
            return Column(
              children: [
                Expanded(
                    child: ListView.builder(
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return MetagramCommentHeader(
                        data: controller.data,
                        hasEmpty: controller.dataList.isEmpty,
                      );
                    } else {
                      return buildCommentItem(context, index - 1, controller);
                    }
                  },
                  itemCount: controller.dataList.length + 1,
                  controller: controller.scrollController,
                )),
                footer(context, controller),
              ],
            );
          },
          init: Get.find<MetagramCommentsController>()),
    );
  }

  Widget footer(
    BuildContext context,
    MetagramCommentsController controller,
  ) {
    return Row(
      children: [
        Expanded(
            child: _function(context, Images.ic_discovery_comment, S.of(context).discoveryComment, onTap: () {
          onCreateCommentClick(controller);
        })),
        Expanded(
          child: Obx(() => LikeButton(
                size: $(24),
                circleColor: CircleColor(
                  start: Color(0xfffc2a2a),
                  end: Color(0xffc30000),
                ),
                bubblesColor: BubblesColor(
                  dotPrimaryColor: Color(0xfffc2a2a),
                  dotSecondaryColor: Color(0xffc30000),
                ),
                isLiked: controller.data.liked.value,
                likeBuilder: (bool isLiked) {
                  return Image.asset(
                    isLiked ? Images.ic_discovery_liked : Images.ic_discovery_like,
                    width: $(24),
                    color: isLiked ? Colors.red : Colors.white,
                  );
                },
                likeCount: 0,
                onTap: (liked) async {
                  if (userManager.isNeedLogin) {
                    userManager.doOnLogin(context, logPreLoginAction: controller.data.likeId == null ? 'pre_metagram_like' : 'pre_metagram_unlike');
                    return liked;
                  }
                  bool result;
                  controller.likeLocalAddAlready.value = true;
                  if (liked) {
                    // controller.data.likes--;
                    controller.appApi.discoveryUnLike(controller.data.id!, controller.data.likeId!).then((value) {
                      controller.likeLocalAddAlready.value = false;
                    });
                    result = false;
                    controller.data.liked.value = false;
                  } else {
                    // controller.data.likes++;
                    controller.appApi.discoveryLike(controller.data.id!, source: 'metagram_comment_page', style: 'metagram').then((value) {
                      controller.likeLocalAddAlready.value = false;
                    });
                    result = true;
                    controller.data.liked.value = true;
                  }
                  return result;
                },
                countBuilder: (int? count, bool isLiked, String text) {
                  return Text(
                    isLiked ? S.of(context).discoveryUnlike : S.of(context).discoveryLike,
                    style: TextStyle(color: Colors.white),
                  );
                },
              ).ignore(ignoring: controller.likeLocalAddAlready.value)),
        ),
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

  Widget buildCommentItem(BuildContext context, int index, MetagramCommentsController controller) {
    var data = controller.dataList[index];
    List<Widget> children = [
      Obx(() => DiscoveryCommentsListCard(
            data: data,
            authorId: controller.data.userId!,
            hasLine: index != 0,
            onCommentTap: () {
              onCreateCommentClick(controller, replySocialPostCommentId: data.id, parentSocialPostCommentId: data.id, userName: data.userName);
            },
            isTopComments: true,
            ignoreLikeBtn: controller.likeLocalAddAlready.value,
            onLikeTap: (liked) async {
              if (userManager.isNeedLogin) {
                userManager.doOnLogin(context, logPreLoginAction: data.likeId == null ? 'pre_comment_like' : 'pre_comment_unlike');
                return liked;
              }
              bool result;
              if (liked) {
                controller.commentUnLike(data);
                result = false;
              } else {
                controller.commentLike(data);
                result = true;
              }
              return result;
            },
          )).intoContainer(margin: EdgeInsets.only(top: $(10)))
    ];
    getCommentChildren(context, children, data);
    if (data.comments > data.children.length) {
      children.add(Column(
        children: [
          Obx(
            () => CircularProgressIndicator()
                .intoContainer(width: $(15), height: $(15))
                .intoCenter()
                .intoContainer(width: $(25), height: $(25), margin: EdgeInsets.only(right: $(30)))
                .visibility(visible: controller.loadingCommentId.value == data.id),
          ),
          TitleTextWidget(
            S.of(context).view_more_comment.replaceAll('%d', '${data.comments - data.children.length}'),
            ColorConstant.BlueColor,
            FontWeight.normal,
            $(13),
          )
              .intoContainer(
            width: double.maxFinite,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(bottom: $(4), top: $(4)),
            color: Colors.transparent,
          )
              .intoGestureDetector(onTap: () {
            controller.getSecondaryComments(data);
          })
        ],
      ).intoContainer(padding: EdgeInsets.only(left: $(70))));
    }
    if (index == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).comments.replaceAll('%d', '${controller.data.comments}').replaceAll('>', ''),
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
          ...children,
        ],
      );
    } else {
      return Column(
        children: children,
      );
    }
  }

  getCommentChildren(BuildContext context, List<Widget> list, DiscoveryCommentListEntity entity) {
    for (var data in entity.children) {
      list.add(Obx(() => DiscoveryCommentsListCard(
            data: data,
            authorId: controller.data.userId!,
            hasLine: false,
            onCommentTap: () {
              onCreateCommentClick(controller, replySocialPostCommentId: data.id, parentSocialPostCommentId: entity.id, userName: data.userName);
            },
            isTopComments: false,
            ignoreLikeBtn: controller.likeLocalAddAlready.value,
            onLikeTap: (liked) async {
              if (userManager.isNeedLogin) {
                userManager.doOnLogin(context, logPreLoginAction: data.likeId == null ? 'pre_comment_like' : 'pre_comment_unlike');
                return liked;
              }
              bool result;
              if (liked) {
                controller.commentUnLike(data);
                result = false;
              } else {
                controller.commentLike(data);
                result = true;
              }
              return result;
            },
          )));
    }
  }

  onCreateCommentClick(MetagramCommentsController controller, {int? replySocialPostCommentId, int? parentSocialPostCommentId, String? userName}) {
    userManager.doOnLogin(context, logPreLoginAction: 'pre_create_comment', callback: () {
      Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) => InputScreen(
              uniqueId: "${controller.data.id}_${replySocialPostCommentId ?? ''}",
              hint: userName != null ? '${S.of(context).reply} $userName' : '',
              callback: (text) async {
                return createComment(text, replySocialPostCommentId, parentSocialPostCommentId, controller);
              },
            ),
          ));
    });
  }

  Future<bool> createComment(String comment, int? replySocialPostCommentId, int? parentSocialPostCommentId, MetagramCommentsController controller) async {
    await showLoading();
    var result = controller.createDiscoveryComment(
      comment,
      'metagram',
      'discovery',
      replySocialPostCommentId: replySocialPostCommentId,
      parentSocialPostCommentId: parentSocialPostCommentId,
      onUserExpired: () {
        userManager.doOnLogin(context, logPreLoginAction: 'token_expired');
      },
    );
    await hideLoading();
    return result;
  }
}
