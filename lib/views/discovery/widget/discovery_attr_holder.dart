import 'package:cartoonizer/Common/importFile.dart';

class DiscoveryAttrHolder {
  Widget buildAttr(
    BuildContext context, {
    required String iconRes,
    required int value,
    Axis axis = Axis.horizontal,
    GestureTapCallback? onTap,
    Color color = Colors.white,
    Color? iconColor,
    bool hasCount = true,
    double? iconSize,
  }) {
    if (iconSize == null) {
      iconSize = $(18);
    }
    iconColor ??= color;
    return (axis == Axis.vertical
            ? Column(
                crossAxisAlignment: value > 10 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    iconRes,
                    width: iconSize,
                    color: iconColor,
                  ),
                  SizedBox(height: $(4)),
                  Text(
                    value.socialize,
                    style: TextStyle(color: color, fontSize: $(14)),
                  ).offstage(offstage: !hasCount),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    iconRes,
                    width: iconSize,
                    color: iconColor,
                  ),
                  SizedBox(width: $(4)),
                  Text(
                    value.socialize,
                    style: TextStyle(color: color, fontSize: $(14)),
                  ).offstage(offstage: !hasCount),
                ],
              ))
        .intoContainer(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: $(6), vertical: $(6)),
          constraints: BoxConstraints(minWidth: $(0)),
        )
        .intoGestureDetector(onTap: onTap);
  }
}
