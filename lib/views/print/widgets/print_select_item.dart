import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/string_ex.dart';

import '../../../Common/importFile.dart';
import '../../../Widgets/cacheImage/cached_network_image_utils.dart';

class PrintSelectItem extends StatelessWidget {
  PrintSelectItem({Key? key, required this.title, required this.content, required this.imgUrl, required this.showImage}) : super(key: key);
  final String title;
  final String content;
  final String imgUrl;
  final bool showImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TitleTextWidget(title.intl, ColorConstant.White, FontWeight.normal, $(12)),
            if (content.isNotEmpty) TitleTextWidget(content, ColorConstant.White, FontWeight.w500, $(14)),
          ],
        ),
        Spacer(),
        if (imgUrl.isNotEmpty && title.toLowerCase() == "color" && showImage)
          CachedNetworkImageUtils.custom(
            context: context,
            useOld: false,
            imageUrl: imgUrl,
            width: $(32),
            fit: BoxFit.cover,
          ).intoContainer(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular($(4)),
                  border: Border.all(
                    color: ColorConstant.loginTitleColor,
                    width: $(1),
                  ))),
        Image.asset(
          Images.ic_arrow_right,
          color: ColorConstant.White,
          width: $(24),
        ).intoContainer()
      ],
    ).intoContainer(
      width: ScreenUtil.screenSize.width,
      height: $(56),
      color: ColorConstant.EffectFunctionGrey,
      padding: EdgeInsets.only(left: $(17), right: $(8)),
    );
  }
}
