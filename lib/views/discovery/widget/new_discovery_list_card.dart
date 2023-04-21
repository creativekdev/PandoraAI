import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/expand_text.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/views/discovery/discovery.dart';
import 'package:cartoonizer/views/discovery/my_discovery_screen.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_attr_holder.dart';

import 'user_info_header_widget.dart';

class NewDiscoveryListCard extends StatelessWidget with DiscoveryAttrHolder {
  late DiscoveryListEntity data;
  GestureTapCallback? onTap;
  GestureTapCallback? onLikeTap;
  GestureTapCallback? onCommentTap;
  late List<DiscoveryResource> resources;
  late double width;
  bool hasLine;

  NewDiscoveryListCard({
    Key? key,
    required this.data,
    this.onTap,
    this.hasLine = true,
    this.onCommentTap,
    this.onLikeTap,
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
        resources.length != 1
            ? Wrap(
                spacing: $(1),
                children: resources.map((e) => buildResourceItem(context, e, width: width)).toList(),
                alignment: WrapAlignment.start,
              ).intoContainer(
                width: ScreenUtil.screenSize.width,
                alignment: Alignment.center,
              )
            : buildResourceItem(context, resources.first, width: width * 2 + $(1), maxHeight: ScreenUtil.screenSize.height),
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
              iconRes: data.likeId == null ? Images.ic_discovery_like : Images.ic_discovery_liked,
              iconColor: data.likeId == null ? ColorConstant.White : ColorConstant.Red,
              value: data.likes,
              onTap: onLikeTap,
              hasCount: false,
              iconSize: $(24),
            ),
            buildAttr(
              context,
              iconRes: Images.ic_discovery_comment,
              value: data.comments,
              hasCount: false,
              onTap: onCommentTap,
              iconSize: $(24),
            ),
          ],
        ).intoContainer(margin: EdgeInsets.symmetric(vertical: $(10), horizontal: $(9))).hero(tag: Discovery.attrTag(data.id)),
        TitleTextWidget(S.of(context).all_likes.replaceAll('%d', '${data.likes}'), ColorConstant.White, FontWeight.w400, $(14), align: TextAlign.start)
            .intoContainer(width: double.maxFinite, margin: EdgeInsets.symmetric(horizontal: $(15)), alignment: Alignment.centerLeft),
        ExpandableText(
          text: data.text,
          style: TextStyle(color: ColorConstant.White, fontSize: $(14), fontFamily: 'Poppins'),
          minLines: 2,
          overflow: TextOverflow.ellipsis,
          width: ScreenUtil.screenSize.width - $(30),
        )
            .intoContainer(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: $(6), horizontal: $(15)),
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
              padding: EdgeInsets.only(left: $(15), right: $(15), bottom: $(20)),
            ),
      ],
    ).intoGestureDetector(onTap: onTap);
  }

  Widget buildResourceItem(BuildContext context, DiscoveryResource resource, {required double width, double? maxHeight}) {
    if (resource.type == DiscoveryResourceType.video.value()) {
      return EffectVideoPlayer(
        url: resource.url ?? '',
      ).intoContainer(height: width).hero(tag: resource.url ?? '');
    } else {
      return CachedNetworkImageUtils.custom(
          context: context,
          useOld: false,
          imageUrl: resource.url ?? '',
          width: width,
          useCachedScale: true,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return CircularProgressIndicator()
                .intoContainer(
                  width: $(25),
                  height: $(25),
                )
                .intoCenter()
                .intoContainer(width: width, height: width);
          },
          errorWidget: (context, url, error) {
            return CircularProgressIndicator()
                .intoContainer(
                  width: $(25),
                  height: $(25),
                )
                .intoCenter()
                .intoContainer(width: width, height: width);
          }).intoContainer(constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity)).hero(tag: resource.url ?? '');
    }
  }
}
