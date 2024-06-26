import '../../../common/importFile.dart';
import '../../../widgets/cacheImage/cached_network_image_utils.dart';
import '../../../models/print_option_entity.dart';

class PrintOptionItem extends StatelessWidget {
  PrintOptionItem({Key? key, required this.data}) : super(key: key);
  final PrintOptionData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular($(8)),
            topRight: Radius.circular($(8)),
          ),
          child: CachedNetworkImageUtils.custom(
            context: context,
            imageUrl: data.thumbnail,
            width: (ScreenUtil.screenSize.width - $(20)) / 2,
            height: (ScreenUtil.screenSize.width - $(20)) / 2,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: $(8), left: $(8)),
          child: TitleTextWidget(
            data.title,
            ColorConstant.White,
            FontWeight.normal,
            $(10),
            align: TextAlign.left,
            maxLines: 2,
          ),
        ),
      ],
    ).intoContainer(
        height: (ScreenUtil.screenSize.width - $(20)) / 2 + $(44),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular($(8)),
          color: ColorConstant.EffectFunctionGrey,
        ));
  }
}
