import 'package:cartoonizer/Common/importFile.dart';

class DiscoveryAttrHolder {
  Widget buildAttr(
    BuildContext context, {
    required String iconRes,
    required int value,
  }) =>
      Column(
        children: [
          Image.asset(
            iconRes,
            width: $(18),
          ),
          SizedBox(height: $(4)),
          Text(
            value.socialize,
            style: TextStyle(color: ColorConstant.White, fontSize: $(14)),
          ),
        ],
      ).intoContainer(
        padding: EdgeInsets.symmetric(horizontal: $(4), vertical: $(6)),
        constraints: BoxConstraints(minWidth: $(35)),
      );
}
