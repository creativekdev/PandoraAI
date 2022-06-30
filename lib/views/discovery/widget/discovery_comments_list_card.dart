import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_comment_list_entity.dart';
import 'package:cartoonizer/views/discovery/user_discovery_screen.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_attr_holder.dart';
import 'package:common_utils/common_utils.dart';

class DiscoveryCommentsListCard extends StatelessWidget with DiscoveryAttrHolder {
  DiscoveryCommentListEntity data;
  bool isLast;
  GestureTapCallback? onTap;
  GestureTapCallback? onCommentTap;
  GestureTapCallback? onLikeTap;
  bool isTopComments;
  CommentsListCardType type;

  DiscoveryCommentsListCard({
    Key? key,
    required this.data,
    required this.isLast,
    this.type = CommentsListCardType.list,
    this.onTap,
    this.onLikeTap,
    this.onCommentTap,
    this.isTopComments = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular($(64)),
          child: CachedNetworkImage(
            imageUrl: data.userAvatar,
            fit: BoxFit.cover,
          ),
        ).intoContainer(width: $(45), height: $(45)).intoGestureDetector(onTap: () {
          UserManager userManager = AppDelegate.instance.getManager();
          bool isMe = userManager.user?.id == data.userId;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => UserDiscoveryScreen(
                userId: data.userId,
                title: isMe ? StringConstant.setting_my_discovery : null,
              ),
              settings: RouteSettings(name: "/UserDiscoveryScreen"),
            ),
          );
        }),
        SizedBox(width: $(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: $(3)),
              TitleTextWidget(data.userName, ColorConstant.DiscoveryCommentGrey, FontWeight.normal, $(14)),
              SizedBox(height: $(6)),
              Text(
                data.text,
                style: TextStyle(color: ColorConstant.White, fontSize: $(16), fontFamily: 'Poppins'),
              ).intoContainer(width: double.maxFinite).intoGestureDetector(onTap: () {
                if (isTopComments) {
                  onTap?.call();
                }
              }),
              SizedBox(height: $(6)),
              TitleTextWidget('other ${data.comments} replies >', ColorConstant.BlueColor, FontWeight.normal, $(13))
                  .intoContainer(
                      width: double.maxFinite,
                      color: Colors.black,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: $(8), vertical: $(6)),
                      margin: EdgeInsets.only(top: $(4), bottom: $(8)))
                  .intoGestureDetector(onTap: onCommentTap)
                  .offstage(offstage: data.comments == 0 || type == CommentsListCardType.header || !isTopComments),
              Row(
                children: [
                  Text(
                    DateUtil.formatDateStr(data.modified, format: 'MM-dd HH:mm'),
                    style: TextStyle(color: ColorConstant.DiscoveryCommentGrey, fontSize: $(12), fontFamily: 'Poppins'),
                  ),
                  Expanded(child: Container()),
                  buildAttr(
                    context,
                    iconRes: Images.ic_discovery_comment,
                    value: data.comments,
                    axis: Axis.horizontal,
                    color: ColorConstant.DiscoveryCommentGrey,
                    onTap: () {
                      if (isTopComments) {
                        onCommentTap?.call();
                      }
                    },
                  ).offstage(offstage: !isTopComments),
                  buildAttr(
                    context,
                    iconRes: data.likeId == null ? Images.ic_discovery_like : Images.ic_discovery_liked,
                    iconColor: data.likeId == null ? ColorConstant.DiscoveryCommentGrey : ColorConstant.Red,
                    value: data.likes,
                    axis: Axis.horizontal,
                    color: ColorConstant.DiscoveryCommentGrey,
                    onTap: onLikeTap,
                  ).offstage(offstage: !isTopComments),
                ],
              ),
              SizedBox(height: $(12)),
              !isLast ? Divider(height: 1, color: ColorConstant.DiscoveryCommentGrey) : Container(),
            ],
          ),
        )
      ],
    ).intoContainer(
      color: ColorConstant.BackgroundColor,
      padding: EdgeInsets.only(top: $(15), left: $(15), right: $(15)),
    );
  }
}

enum CommentsListCardType {
  header,
  list,
}
