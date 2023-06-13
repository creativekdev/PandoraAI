import '../../../Common/importFile.dart';

class PrintOrderInfoItem extends StatelessWidget {
  const PrintOrderInfoItem({Key? key, required this.name, required this.value}) : super(key: key);
  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: $(16)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TitleTextWidget(
            name,
            ColorConstant.DiscoveryCommentGrey,
            FontWeight.w400,
            $(14),
            align: TextAlign.left,
            maxLines: 3,
          ),
          TitleTextWidget(
            value,
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
