import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/expand_text.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/views/discovery/discovery.dart';
import 'package:cartoonizer/views/discovery/my_discovery_screen.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_attr_holder.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_detail_card.dart';
import 'package:like_button/like_button.dart';
import 'package:skeletons/skeletons.dart';

import 'user_info_header_widget.dart';

class DiscoveryListCard extends StatelessWidget with DiscoveryAttrHolder {
  late DiscoveryListEntity data;
  GestureTapCallback? onTap;
  OnLikeTap onLikeTap;
  GestureTapCallback? onCommentTap;
  late List<DiscoveryResource> resources;
  late double width;
  bool hasLine;
  bool ignoreLikeBtn = false;
  bool liked;

  DiscoveryListCard({
    Key? key,
    required this.data,
    this.onTap,
    this.hasLine = true,
    this.onCommentTap,
    required this.onLikeTap,
    required this.ignoreLikeBtn,
    required this.liked,
  }) : super(key: key) {
    resources = data.resourceList();
    width = (ScreenUtil.screenSize.width - $(1)) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Divider(height: 1, color: ColorConstant.LineColor).visibility(visible: hasLine),
        UserInfoHeaderWidget(avatar: data.userAvatar, name: data.userName)
            .intoGestureDetector(onTap: () {
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
            })
            .hero(tag: '${data.userAvatar}${data.userName}${data.id}')
            .intoContainer(
              margin: EdgeInsets.only(left: $(15), right: $(15), top: $(10), bottom: $(16)),
            ),
        resources.length != 1 ? buildImages(context) : buildResourceItem(context, resources.first, width: width * 2 + $(1), maxHeight: ScreenUtil.screenSize.height),
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
              onTap: onCommentTap,
              axis: Axis.horizontal,
              iconSize: $(24),
            ),
            LikeButton(
              size: $(24),
              circleColor: CircleColor(
                start: Color(0xfffc2a2a),
                end: Color(0xffc30000),
              ),
              bubblesColor: BubblesColor(
                dotPrimaryColor: Color(0xfffc2a2a),
                dotSecondaryColor: Color(0xffc30000),
              ),
              isLiked: liked,
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
            ).ignore(ignoring: ignoreLikeBtn),
          ],
        ).intoContainer(margin: EdgeInsets.only(top: $(8), left: $(9), right: $(9))).hero(tag: Discovery.attrTag(data.id)),
        TitleTextWidget(S.of(context).all_likes.replaceAll('%d', '${data.likes}'), ColorConstant.White, FontWeight.w400, $(14), align: TextAlign.start)
            .intoContainer(width: double.maxFinite, margin: EdgeInsets.symmetric(horizontal: $(15)), alignment: Alignment.centerLeft)
            .visibility(visible: false),
        ExpandableText(
          text: data.text,
          style: TextStyle(color: ColorConstant.White, fontSize: $(14), fontFamily: 'Poppins'),
          minLines: 2,
          overflow: TextOverflow.ellipsis,
          width: ScreenUtil.screenSize.width - $(30),
        )
            .intoContainer(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: $(15)),
            )
            .hero(tag: Discovery.textTag(data.id)),
        Text(
          S.of(context).view_all_comment.replaceAll('%d', '${data.comments}'),
          style: TextStyle(color: ColorConstant.DiscoveryBtn, fontSize: $(12), fontFamily: 'Poppins'),
        )
            .visibility(
              visible: data.comments > 0,
            )
            .intoContainer(
              alignment: Alignment.centerLeft,
              width: double.maxFinite,
              padding: EdgeInsets.only(left: $(15), right: $(15), bottom: $(20), top: $(6)),
            ),
      ],
    ).intoGestureDetector(onTap: onTap);
  }

  Widget buildResourceItem(BuildContext context, DiscoveryResource resource, {required double width, double? maxHeight, double? height}) {
    if (resource.type == DiscoveryResourceType.video.value()) {
      return EffectVideoPlayer(
        url: resource.url ?? '',
      ).intoContainer(height: width).hero(tag: resource.url ?? '');
    } else {
      return CachedNetworkImageUtils.custom(
          context: context,
          useOld: true,
          imageUrl: resource.url ?? '',
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return SkeletonLine(style: SkeletonLineStyle(height: height));
          },
          errorWidget: (context, url, error) {
            return SkeletonLine(style: SkeletonLineStyle(height: height));
          }).intoContainer(constraints: BoxConstraints(maxHeight: height ?? maxHeight ?? double.infinity)).hero(tag: resource.url ?? '');
    }
  }

  Widget buildImages(
    BuildContext context,
  ) {
    var localHeight = getLocalHeight(resources[1].url!, width);
    return Row(
      children: [
        localHeight != null
            ? buildResourceItem(context, resources[0], width: width, height: localHeight)
            : FutureBuilder<double?>(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return buildResourceItem(context, resources[0], width: width, height: snapshot.data);
                  } else {
                    return Container(width: width, height: width);
                  }
                },
                future: getHeight(resources[1].url!, width),
              ).intoContainer(width: width),
        SizedBox(width: $(1)),
        buildResourceItem(context, resources[1], width: width)
      ],
    ).intoContainer(
      width: ScreenUtil.screenSize.width,
      alignment: Alignment.center,
    );
  }

  double? getLocalHeight(String url, double width) {
    CacheManager cacheManager = AppDelegate().getManager();
    var imgSummaryCache = cacheManager.imgSummaryCache;
    var scale = imgSummaryCache.getScale(url: url);
    if (scale != null) {
      return width / scale;
    }
    return null;
  }

  Future<double?> getHeight(String url, double width) async {
    CacheManager cacheManager = AppDelegate().getManager();
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
