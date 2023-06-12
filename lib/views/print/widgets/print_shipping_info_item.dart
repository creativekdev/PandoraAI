import '../../../Common/importFile.dart';
import '../../../images-res.dart';

class PrintShippingInfoItem extends StatelessWidget {
  const PrintShippingInfoItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: $(14)),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Image.asset(
            Images.ic_order_name,
            width: $(16),
            color: ColorConstant.DiscoveryCommentGrey,
          ),
          SizedBox(width: $(16)),
          TitleTextWidget(
            "S",
            ColorConstant.DiscoveryCommentGrey,
            FontWeight.w400,
            $(14),
            align: TextAlign.left,
            maxLines: 3,
          ),
        ]),
      ],
    );
  }
}
