import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/expand_text.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/views/discovery/my_discovery_screen.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_attr_holder.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_detail_card.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_resources_card.dart';
import 'package:like_button/like_button.dart';
import 'package:skeletons/skeletons.dart';

import 'user_info_header_widget.dart';

typedef LongPressCallBack = Function(LongPressStartDetails positin);

class DiscoveryListCard extends StatelessWidget with DiscoveryAttrHolder {
  late DiscoveryListEntity data;
  GestureTapCallback? onTap;
  OnLikeTap onLikeTap;
  LongPressCallBack longPressCallback;
  GestureTapCallback? onCommentTap;
  late List<DiscoveryResource> resources;
  late double width;
  bool hasLine;
  bool ignoreLikeBtn = false;
  bool liked;

  DiscoveryListCard(
      {Key? key,
      required this.data,
      this.onTap,
      this.hasLine = true,
      this.onCommentTap,
      required this.onLikeTap,
      required this.ignoreLikeBtn,
      required this.liked,
      required this.longPressCallback})
      : super(key: key) {
    resources = data.resourceList();
    width = (ScreenUtil.screenSize.width - $(1)) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (olpdt) async {
        longPressCallback(olpdt);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(height: 1, color: ColorConstant.LineColor).visibility(visible: hasLine),
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
          buildImages(context),
          data.getPrompt() != null
              ? TitleTextWidget(data.getPrompt()!, Color(0xffb3b3b3), FontWeight.w500, $(14), maxLines: 99, align: TextAlign.start).intoContainer(
                  padding: EdgeInsets.only(left: $(15), right: $(15), top: $(10)),
                )
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
          ).intoContainer(margin: EdgeInsets.only(top: $(8), left: $(9), right: $(9))),
          TitleTextWidget(S.of(context).all_likes.replaceAll('%d', '${data.likes}'), ColorConstant.White, FontWeight.w400, $(14), align: TextAlign.start)
              .intoContainer(width: double.maxFinite, margin: EdgeInsets.symmetric(horizontal: $(15)), alignment: Alignment.centerLeft)
              .visibility(visible: false),
          ExpandableText(
            text: data.text,
            style: TextStyle(color: ColorConstant.White, fontSize: $(14), fontFamily: 'Poppins'),
            minLines: 2,
            overflow: TextOverflow.ellipsis,
            width: ScreenUtil.screenSize.width - $(30),
          ).intoContainer(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: $(15)),
          ),
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
      ).intoGestureDetector(onTap: onTap),
    );
  }

  Widget buildImages(
    BuildContext context,
  ) {
    return DiscoveryResourcesCard(
      datas: resources,
      alignType: AlignType.last,
      placeholderWidgetBuilder: (context, url, width, height) {
        return SkeletonAvatar(
          style: SkeletonAvatarStyle(width: width, height: height),
        );
      },
    );
  }
}
