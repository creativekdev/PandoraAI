import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/utils/string_ex.dart';

typedef onClickItemAction = Function();

showCommentActions(BuildContext context,
    {required onClickItemAction replyAction, required onClickItemAction reportAction, required onClickItemAction cancelAction, required String title}) {
  showModalBottomSheet(
      constraints: BoxConstraints(
        maxHeight: $(284),
      ),
      context: context,
      builder: (context) {
        return ListView(
          children: [
            TitleTextWidget(
              title,
              ColorConstant.DiscoveryCommentGrey,
              FontWeight.w400,
              $(13),
              align: TextAlign.center,
            ).intoPadding(
                padding: EdgeInsets.only(
              top: $(16),
              bottom: $(16),
            )),
            Divider(
              indent: $(16),
              color: ColorConstant.LightLineColor,
              endIndent: $(16),
              height: $(1),
            ),
            TitleTextWidget(
              S.of(context).reply.toUpperCaseFirst,
              ColorConstant.White,
              FontWeight.w400,
              $(17),
              align: TextAlign.center,
            )
                .intoPadding(
                    padding: EdgeInsets.only(
              bottom: $(16),
              top: $(16),
            ))
                .intoGestureDetector(onTap: () {
              replyAction();
            }),
            Divider(
              indent: $(16),
              color: ColorConstant.LightLineColor,
              endIndent: $(16),
              height: $(1),
            ),
            TitleTextWidget(
              S.of(context).Report,
              ColorConstant.White,
              FontWeight.w400,
              $(17),
              align: TextAlign.center,
            )
                .intoPadding(
                    padding: EdgeInsets.only(
              bottom: $(16),
              top: $(16),
            ))
                .intoGestureDetector(onTap: () {
              reportAction();
            }),
            Container(
              height: $(8),
              color: ColorConstant.BackgroundColorBlur,
            ),
            TitleTextWidget(
              S.of(context).cancel,
              ColorConstant.White,
              FontWeight.w400,
              $(17),
              align: TextAlign.center,
            )
                .intoPadding(
                    padding: EdgeInsets.only(
              bottom: $(16),
              top: $(16),
            ))
                .intoGestureDetector(onTap: () {
              cancelAction();
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
