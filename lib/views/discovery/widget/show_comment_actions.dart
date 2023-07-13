import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/utils/string_ex.dart';

typedef onClickItemAction = Function();

showCommentActions(BuildContext context,
    {required onClickItemAction replyAction,
    required onClickItemAction reportAction,
    required onClickItemAction copyAction,
    required onClickItemAction cancelAction,
    required String title}) {
  showModalBottomSheet(
      constraints: BoxConstraints(
        maxHeight: $(284),
      ),
      context: context,
      builder: (context) {
        return ListView(
          children: [
            _Item(title: title, showLine: true, color: ColorConstant.DiscoveryCommentGrey),
            _Item(title: S.of(context).reply.toUpperCaseFirst, showLine: true, color: ColorConstant.White).intoGestureDetector(onTap: replyAction),
            _Item(title: S.of(context).copy.toUpperCaseFirst, showLine: true, color: ColorConstant.White).intoGestureDetector(onTap: copyAction),
            _Item(title: S.of(context).Report.toUpperCaseFirst, showLine: false, color: ColorConstant.White).intoGestureDetector(onTap: reportAction),
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

class _Item extends StatelessWidget {
  final String title;
  final bool showLine;
  final Color color;

  const _Item({super.key, required this.title, required this.showLine, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleTextWidget(
          title,
          color,
          FontWeight.w400,
          $(13),
          align: TextAlign.center,
        ).intoPadding(
            padding: EdgeInsets.only(
          top: $(16),
          bottom: $(16),
        )),
        if (showLine)
          Divider(
            indent: $(16),
            color: ColorConstant.LightLineColor,
            endIndent: $(16),
            height: $(1),
          ),
      ],
    );
  }
}
