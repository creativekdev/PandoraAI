import '../../../Common/importFile.dart';
import '../../../images-res.dart';

class PopmenuUtil {
  static Future showPopMenu(BuildContext context, LongPressStartDetails details, LongPressItem item) {
    return showDialog(
        context: context,
        builder: (context) {
          return Stack(
            children: [
              Positioned(
                  left: details.globalPosition.dx - $(64),
                  top: details.globalPosition.dy - $(24),
                  child: UnconstrainedBox(
                      child: Container(
                    width: $(128),
                    height: $(48),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular($(8)),
                      color: ColorConstant.White,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          Images.ic_report,
                          width: $(16),
                        ),
                        SizedBox(
                          width: $(5),
                        ),
                        TitleTextWidget(item.text, Colors.black, FontWeight.normal, $(14)),
                      ],
                    ).intoGestureDetector(onTap: () {
                      item.onTap!();
                    }),
                  ))),
            ],
          );
        });
  }
}

class LongPressItem {
  final String text;
  final GestureTapCallback? onTap;

  const LongPressItem({this.text = '', this.onTap});
}
