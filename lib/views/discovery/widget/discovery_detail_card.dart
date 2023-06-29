import 'dart:io';

import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/Widgets/image/images_card.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/photo_view/photo_pager.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/views/discovery/discovery.dart';
import 'package:cartoonizer/views/discovery/discovery_detail_controller.dart';
import 'package:cartoonizer/views/discovery/my_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:like_button/like_button.dart';
import 'package:mmoo_forbidshot/mmoo_forbidshot.dart';
import 'package:skeletons/skeletons.dart';

import 'discovery_attr_holder.dart';
import 'user_info_header_widget.dart';

typedef OnLikeTap = Future<bool> Function(bool liked);

class DiscoveryDetailCard extends StatelessWidget with DiscoveryAttrHolder {
  DiscoveryDetailController controller;
  Function onCommentTap;
  OnLikeTap onLikeTap;
  Function onTryTap;
  CacheManager cacheManager = AppDelegate().getManager();
  late double imageListWidth;
  DateTime? dateTime;

  DiscoveryDetailCard({
    Key? key,
    required this.controller,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onTryTap,
  }) : super(key: key) {
    imageListWidth = (ScreenUtil.screenSize.width - $(31)) / 2;
    dateTime = controller.discoveryEntity.created.timezoneCur;
  }

  @override
  Widget build(BuildContext context) {
    var data = controller.discoveryEntity;
    return Column(
      children: [
        UserInfoHeaderWidget(avatar: data.userAvatar, name: data.userName).intoGestureDetector(onTap: () {
          UserManager userManager = AppDelegate.instance.getManager();
          bool isMe = userManager.user?.id == data.userId;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => MyDiscoveryScreen(
                userId: data.userId,
                title: isMe ? S.of(context).setting_my_discovery : null,
              ),
              settings: RouteSettings(name: "/UserDiscoveryScreen"),
            ),
          );
        }).intoContainer(
          margin: EdgeInsets.only(left: $(15), right: $(15), top: $(10), bottom: $(16)),
        ),
        buildImages(context, imageListWidth).intoContainer(
          width: ScreenUtil.screenSize.width,
          alignment: Alignment.center,
        ),
        data.getPrompt() != null
            ? TitleTextWidget(data.getPrompt()!, Color(0xffb3b3b3), FontWeight.w500, $(14), maxLines: 99, align: TextAlign.start)
                .intoContainer(
                  padding: EdgeInsets.only(left: $(15), right: $(15), top: $(10)),
                )
                .hero(tag: data.getPrompt()!)
            : SizedBox.shrink(),
        Row(
          children: [
            buildAttr(
              context,
              iconRes: Images.ic_discovery_comment,
              value: data.comments,
              iconSize: $(24),
            ),
            Obx(() => LikeButton(
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
                  likeCount: data.likes,
                  onTap: (liked) async => await onLikeTap.call(liked),
                  countBuilder: (int? count, bool isLiked, String text) {
                    count ??= 0;
                    return Text(
                      count.socialize,
                      style: TextStyle(color: Colors.white),
                    );
                  },
                ).ignore(ignoring: controller.likeLocalAddAlready.value)),
          ],
        ).intoContainer(margin: EdgeInsets.only(top: $(8), left: $(9), right: $(9))).hero(tag: Discovery.attrTag(data.id)),
        Text(
          data.text,
          style: TextStyle(color: ColorConstant.White, fontSize: $(14), fontFamily: 'Poppins'),
          maxLines: 9999,
          overflow: TextOverflow.ellipsis,
        )
            .intoContainer(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: $(15)),
            )
            .hero(tag: Discovery.textTag(data.id)),
        Text(
          data.created.isEmpty ? '2022-01-01' : DateUtil.formatDate(dateTime, format: 'yyyy-MM-dd'),
          style: TextStyle(color: Color(0xff77777a), fontFamily: 'Poppins', fontWeight: FontWeight.normal, fontSize: $(10)),
        ).intoContainer(alignment: Alignment.centerLeft, padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12))),
        SizedBox(height: $(12)),
        OutlineWidget(
          strokeWidth: $(2),
          radius: $(6),
          gradient: LinearGradient(
            colors: [Color(0xffE31ECD), Color(0xff243CFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          child: ShaderMask(
            shaderCallback: (Rect bounds) => LinearGradient(
              colors: [Color(0xffE31ECD), Color(0xff243CFF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(Offset.zero & bounds.size),
            blendMode: BlendMode.srcATop,
            child: TitleTextWidget(
              S.of(context).discoveryDetailsUseSameTemplate,
              Color(0xffffffff),
              FontWeight.w700,
              $(15),
            ).intoContainer(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: $(10), vertical: $(10)),
            ),
          ),
        ).intoGestureDetector(onTap: () {
          onTryTap.call();
        }).intoContainer(margin: EdgeInsets.only(left: $(15), right: $(15), top: $(0), bottom: $(24))),
      ],
    );
  }

  Widget buildResourceItem(BuildContext context, DiscoveryResource resource, {required double width, double? height, BoxFit fit = BoxFit.cover}) {
    if (resource.type == DiscoveryResourceType.video.value()) {
      return EffectVideoPlayer(url: resource.url ?? '').intoContainer(height: (ScreenUtil.screenSize.width - $(32)) / 2).hero(tag: resource.url ?? '');
    } else {
      if (fit == BoxFit.contain) {
        return Stack(
          children: [
            CachedNetworkImageUtils.custom(
                context: context,
                useOld: false,
                imageUrl: resource.url ?? '',
                fit: BoxFit.fill,
                width: width,
                height: height,
                cacheManager: CachedImageCacheManager(),
                placeholder: (context, url) {
                  return CircularProgressIndicator()
                      .intoContainer(
                        width: $(25),
                        height: $(25),
                      )
                      .intoCenter()
                      .intoContainer(width: width, height: height ?? width);
                },
                errorWidget: (context, url, error) {
                  return CircularProgressIndicator()
                      .intoContainer(
                        width: $(25),
                        height: $(25),
                      )
                      .intoCenter()
                      .intoContainer(width: width, height: height ?? width);
                }),
            Container().blur(),
            CachedNetworkImageUtils.custom(
                context: context,
                useOld: false,
                imageUrl: resource.url ?? '',
                fit: fit,
                width: width,
                height: height,
                cacheManager: CachedImageCacheManager(),
                placeholder: (context, url) {
                  return CircularProgressIndicator()
                      .intoContainer(
                        width: $(25),
                        height: $(25),
                      )
                      .intoCenter()
                      .intoContainer(width: width, height: height ?? width);
                },
                errorWidget: (context, url, error) {
                  return CircularProgressIndicator()
                      .intoContainer(
                        width: $(25),
                        height: $(25),
                      )
                      .intoCenter()
                      .intoContainer(width: width, height: height ?? width);
                })
          ],
        ).hero(tag: resource.url ?? '').intoContainer(width: width, height: height);
      } else {
        return CachedNetworkImageUtils.custom(
            context: context,
            useOld: false,
            imageUrl: resource.url ?? '',
            fit: fit,
            width: width,
            height: height,
            cacheManager: CachedImageCacheManager(),
            placeholder: (context, url) {
              return CircularProgressIndicator()
                  .intoContainer(
                    width: $(25),
                    height: $(25),
                  )
                  .intoCenter()
                  .intoContainer(width: width, height: height ?? width);
            },
            errorWidget: (context, url, error) {
              return CircularProgressIndicator()
                  .intoContainer(
                    width: $(25),
                    height: $(25),
                  )
                  .intoCenter()
                  .intoContainer(width: width, height: height ?? width);
            }).hero(tag: resource.url ?? '');
      }
    }
  }

  void openImage(BuildContext context, final int index) {
    if (Platform.isAndroid) {
      FlutterForbidshot.setAndroidForbidOn();
    }
    List<String> images = controller.resources
        .filter(
          (t) => t.type == DiscoveryResourceType.image.value(),
        )
        .map((e) => e.url ?? '')
        .toList();
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => GalleryPhotoViewWrapper(
          galleryItems: images,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index >= images.length ? 0 : index,
          scrollDirection: Axis.horizontal,
        ),
      ),
    ).then((value) {
      if (Platform.isAndroid) {
        FlutterForbidshot.setAndroidForbidOff();
      }
    });
  }

  Widget buildImages(
    BuildContext context,
    double width,
  ) {
    return ImagesCard(
      images: controller.resources.map((e) => e.url!).toList(),
      placeholderWidgetBuilder: (context, url, width, height) {
        return SkeletonAvatar(
          style: SkeletonAvatarStyle(width: width, height: height),
        );
      },
      onTap: (url, index) {
        openImage(context, index);
      },
    );
  }

  double? getLocalHeight(String url, double width) {
    var imgSummaryCache = cacheManager.imgSummaryCache;
    var scale = imgSummaryCache.getScale(url: url);
    if (scale != null) {
      return width / scale;
    }
    return null;
  }

  Future<double?> getHeight(String url, double width) async {
    var imgSummaryCache = cacheManager.imgSummaryCache;
    var scale = imgSummaryCache.getScale(url: url);
    if (scale != null) {
      return width / scale;
    } else {
      try {
        var imageInfo = await SyncCachedNetworkImage(url: url).getImage();
        scale = imageInfo.image.width / imageInfo.image.height;
        imgSummaryCache.setScale(url: url, scale: scale);
        return width / scale;
      } catch (e) {
        return null;
      }
    }
  }
}
