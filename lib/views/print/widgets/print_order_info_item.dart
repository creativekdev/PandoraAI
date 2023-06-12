import '../../../Common/importFile.dart';

class PrintOrderInfoItem extends StatelessWidget {
  const PrintOrderInfoItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: $(16)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TitleTextWidget(
            "Size:",
            ColorConstant.DiscoveryCommentGrey,
            FontWeight.w400,
            $(14),
            align: TextAlign.left,
            maxLines: 3,
          ),
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
