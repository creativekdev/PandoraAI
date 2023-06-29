import 'dart:convert';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/discovery_comment_list_entity.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/views/discovery/discovery_detail_controller.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_comments_list_card.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_detail_card.dart';
import 'package:cartoonizer/views/input/input_screen.dart';
import 'package:cartoonizer/views/transfer/cartoonizer/cartoonize.dart';
import 'package:cartoonizer/views/transfer/style_morph/style_morph.dart';
import 'package:like_button/like_button.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

extension DiscoveryListEntityEx on DiscoveryListEntity {
  String? getStyle(BuildContext context) {
    EffectDataController effectDataController = Get.find();
    var type = HomeCardTypeUtils.build(category);
    switch (type) {
      case HomeCardType.cartoonize:
        if (effectDataController.data == null) {
          return null;
        }
        String key = cartoonizeKey;
        int tabPos = effectDataController.data!.tabPos(key);
        if (tabPos == -1) {
          CommonExtension().showToast(S.of(context).template_not_available);
          return null;
        }
        EffectCategory effectModel = effectDataController.data!.findCategory(key)!;
        EffectItem effectItem = effectModel.effects.pick((t) => t.key == key)!;
        return 'facetoon-${effectItem.key}';
      case HomeCardType.anotherme:
        return 'metaverse';
      case HomeCardType.ai_avatar:
        return 'avatar';
      case HomeCardType.txt2img:
        return 'txt2img';
      case HomeCardType.scribble:
        return 'scribble';
      case HomeCardType.metagram:
        return 'metagram';
      case HomeCardType.style_morph:
        return 'stylemorph';
      case HomeCardType.lineart:
        return 'lineart';
      case HomeCardType.UNDEFINED:
        return null;
    }
  }
}

class DiscoveryDetailScreen extends StatefulWidget {
  DiscoveryListEntity discoveryEntity;
  String prePage;
  bool autoComment;

  DiscoveryDetailScreen({
    Key? key,
    required this.discoveryEntity,
    required this.prePage,
    this.autoComment = false,
  }) : super(key: key);

  @override
  State<DiscoveryDetailScreen> createState() => _DiscoveryDetailScreenState();
}

class _DiscoveryDetailScreenState extends AppState<DiscoveryDetailScreen> {
  UserManager userManager = AppDelegate.instance.getManager();
  late DiscoveryDetailController controller;

  late String prePage;
  String source = '';
  String style = '';
  EffectDataController effectDataController = Get.find();

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'discovery_detail_screen');
    prePage = widget.prePage;
    source = prePage + '-discovery';
    controller = Get.put(DiscoveryDetailController(
      discoveryEntity: widget.discoveryEntity.copy(),
    ));
    delay(() {
      logLoading();
      if (widget.autoComment) {
        onCreateCommentClick(controller);
      }
    });
  }

  @override
  dispose() {
    Get.delete<DiscoveryDetailController>();
    super.dispose();
  }

  logLoading() {
    var discoveryEntity = controller.discoveryEntity;
    var style = discoveryEntity.getStyle(context);
    if (style == null) {
      return;
    }
    this.style = style;
    Events.discoveryDetailLoading(source: source, style: style);
  }

  delete() {
    showLoading().whenComplete(() {
      controller.deleteDiscovery().then((value) {
        hideLoading().whenComplete(() {
          if (value != null) {
            CommonExtension().showToast(S.of(context).delete_succeed);
            Navigator.of(context).pop();
          }
        });
      });
    });
  }

  onTryTap(DiscoveryListEntity data) {}

  toChoosePage() {
    if (effectDataController.data == null) {
      return;
    }
    String key = controller.discoveryEntity.cartoonizeKey;
    int tabPos = effectDataController.data!.tabPos(key);
    int categoryPos = 0;
    int itemPos = 0;
    if (tabPos == -1) {
      CommonExtension().showToast(S.of(context).template_not_available);
      return;
    }
    EffectCategory effectModel = effectDataController.data!.findCategory(key)!;
    EffectItem effectItem = effectModel.effects.pick((t) => t.key == key)!;
    categoryPos = effectDataController.tabTitleList.findPosition((data) => data.categoryKey == effectModel.key)!;
    itemPos = effectDataController.tabItemList.findPosition((data) => data.data.key == effectItem.key)!;
    Events.discoveryTemplateClick(source: source, style: 'facetoon-${effectItem.key}');
    Cartoonize.open(
      context,
      source: source + '-try-template',
      tabPos: tabPos,
      categoryPos: categoryPos,
      itemPos: itemPos,
    );
  }

  toStyleMorph() {
    if (effectDataController.data == null) {
      return;
    }

    String key = controller.discoveryEntity.cartoonizeKey;
    Events.discoveryTemplateClick(source: source, style: 'stylemorph-${key}');
    StyleMorph.open(context, source + '-try-template', initKey: key);
  }

  onCreateCommentClick(DiscoveryDetailController controller, {int? replySocialPostCommentId, int? parentSocialPostCommentId, String? userName}) {
    userManager.doOnLogin(context, logPreLoginAction: 'pre_create_comment', callback: () {
      Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) => InputScreen(
              uniqueId: "${controller.discoveryEntity.id}_${replySocialPostCommentId ?? ''}",
              hint: userName != null ? '${S.of(context).reply} $userName' : '',
              callback: (text) async {
                return createComment(text, replySocialPostCommentId, parentSocialPostCommentId, controller);
              },
            ),
          ));
    });
  }

  Future<bool> createComment(String comment, int? replySocialPostCommentId, int? parentSocialPostCommentId, DiscoveryDetailController controller) async {
    await showLoading();
    var result = controller.createDiscoveryComment(
      comment,
      source,
      style,
      replySocialPostCommentId: replySocialPostCommentId,
      parentSocialPostCommentId: parentSocialPostCommentId,
      onUserExpired: () {
        userManager.doOnLogin(context, logPreLoginAction: 'token_expired');
      },
    );
    await hideLoading();
    return result;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppNavigationBar(
        backgroundColor: Colors.black,
        middle: TitleTextWidget(S.of(context).discoveryDetails, ColorConstant.BtnTextColor, FontWeight.w600, $(18)),
        trailing: TitleTextWidget(S.of(context).delete, ColorConstant.BtnTextColor, FontWeight.w600, $(15)).intoGestureDetector(onTap: () {
          showDeleteDialog();
        }).visibility(visible: userManager.user?.id == controller.discoveryEntity.userId),
      ),
      body: GetBuilder<DiscoveryDetailController>(
        init: Get.find<DiscoveryDetailController>(),
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                  child: ListView.builder(
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return DiscoveryDetailCard(
                        controller: controller,
                        onLikeTap: (liked) async {
                          if (userManager.isNeedLogin) {
                            userManager.doOnLogin(context, logPreLoginAction: controller.discoveryEntity.likeId == null ? 'pre_discovery_like' : 'pre_discovery_unlike');
                            return liked;
                          }
                          bool result;
                          if (liked) {
                            controller.discoveryUnLike();
                            result = false;
                          } else {
                            controller.discoveryLike(source, style);
                            result = true;
                          }
                          return result;
                        },
                        onCommentTap: () {
                          onCreateCommentClick(controller);
                        },
                        onTryTap: () {
                          HomeCardTypeUtils.jump(context: context, source: '$source-try-template', data: controller.discoveryEntity);
                        });
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
      ),
    );
  }

  Widget footer(
    BuildContext context,
    DiscoveryDetailController controller,
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
                isLiked: controller.liked.value,
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
                    userManager.doOnLogin(context, logPreLoginAction: controller.discoveryEntity.likeId == null ? 'pre_discovery_like' : 'pre_discovery_unlike');
                    return liked;
                  }
                  bool result;
                  if (liked) {
                    controller.discoveryUnLike();
                    result = false;
                  } else {
                    controller.discoveryLike(source, style);
                    result = true;
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

  Widget buildCommentItem(BuildContext context, int index, DiscoveryDetailController controller) {
    var data = controller.dataList[index];
    List<Widget> children = [
      Obx(() => DiscoveryCommentsListCard(
            data: data,
            authorId: controller.discoveryEntity.userId,
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
            S.of(context).comments.replaceAll('%d', '${controller.discoveryEntity.comments}').replaceAll('>', ''),
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
            authorId: controller.discoveryEntity.userId,
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
}
