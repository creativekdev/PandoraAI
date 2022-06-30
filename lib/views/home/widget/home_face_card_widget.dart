import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/views/home/widget/home_card_ex.dart';

///
/// @Author: wangyu
/// @Date: 2022/6/7
/// ignore: must_be_immutable
class HomeFaceCardWidget extends StatelessWidget with HomeCardEx {
  EffectModel data;
  double parentWidth;

  HomeFaceCardWidget({
    Key? key,
    required this.parentWidth,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = (parentWidth - $(45)) / 2;
    return Card(
      color: ColorConstant.CardColor,
      elevation: $(1),
      shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular($(12)),
      ),
      child: Column(
        children: [
          Wrap(
            direction: Axis.horizontal,
            children: data.thumbnails.map((e) {
              var effect = data.effects[e]!;
              return ClipRRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderRadius: BorderRadius.all(Radius.circular($(6))),
                child: urlWidget(
                  context,
                  width: size,
                  height: size,
                  url: effect.imageUrl,
                ),
              ).intoContainer(
                padding: EdgeInsets.all($(6)),
              );
            }).toList(),
          ).intoContainer(alignment: Alignment.centerLeft, padding: EdgeInsets.all($(6))),
          Padding(
            padding: EdgeInsets.only(left: $(12), right: $(12), bottom: $(24), top: $(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TitleTextWidget(data.displayName, ColorConstant.BtnTextColor, FontWeight.w600, 17, align: TextAlign.start),
                ),
                Image.asset(
                  ImagesConstant.ic_next,
                  height: $(32),
                  width: $(32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
