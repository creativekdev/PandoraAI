import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/nsfw_card.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/enums/effect_tag.dart';

import 'effect_card_ex.dart';

class EffectFullBodyCardWidget extends StatelessWidget with EffectCardEx {
  List<EffectItemListData> data;
  double parentWidth;
  double imageSize = 0;
  Function(EffectItemListData data) onTap;

  bool nsfwShown;
  GestureTapCallback onNsfwTap;

  EffectFullBodyCardWidget({
    Key? key,
    required this.data,
    required this.parentWidth,
    required this.onTap,
    required this.nsfwShown,
    required this.onNsfwTap,
  }) : super(key: key) {
    imageSize = (parentWidth - $(6)) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: buildItem(context, data: data[0])),
        SizedBox(width: $(6)),
        Expanded(child: data.length > 1 ? buildItem(context, data: data[1]) : Container()),
      ],
    );
  }

  Widget buildItem(BuildContext context, {required EffectItemListData data}) {
    var tag = EffectTagUtils.build(data.item!.tag);
    return Stack(
      children: [
        Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  borderRadius: BorderRadius.all(Radius.circular($(8))),
                  child: urlWidget(
                    context,
                    width: imageSize,
                    height: imageSize,
                    url: data.item!.imageUrl,
                  ),
                ),
                nsfwShown && data.item!.nsfw ? Container().blur() : Container(),
                nsfwShown && data.item!.nsfw
                    ? NsfwCard(
                        width: imageSize,
                        height: imageSize,
                        onTap: onNsfwTap,
                      )
                    : Container(),
              ],
            ),
            Text(
              data.item!.displayName,
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
        ),
        tag == EffectTag.UNDEFINED
            ? Container()
            : Image.asset(
                tag.image(),
              ).intoContainer(width: $(28)),
      ],
    ).intoGestureDetector(onTap: () {
      onTap(data);
    });
  }
}
