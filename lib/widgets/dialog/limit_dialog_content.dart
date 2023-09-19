import 'package:cartoonizer/common/ThemeConstant.dart';
import 'package:cartoonizer/generated/l10n.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/utils/screen_util.dart';
import 'package:cartoonizer/widgets/TitleTextWidget.dart';
import 'package:cartoonizer/widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/widgets/widget_extensions.dart';
import 'package:flutter/material.dart';

class LimitDialogContent extends StatelessWidget {
  final Function(bool toSign) onPositiveTap;
  final Function onNegativeTap;
  final Function onInviteTap;
  final AccountLimitType type;

  const LimitDialogContent({
    super.key,
    required this.type,
    required this.onNegativeTap,
    required this.onPositiveTap,
    required this.onInviteTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AccountLimitType.guest:
        return GuestLimitDialogContent(onNegativeTap: onNegativeTap, onPositiveTap: onPositiveTap);
      case AccountLimitType.normal:
        return UserLimitDialogContent(
          onNegativeTap: onNegativeTap,
          onPositiveTap: onPositiveTap,
          onInviteTap: onInviteTap,
        );
      case AccountLimitType.vip:
        return VipLimitDialogContent(onNegativeTap: onNegativeTap, onPositiveTap: onPositiveTap)
            .intoContainer(padding: EdgeInsets.symmetric(horizontal: $(25)))
            .customDialogStyle();
      default:
        return Container();
    }
  }
}

class GuestLimitDialogContent extends StatelessWidget {
  final Function(bool toSign) onPositiveTap;
  final Function onNegativeTap;

  const GuestLimitDialogContent({super.key, required this.onNegativeTap, required this.onPositiveTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TitleTextWidget(S.of(context).limit_login_title, Colors.white, FontWeight.bold, $(20), maxLines: 3),
            SizedBox(height: $(40)),
            Image.asset(Images.ic_limit_guest_icon),
            SizedBox(height: $(40)),
            ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  colors: [ColorConstant.ColorLinearStart, ColorConstant.ColorLinearEnd],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(rect);
              },
              blendMode: BlendMode.srcATop,
              child: TitleTextWidget(S.of(context).sign_up, Colors.white, FontWeight.w500, $(12), maxLines: 1).intoContainer(width: double.maxFinite),
            )
                .intoContainer(
                    padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(12)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular($(32)),
                    ))
                .intoGestureDetector(onTap: () {
              onPositiveTap.call(true);
            }),
            SizedBox(height: $(15)),
            RichText(
              text: TextSpan(text: S.of(context).limit_login_desc, style: TextStyle(color: Colors.white, fontSize: $(9), fontFamily: 'Poppins'), children: [
                TextSpan(text: S.of(context).limit_login_btn, style: TextStyle(decoration: TextDecoration.underline)),
                TextSpan(text: S.of(context).limit_login_desc_end),
              ]),
            ).intoGestureDetector(onTap: () {
              onPositiveTap.call(false);
            }),
          ],
        ).intoContainer(
          padding: EdgeInsets.only(left: $(15), right: $(15), top: $(20), bottom: $(30)),
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(Images.ic_limit_background), fit: BoxFit.fill),
          ),
        ),
        Image.asset(
          Images.ic_bg_close,
          width: $(28),
          color: Colors.white,
        ).intoContainer(padding: EdgeInsets.all($(15)), color: Colors.transparent).intoGestureDetector(onTap: () {
          onNegativeTap.call();
        }),
      ],
    ).customDialogStyle(color: Colors.transparent, padding: EdgeInsets.zero);
  }
}

class UserLimitDialogContent extends StatelessWidget {
  final Function(bool toSign) onPositiveTap;
  final Function onInviteTap;
  final Function onNegativeTap;

  const UserLimitDialogContent({super.key, required this.onNegativeTap, required this.onPositiveTap, required this.onInviteTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TitleTextWidget(S.of(context).limit_pro_title, Colors.white, FontWeight.bold, $(20), maxLines: 3),
            SizedBox(height: $(12)),
            TitleTextWidget(S.of(context).limit_pro_title_extra, Colors.white, FontWeight.normal, $(12), maxLines: 3)
                .intoContainer(padding: EdgeInsets.symmetric(horizontal: $(10))),
            SizedBox(height: $(37)),
            Image.asset(Images.ic_limit_normal_icon),
            SizedBox(height: $(15)),
            TitleTextWidget(S.of(context).limit_pro_desc, Colors.white, FontWeight.normal, $(9), maxLines: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TitleTextWidget(S.of(context).limit_pro_btn, Colors.black, FontWeight.w500, $(12), maxLines: 1),
                ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      colors: [ColorConstant.ColorLinearStart, ColorConstant.ColorLinearEnd],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.srcATop,
                  child: TitleTextWidget('\$3.99', Colors.white, FontWeight.bold, $(17), maxLines: 1),
                ),
              ],
            )
                .intoContainer(
                    margin: EdgeInsets.only(top: $(39)),
                    padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(12)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular($(32)),
                    ))
                .intoGestureDetector(onTap: () {
              onPositiveTap.call(false);
            }),
            Text(
              S.of(context).limit_inv_desc,
              style: TextStyle(
                color: Color(0xffa7a7a7),
                fontWeight: FontWeight.normal,
                fontSize: $(9),
                decoration: TextDecoration.underline,
              ),
              maxLines: 10,
            ).intoContainer(padding: EdgeInsets.only(top: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
              onInviteTap.call();
            }),
          ],
        ).intoContainer(
          padding: EdgeInsets.only(left: $(15), right: $(15), top: $(20), bottom: $(30)),
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(Images.ic_limit_background), fit: BoxFit.fill),
          ),
        ),
        Image.asset(
          Images.ic_bg_close,
          width: $(28),
          color: Colors.white,
        ).intoContainer(padding: EdgeInsets.all($(15)), color: Colors.transparent).intoGestureDetector(onTap: () {
          onNegativeTap.call();
        }),
      ],
    ).customDialogStyle(color: Colors.transparent, padding: EdgeInsets.zero);
  }
}

class VipLimitDialogContent extends StatelessWidget {
  final Function onPositiveTap;
  final Function onNegativeTap;

  const VipLimitDialogContent({super.key, required this.onNegativeTap, required this.onPositiveTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: $(27)),
        Image.asset(
          Images.ic_limit_icon,
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(22))),
        SizedBox(height: $(16)),
        TitleTextWidget(S.of(context).generate_reached_limit_title, Colors.white, FontWeight.w600, $(18), maxLines: 4).intoContainer(
          width: double.maxFinite,
          padding: EdgeInsets.only(left: $(10), right: $(10)),
          alignment: Alignment.center,
        ),
        SizedBox(height: $(16)),
        TitleTextWidget(
          AccountLimitType.vip.getContent(context),
          ColorConstant.White,
          FontWeight.w500,
          $(13),
          maxLines: 100,
          align: TextAlign.center,
        ).intoContainer(
          width: double.maxFinite,
          padding: EdgeInsets.only(
            bottom: $(30),
            left: $(30),
            right: $(30),
          ),
          alignment: Alignment.center,
        ),
        Text(
          AccountLimitType.vip.getSubmitText(context),
          style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(14)),
        )
            .intoContainer(
          width: double.maxFinite,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular($(8)), color: ColorConstant.DiscoveryBtn),
          padding: EdgeInsets.only(top: $(10), bottom: $(10)),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: $(10)),
        )
            .intoGestureDetector(onTap: () {
          onPositiveTap.call();
        }),
        Text(
          S.of(context).cancel,
          style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(14)),
        )
            .intoContainer(
          width: double.maxFinite,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular($(8)), color: Color(0xff292929)),
          padding: EdgeInsets.only(top: $(10), bottom: $(10)),
          margin: EdgeInsets.only(top: $(16), bottom: $(24)),
          alignment: Alignment.center,
        )
            .intoGestureDetector(onTap: () {
          onNegativeTap.call();
        })
      ],
    );
  }
}
