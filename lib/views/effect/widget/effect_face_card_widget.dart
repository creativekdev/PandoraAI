import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/tag/tag_widget.dart';
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
    var size = (parentWidth - $(28)) / 2;
    return Stack(
      children: [
        Column(
          children: [
            TextUtil.isEmpty(data.thumbnail)
                ? Wrap(
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
                  ).intoContainer(
                    alignment: Alignment.centerLeft,
                  )
                : ClipRRect(
                    child: CachedNetworkImageUtils.custom(
                      context: context,
                      imageUrl: data.thumbnail,
                      width: parentWidth,
                      height: parentWidth,
                    ),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  ).intoContainer(
                    padding: EdgeInsets.all($(6)),
                  ),
            Padding(
              padding: EdgeInsets.only(left: $(12), right: $(12), bottom: $(20), top: $(12)),
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
            : Tag(
                child: Text(
                  tag.value(),
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
                color: tag.color(),
                width: 35,
                height: 35,
                gravity: TagGravity.topLeft,
              ).intoContainer(
                padding: EdgeInsets.all($(6)),
              ),
      ],
    );
  }
}
