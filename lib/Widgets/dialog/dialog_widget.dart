import 'package:cartoonizer/Common/importFile.dart';

extension DialogWidgetEx on Widget {
  Widget customDialogStyle({Color color=ColorConstant.EffectFunctionGrey}) {
    return this
        .intoMaterial(
          color: color,
          borderRadius: BorderRadius.circular($(16)),
        )
        .intoContainer(
          padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
          margin: EdgeInsets.symmetric(horizontal: $(25)),
        )
        .intoCenter();
  }
}

Future<bool?> showOpenNsfwDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.of(context).scary_content_alert_open_it,
          style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
          textAlign: TextAlign.center,
        ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
        Row(
          children: [
            Expanded(
                child: Text(
              S.of(context).cancel,
              style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
            )
                    .intoContainer(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                          top: BorderSide(color: ColorConstant.LineColor, width: 1),
                          right: BorderSide(color: ColorConstant.LineColor, width: 1),
                        )))
                    .intoGestureDetector(onTap: () async {
              Navigator.pop(context, false);
            })),
            Expanded(
                child: Text(
              S.of(context).show_it,
              style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.red),
            )
                    .intoContainer(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                          top: BorderSide(color: ColorConstant.LineColor, width: 1),
                        )))
                    .intoGestureDetector(onTap: () {
              Navigator.pop(context, true);
            })),
          ],
        ),
      ],
    )
        .intoMaterial(
          color: ColorConstant.EffectFunctionGrey,
          borderRadius: BorderRadius.circular($(16)),
        )
        .intoContainer(
          padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
          margin: EdgeInsets.symmetric(horizontal: $(35)),
        )
        .intoCenter(),
  );
}
