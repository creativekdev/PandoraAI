import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/enums/effect_tag.dart';
import 'package:common_utils/common_utils.dart';

import 'effect_card_ex.dart';

///
/// @Author: wangyu
/// @Date: 2022/6/7
/// ignore: must_be_immutable
class EffectFaceCardWidget extends StatelessWidget with EffectCardEx {
  EffectModel data;
  double parentWidth;
  late EffectTag tag;

  EffectFaceCardWidget({
    Key? key,
    required this.parentWidth,
    required this.data,
  }) : super(key: key) {
    tag = EffectTagUtils.build(data.tag);
  }

  @override
  Widget build(BuildContext context) {
    var size = (parentWidth - $(6)) / 2;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextUtil.isEmpty(data.thumbnail)
                ? Wrap(
                    spacing: $(6),
                    runSpacing: $(6),
                    direction: Axis.horizontal,
                    children: data.thumbnails.transfer((e, index) {
                      BorderRadius radius;
                      if (index % 2 == 0) {
                        radius = BorderRadius.only(topLeft: Radius.circular($(8)));
                      } else {
                        radius = BorderRadius.only(topRight: Radius.circular($(8)));
                      }
                      var effect = data.effects[e]!;
                      return ClipRRect(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        borderRadius: radius,
                        child: urlWidget(
                          context,
                          width: size,
                          height: size,
                          url: effect.imageUrl,
                        ),
                      );
                    }),
                  ).intoContainer(
                    alignment: Alignment.center,
                  )
                : ClipRRect(
                    child: CachedNetworkImageUtils.custom(
                      context: context,
                      imageUrl: data.thumbnail,
                      width: parentWidth,
                      height: parentWidth,
                    ),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  ),
            Padding(
              padding: EdgeInsets.only(left: $(12), right: $(12), bottom: $(12), top: $(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TitleTextWidget(data.displayName, ColorConstant.BtnTextColor, FontWeight.w600, 14, align: TextAlign.start),
                  ),
                  Image.asset(
                    Images.ic_arrow_right,
                    width: $(16),
                  ),
                ],
              ),
            ),
          ],
        ),
        tag == EffectTag.UNDEFINED
            ? Container()
            : Image.asset(
                tag.image(),
              ).intoContainer(width: $(28)),
      ],
    ).intoMaterial(color: ColorConstant.BackgroundColor, borderRadius: BorderRadius.circular(8));
  }
}
