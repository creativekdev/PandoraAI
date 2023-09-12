import '../../../common/importFile.dart';

class PrintShippingInfoItem extends StatelessWidget {
  const PrintShippingInfoItem({Key? key, required this.image, required this.value, this.color}) : super(key: key);
  final String image;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: $(14)),
        Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
          Image.asset(
            image,
            width: $(16),
            color: color ?? ColorConstant.DiscoveryCommentGrey,
          ).intoPadding(padding: EdgeInsets.only(top: $(3))),
          SizedBox(width: $(16)),
          Expanded(
            child: TitleTextWidget(
              value,
              color ?? ColorConstant.DiscoveryCommentGrey,
              FontWeight.w400,
              $(14),
              align: TextAlign.left,
              maxLines: 3,
            ).intoContainer(
              padding: EdgeInsets.only(right: $(15)),
            ),
          ),
        ]),
      ],
    );
  }
}
