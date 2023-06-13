import '../../../Common/importFile.dart';

class PrintShippingInfoItem extends StatelessWidget {
  const PrintShippingInfoItem({Key? key, required this.image, required this.value}) : super(key: key);
  final String image;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: $(14)),
        Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
          Image.asset(
            image,
            width: $(16),
            color: ColorConstant.DiscoveryCommentGrey,
          ).intoPadding(padding: EdgeInsets.only(top: $(6))),
          SizedBox(width: $(16)),
          Expanded(
            child: TitleTextWidget(
              value,
              ColorConstant.DiscoveryCommentGrey,
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
