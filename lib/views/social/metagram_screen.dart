import 'dart:convert';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/auth/connector_platform.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/views/share/ShareUrlScreen.dart';
import 'package:cartoonizer/views/social/metagram_item_list_screen.dart';
import 'package:cartoonizer/views/social/widget/rotating_image.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:skeletons/skeletons.dart';

import 'metagram_controller.dart';
import 'widget/blink_image.dart';

class MetagramScreen extends StatefulWidget {
  String source;
  int coreUserId;
  bool isSelf;

  MetagramScreen({
    Key? key,
    required this.source,
    required this.coreUserId,
    required this.isSelf,
  }) : super(key: key);

  @override
  State<MetagramScreen> createState() => _MetagramScreenState();
}

class _MetagramScreenState extends AppState<MetagramScreen> {
  MetagramController controller = Get.put(MetagramController());

  @override
  void initState() {
    super.initState();
    Posthog().screen(screenName: 'metagram_home_screen');
    delay(() => controller.onPageStart(context, widget.coreUserId, widget.isSelf));
  }

  @override
  void dispose() {
    Get.delete<MetagramController>();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: GetBuilder<MetagramController>(
          builder: (controller) {
            return Stack(
              children: [
                buildMetagramCard(context, controller).intoContainer(margin: EdgeInsets.only(top: 44 + ScreenUtil.getStatusBarHeight())),
                Container(
                  height: 44 + ScreenUtil.getStatusBarHeight(),
                  child: AppNavigationBar(
                    backgroundColor: ColorConstant.BackgroundColor,
                    middle: TitleTextWidget(controller.data?.socialPostPage?.name ?? 'Influencer', Colors.white, FontWeight.w500, $(18)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        (controller.metaProcessing
                                ? RotatingImage(
                                    child: Image.asset(
                                      Images.ic_metagram_refresh,
                                      color: Colors.white,
                                      width: $(24),
                                    ),
                                  )
                                : Image.asset(
                                    Images.ic_metagram_refresh,
                                    color: Colors.white,
                                    width: $(24),
                                  ))
                            .intoContainer(padding: EdgeInsets.all($(10)), color: Colors.transparent)
                            .intoGestureDetector(onTap: () {
                          if (controller.metaProcessing) {
                            return;
                          }
                          controller.startLoadPage(force: true);
                        }).offstage(offstage: controller.data == null || !controller.isSelf),
                        Image.asset(
                          Images.ic_metagram_share_home,
                          width: $(24),
                        ).intoContainer(padding: EdgeInsets.only(left: $(10), top: $(10), bottom: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
                          ShareUrlScreen.startShare(
                            context,
                            url: '${Config.instance.host}/metagram/${controller.slug}',
                          ).then((value) {
                            if (value != null) {
                              Events.metagramCompleteShare(source: 'metagram', platform: value, type: 'url');
                            }
                          });
                        }).offstage(offstage: controller.data == null),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          init: Get.find<MetagramController>()),
    );
  }

  Widget buildMetagramCard(BuildContext context, MetagramController controller) {
    MetagramPageEntity? entity = controller.data;
    Map<String, dynamic>? payload;

    List<String>? userAvatars;
    if (entity != null && entity.socialPostPage != null) {
      userAvatars = entity.socialPostPage!.coverImage?.split(',');
      try {
        payload = jsonDecode(entity.socialPostPage!.payload ?? '');
      } catch (e) {
        payload = null;
      }
    }
    var height = ScreenUtil.screenSize.height - $(150) - 44 - ScreenUtil.getStatusBarHeight();
    var imageWidth = ((ScreenUtil.screenSize.width - $(34)) / 3).truncateToDouble();
    return Column(
      children: [
        buildHeader(context, entity, payload, userAvatars),
        Expanded(
          child: entity == null
              ? SkeletonListView(
                  itemCount: 6,
                  item: Row(
                    children: [
                      SkeletonAvatar(
                        style: SkeletonAvatarStyle(width: imageWidth - 1, height: imageWidth),
                      ),
                      SizedBox(
                        width: $(1),
                      ),
                      SkeletonAvatar(
                        style: SkeletonAvatarStyle(width: imageWidth - 1, height: imageWidth),
                      ),
                      SizedBox(
                        width: $(1),
                      ),
                      SkeletonAvatar(
                        style: SkeletonAvatarStyle(width: imageWidth - 1, height: imageWidth),
                      ),
                    ],
                  ).intoContainer(margin: EdgeInsets.only(top: $(1))),
                ).intoContainer(height: height)
              : GridView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.symmetric(horizontal: $(15)),
                  itemBuilder: (context, index) {
                    var e = entity.rows[index];
                    var blinkImage = BlinkImage(
                      images: e.resourceList().filter((t) => t.type == 'image').map((e) => e.url!).toList(),
                      width: imageWidth,
                      height: imageWidth,
                    );
                    if (e.resourceList().length > 2) {
                      return Stack(
                        children: [
                          blinkImage,
                          Positioned(
                            child: Image.asset(
                              Images.ic_metagram_stack,
                              width: $(20),
                            ),
                            top: $(4),
                            right: $(4),
                          ),
                        ],
                      ).intoGestureDetector(onTap: () {
                        onItemClick(controller, e, index);
                      });
                    } else {
                      return blinkImage.intoGestureDetector(onTap: () {
                        onItemClick(controller, e, index);
                      });
                    }
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: $(1), crossAxisSpacing: $(1)),
                  itemCount: entity.rows.length,
                ),
        ),
        TitleTextWidget(S.of(context).disconnect, Colors.white, FontWeight.w500, $(18))
            .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: $(8)),
                margin: EdgeInsets.only(left: $(15), right: $(15), bottom: ScreenUtil.getBottomPadding(context)),
                decoration: BoxDecoration(
                  color: ColorConstant.DiscoveryBtn,
                  borderRadius: BorderRadius.circular($(10)),
                ))
            .intoGestureDetector(onTap: () {
          disconnectAccount();
        }).visibility(visible: controller.isSelf),
      ],
    );
  }

  onItemClick(MetagramController controller, e, index) {
    controller.scrollPosition = index;
    Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: "/MetagramItemListScreen"),
      builder: (context) => MetagramItemListScreen(),
    ));
  }

  Widget buildHeader(BuildContext context, MetagramPageEntity? entity, Map<String, dynamic>? payload, List<String>? userAvatars) {
    return Column(
      children: [
        Row(
          children: [
            buildAvatar(context, userAvatars),
            SizedBox(width: $(15)),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: buildUserAttr(context, payload, key: 'posts', title: 'Posts'),
                  ),
                  SizedBox(width: $(12)),
                  Expanded(
                    child: buildUserAttr(context, payload, key: 'followers', title: 'Followers'),
                  ),
                  SizedBox(width: $(12)),
                  Expanded(
                    child: buildUserAttr(context, payload, key: 'followings', title: 'Following'),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: $(12)),
        buildBio(context, entity, payload),
        SizedBox(height: $(12)),
        Divider(height: 1, color: Color(0xff464646)),
        SizedBox(height: $(12)),
      ],
    ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)));
  }

  Widget buildAvatar(BuildContext context, List<String>? userAvatars) {
    if (userAvatars == null) {
      return SkeletonAvatar(
        style: SkeletonAvatarStyle(shape: BoxShape.circle, width: $(92), height: $(92)),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular($(64)),
        child: BlinkImage(
          width: $(92),
          height: $(92),
          images: userAvatars,
        ),
      );
    }
  }

  Widget buildUserName(BuildContext context, MetagramPageEntity? entity) {
    if (entity?.socialPostPage == null) {
      return SkeletonLine(
        style: SkeletonLineStyle(height: $(17)),
      );
    } else {
      return TitleTextWidget(
        entity!.socialPostPage!.name ?? '',
        Colors.white,
        FontWeight.w500,
        $(17),
        maxLines: 2,
      ).intoContainer(alignment: Alignment.centerLeft);
    }
  }

  Widget buildUserAttr(BuildContext context, Map<String, dynamic>? payload, {required String key, required String title}) {
    if (payload == null) {
      return SkeletonLine(
        style: SkeletonLineStyle(height: $(12)),
      );
    } else {
      return Column(
        children: [
          TitleTextWidget(title, ColorConstant.White, FontWeight.w400, $(12)),
          TitleTextWidget(((payload[key] ?? 0) as int).socialize, ColorConstant.White, FontWeight.w500, $(14)),
        ],
      );
    }
  }

  Widget buildBio(BuildContext context, MetagramPageEntity? entity, Map<String, dynamic>? payload) {
    if (payload == null) {
      return SkeletonLine(
        style: SkeletonLineStyle(height: $(12)),
      );
    } else {
      return TitleTextWidget(
        payload['bio'] ?? '',
        Colors.white,
        FontWeight.w500,
        $(14),
        maxLines: 10,
        align: TextAlign.start,
      ).intoContainer(alignment: Alignment.centerLeft);
    }
  }

  void disconnectAccount() {
    showDeleteAccountDialog().then((value) {
      if (value ?? false) {
        showLoading().whenComplete(() {
          var userManager = AppDelegate().getManager<UserManager>();
          userManager.disconnectSocialAccount(connection: userManager.platformConnections[ConnectorPlatform.instagram]!.first).then((value) {
            hideLoading().whenComplete(() {
              if (value) {
                CommonExtension().showToast(S.of(context).disconnect_social_completed);
                Navigator.of(context).pop();
              }
            });
          });
        });
      }
    });
  }

  Future<bool?> showDeleteAccountDialog() => showDialog<bool>(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).disconnect_social_tips,
              style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
              textAlign: TextAlign.center,
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
            Row(
              children: [
                Expanded(
                    child: Text(
                  S.of(context).disconnect,
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
                  Navigator.pop(context, true);
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
            .intoMaterial(color: ColorConstant.EffectFunctionGrey, borderRadius: BorderRadius.circular($(16)))
            .intoContainer(padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)), margin: EdgeInsets.symmetric(horizontal: $(35)))
            .intoCenter(),
      );
}
