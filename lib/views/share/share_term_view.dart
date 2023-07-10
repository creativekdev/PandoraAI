import 'package:cartoonizer/Common/importFile.dart';

typedef onClickAgreeMentAction = Function();

showShareTermDialog(BuildContext context, onClickAgreeMentAction agreeAction) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            UnconstrainedBox(
              child: Container(
                margin: EdgeInsets.only(top: $(16)),
                width: $(40),
                height: $(5),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular($(3)),
                ),
              ),
            ),
            TitleTextWidget(
              S.of(context).TermsOfUse,
              ColorConstant.White,
              FontWeight.w600,
              $(36),
              align: TextAlign.left,
            ).intoPadding(
                padding: EdgeInsets.only(
              left: $(16),
              top: $(35),
            )),
            Expanded(
              child: TitleTextWidget(
                S.of(context).TermsOfPost,
                ColorConstant.White,
                FontWeight.w400,
                $(15),
                align: TextAlign.left,
                maxLines: 1000,
              ),
            ).intoContainer(
                width: ScreenUtil.screenSize.width - $(32),
                padding: EdgeInsets.only(
                  left: $(16),
                  right: $(16),
                  top: $(35),
                )),
            TitleTextWidget(
              S.of(context).AgreeAndContinue,
              ColorConstant.White,
              FontWeight.w500,
              $(15),
            )
                .intoContainer(
              height: $(48),
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                left: $(16),
                right: $(16),
                top: $(35),
                bottom: $(35),
              ),
              decoration: BoxDecoration(
                color: ColorConstant.BlueColor,
                borderRadius: BorderRadius.circular(
                  $(
                    $(8),
                  ),
                ),
              ),
            )
                .intoGestureDetector(onTap: () {
              agreeAction();
            }),
          ],
        ).intoContainer(
            padding: EdgeInsets.only(top: $(16), bottom: $(10)),
            decoration: BoxDecoration(
                color: ColorConstant.EffectFunctionGrey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular($(24)),
                  topRight: Radius.circular($(24)),
                )));
      },
      backgroundColor: Colors.transparent);
}
