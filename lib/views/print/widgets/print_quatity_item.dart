import '../../../Common/importFile.dart';

class PrintQuatityItem extends StatefulWidget {
  PrintQuatityItem({Key? key, required this.quantity, required this.onAddTap, required this.onSubTap}) : super(key: key);
  final String quantity;
  final GestureTapCallback onAddTap;
  final GestureTapCallback onSubTap;

  @override
  State<PrintQuatityItem> createState() => _PrintQuatityItemState();
}

class _PrintQuatityItemState extends State<PrintQuatityItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TitleTextWidget(S.of(context).quantity, ColorConstant.White, FontWeight.normal, $(12)),
        Spacer(),
        TitleTextWidget("-", ColorConstant.White, FontWeight.normal, $(12))
            .intoContainer(
          alignment: Alignment.center,
          width: $(24),
          height: $(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular($(6)),
            border: Border.all(
              color: ColorConstant.White,
              width: $(1),
            ),
          ),
        )
            .intoGestureDetector(onTap: () {
          widget.onSubTap();
        }),

        TitleTextWidget(
          widget.quantity,
          ColorConstant.White,
          FontWeight.normal,
          $(14),
        ).intoContainer(
          width: $(40),
        ),
        TitleTextWidget("+", ColorConstant.White, FontWeight.normal, $(12))
            .intoContainer(
          alignment: Alignment.center,
          width: $(24),
          height: $(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular($(6)),
            border: Border.all(
              color: ColorConstant.White,
              width: $(1),
            ),
          ),
        )
            .intoGestureDetector(onTap: () {
          widget.onAddTap();
        }),
      ],
    ).intoContainer(
      width: ScreenUtil.screenSize.width,
      height: $(56),
      color: ColorConstant.EffectFunctionGrey,
      padding: EdgeInsets.only(left: $(17), right: $(8)),
    );
  }
}
