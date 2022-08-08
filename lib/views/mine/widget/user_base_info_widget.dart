import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/models/social_user_info.dart';

class UserBaseInfoWidget extends StatelessWidget {
  SocialUserInfo? userInfo;

  UserBaseInfoWidget({Key? key, required this.userInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: $(24)),
        ClipRRect(
          child: CachedNetworkImageUtils.custom(
            imageUrl: userInfo?.getShownAvatar() ?? '',
            height: $(56),
            width: $(56),
          ),
          borderRadius: BorderRadius.circular(64),
        ),
        SizedBox(width: $(16)),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: children(),
        )),
        SizedBox(width: $(16)),
      ],
    ).intoContainer(padding: EdgeInsets.only(top: $(54), bottom: $(16)), color: ColorConstant.BackgroundColor);
  }

  List<Widget> children() {
    if (userInfo != null) {
      return [
        TitleTextWidget(userInfo!.getShownEmail(), Colors.white, FontWeight.w500, $(17), align: TextAlign.start),
        Row(
          children: [
            Expanded(child: TitleTextWidget(userInfo!.getShownName(), Colors.white, FontWeight.w400, $(13), align: TextAlign.start)),
            Image.asset(
              ImagesConstant.ic_right_arrow,
              height: $(24),
              width: $(24),
            ),
          ],
        )
      ];
    } else {
      return [
        Row(
          children: [
            TitleTextWidget('Login or Register', Colors.white, FontWeight.w400, $(15), align: TextAlign.start),
            SizedBox(width: $(16)),
            Image.asset(
              ImagesConstant.ic_right_arrow,
              height: $(28),
              width: $(28),
            ),
          ],
        )
      ];
    }
  }
}
