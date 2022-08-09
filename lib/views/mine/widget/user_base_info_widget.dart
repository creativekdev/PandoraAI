import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/images-res.dart';
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
          child: userInfo != null
              ? CachedNetworkImageUtils.custom(
                  imageUrl: userInfo?.getShownAvatar() ?? '',
                  height: $(56),
                  width: $(56),
                  errorWidget: (context, url, error) {
                    return Text(
                      (userInfo?.getShownName() == '' ? ' ' : userInfo!.getShownName())[0].toUpperCase(),
                      style: TextStyle(color: ColorConstant.White, fontSize: $(25)),
                    ).intoContainer(
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
                  Images.ic_default_user_icon,
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
            TitleTextWidget('Sign in / Sign up', Colors.white, FontWeight.w400, $(15), align: TextAlign.start),
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
