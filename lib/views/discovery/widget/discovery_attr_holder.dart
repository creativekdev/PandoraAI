import 'package:cartoonizer/Common/importFile.dart';

class DiscoveryAttrHolder {
  Widget buildAttr(
    BuildContext context, {
    required String iconRes,
    required int value,
    Axis axis = Axis.vertical,
    GestureTapCallback? onTap,
    Color color = Colors.white,
  }) {
    var alignment = CrossAxisAlignment.center;
    if (value > 10) {
      alignment = CrossAxisAlignment.start;
    }
    return (axis == Axis.vertical
            ? Column(
                crossAxisAlignment: alignment,
                children: [
                  Image.asset(
                    iconRes,
                    width: $(18),
                    color: color,
                  ),
                  SizedBox(height: $(4)),
                  Text(
                    value.socialize,
                    style: TextStyle(color: color, fontSize: $(14)),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: alignment,
                children: [
                  Image.asset(
                    iconRes,
                    width: $(18),
                    color: color,
                  ),
                  SizedBox(width: $(4)),
                  Text(
                    value.socialize,
                    style: TextStyle(color: color, fontSize: $(14)),
                  ),
                ],
              ))
        .intoContainer(
          padding: EdgeInsets.symmetric(horizontal: $(6), vertical: $(6)),
          constraints: BoxConstraints(minWidth: $(0)),
        )
        .intoGestureDetector(onTap: onTap);
  }
}
