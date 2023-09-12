import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:common_utils/common_utils.dart';

class UserBaseInfoWidget extends StatelessWidget {
  final SocialUserInfo? userInfo;
  late final String avatar;

  UserBaseInfoWidget({Key? key, required this.userInfo}) : super(key: key) {
    avatar = userInfo?.getShownAvatar() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: $(24)),
        ClipRRect(
          child: userInfo != null && !TextUtil.isEmpty(avatar)
              ? CachedNetworkImageUtils.custom(
                  context: context,
                  imageUrl: avatar.avatar(),
                  height: $(56),
                  width: $(56),
                  errorWidget: (context, url, error) {
                    return Image.asset(Images.ic_avatar_default).intoContainer(
                        width: $(45),
                        height: $(45),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular($(32)),
                          border: Border.all(color: ColorConstant.White, width: 1),
                        ));
                  },
                )
              : Image.asset(
                  Images.ic_avatar_default,
                  width: $(56),
                  height: $(56),
                ),
          borderRadius: BorderRadius.circular(64),
        ),
        SizedBox(width: $(16)),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: children(context),
        )),
        SizedBox(width: $(16)),
      ],
    ).intoContainer(padding: EdgeInsets.only(top: $(54), bottom: $(16)), color: ColorConstant.BackgroundColor);
  }

  List<Widget> children(BuildContext context) {
    if (userInfo != null) {
      return [
        TitleTextWidget(userInfo!.getShownName(), Colors.white, FontWeight.w500, $(17), align: TextAlign.start),
        Row(
          children: [
            Expanded(child: TitleTextWidget(userInfo!.getShownEmail(), Colors.white, FontWeight.w400, $(13), align: TextAlign.start)),
            Image.asset(
              ImagesConstant.ic_right_arrow,
              height: $(28),
              width: $(28),
            ),
          ],
        )
      ];
    } else {
      return [
        Row(
          children: [
            TitleTextWidget(S.of(context).login_or_sign_up, Colors.white, FontWeight.w400, $(15), align: TextAlign.start),
            SizedBox(width: $(16)),
            Image.asset(
              Images.ic_right_arrow,
              height: $(28),
              width: $(28),
            ),
          ],
        )
      ];
    }
  }
}
