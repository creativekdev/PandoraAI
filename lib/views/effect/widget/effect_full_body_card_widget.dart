import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/EffectModel.dart';

import 'effect_card_ex.dart';

class EffectFullBodyCardWidget extends StatelessWidget with EffectCardEx {
  List<EffectItemListData> data;
  double parentWidth;
  double imageSize = 0;
  Function(EffectItemListData data) onTap;

  EffectFullBodyCardWidget({
    Key? key,
    required this.data,
    required this.parentWidth,
    required this.onTap,
  }) : super(key: key) {
    imageSize = (parentWidth - $(8)) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: buildItem(context, data: data[0])),
        SizedBox(width: $(8)),
        Expanded(child: data.length > 1 ? buildItem(context, data: data[1]) : Container()),
      ],
    );
  }

  Widget buildItem(BuildContext context, {required EffectItemListData data}) {
    return Column(
      children: [
        ClipRRect(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          borderRadius: BorderRadius.all(Radius.circular($(6))),
          child: urlWidget(
            context,
            width: imageSize,
            height: imageSize,
            url: data.item.imageUrl,
          ),
        ),
        Text(
          data.item.displayName,
          style: TextStyle(
            color: ColorConstant.White,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            fontSize: $(14),
          ),
        ).intoContainer(
            padding: EdgeInsets.only(
          top: $(6),
        )),
      ],
    ).intoGestureDetector(onTap: () {
      onTap(data);
    });
  }
}