import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_comment_list_entity.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/views/discovery/my_discovery_screen.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_attr_holder.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_detail_card.dart';
import 'package:common_utils/common_utils.dart';
import 'package:like_button/like_button.dart';

class DiscoveryCommentsListCard extends StatelessWidget with DiscoveryAttrHolder {
  DiscoveryCommentListEntity data;
  bool hasLine;
  GestureTapCallback? onCommentTap;
  OnLikeTap onLikeTap;
  bool isTopComments;
  late DateTime dateTime;
  bool ignoreLikeBtn;
  int authorId;

  DiscoveryCommentsListCard({
    Key? key,
    required this.data,
    required this.hasLine,
    required this.onLikeTap,
    required this.onCommentTap,
    this.isTopComments = true,
    required this.ignoreLikeBtn,
    required this.authorId,
  }) : super(key: key) {
    dateTime = data.created.timezoneCur!;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isTopComments ? 0 : $(55),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular($(64)),
          child: CachedNetworkImageUtils.custom(
            imageUrl: data.userAvatar.avatar(),
            fit: BoxFit.cover,
            errorWidget: (context, url, error) {
              return Image.asset(Images.ic_avatar_default).intoContainer(
                  width: isTopComments ? $(45) : $(30),
                  height: isTopComments ? $(45) : $(30),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular($(32)),
                    border: Border.all(color: ColorConstant.White, width: 1),
                  ));
            },
            width: isTopComments ? $(45) : $(30),
            height: isTopComments ? $(45) : $(30),
            cacheManager: CachedImageCacheManager(),
            context: context,
          ),
        )
            .intoContainer(
          width: isTopComments ? $(45) : $(30),
          height: isTopComments ? $(45) : $(30),
          margin: EdgeInsets.only(top: $(15)),
        )
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
        }),
        SizedBox(width: $(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hasLine ? Divider(height: 1, color: Color(0xff232528)) : Container(),
              SizedBox(height: $(8)),
              RichText(
                text: TextSpan(
                    text: TextUtil.isEmpty(data.userName) ? S.of(context).accountCancelled : data.userName,
                    style: TextStyle(color: ColorConstant.DiscoveryCommentGrey, fontSize: $(14), fontFamily: 'Poppins'),
                    children: [
                      WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Text(
                            S.of(context).author,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Color(0xffbdbebe),
                              fontWeight: FontWeight.w400,
                              fontSize: $(8),
                            ),
                          )
                              .intoContainer(
                                margin: EdgeInsets.only(left: $(8)),
                                padding: EdgeInsets.only(top: $(1), bottom: $(2), left: $(4), right: $(4)),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Color(0xff232528)),
                              )
                              .offstage(offstage: data.userId != authorId))
                    ]),
              )
                  .intoContainer(
                color: Colors.transparent,
                padding: EdgeInsets.only(top: $(3)),
                width: double.maxFinite,
                alignment: Alignment.centerLeft,
              )
                  .intoGestureDetector(onTap: () {
                onCommentTap?.call();
              }),
              RichText(
                      text: TextSpan(
                          text: data.status == "deleted" ? S.of(context).deleted_comment : data.text,
                          style: TextStyle(color: Color(0xfff6f6f6), fontSize: $(16), fontFamily: 'Poppins'),
                          children: [
                    WidgetSpan(child: Container(width: $(12))),
                    TextSpan(
                      text: DateUtil.formatDate(dateTime, format: 'MM-dd HH:mm'),
                      style: TextStyle(color: ColorConstant.DiscoveryCommentGrey, fontSize: $(12), fontFamily: 'Poppins'),
                    ),
                  ]))
                  .intoContainer(
                color: Colors.transparent,
                width: double.maxFinite,
                padding: EdgeInsets.only(bottom: $(4), top: isTopComments ? $(4) : 0),
              )
                  .intoGestureDetector(onTap: () {
                onCommentTap?.call();
              }),
            ],
          ),
        ),
        LikeButton(
          size: $(24),
          circleColor: CircleColor(
            start: Color(0xfffc2a2a),
            end: Color(0xffc30000),
          ),
          crossAxisAlignment: CrossAxisAlignment.center,
          countPostion: CountPostion.bottom,
          bubblesColor: BubblesColor(
            dotPrimaryColor: Color(0xfffc2a2a),
            dotSecondaryColor: Color(0xffc30000),
          ),
          isLiked: data.likeId != null,
          likeBuilder: (bool isLiked) {
            return Image.asset(
              isLiked ? Images.ic_discovery_liked : Images.ic_discovery_like,
              width: $(24),
              color: isLiked ? Colors.red : Color(0xff949494),
            );
          },
          likeCount: data.likes,
          onTap: (liked) async => await onLikeTap.call(liked),
          countBuilder: (int? count, bool isLiked, String text) {
            count ??= 0;
            return Text(
              count.socialize,
              style: TextStyle(color: Color(0xff949494)),
            );
          },
        ).intoContainer(margin: EdgeInsets.only(top: $(15))).ignore(ignoring: ignoreLikeBtn),
      ],
    ).intoContainer(
      padding: EdgeInsets.only(left: $(15), right: $(15)),
    );
  }
}
