import 'package:cartoonizer/images-res.dart';

import '../../../Common/importFile.dart';

class PrintSelectItem extends StatelessWidget {
  PrintSelectItem(
      {Key? key,
      required this.title,
      required this.content,
      required this.imgUrl})
      : super(key: key);
  final String title;
  final String content;
  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TitleTextWidget(
                  title, ColorConstant.White, FontWeight.normal, $(9)),
              if (content.isNotEmpty)
                TitleTextWidget(
                    content, ColorConstant.White, FontWeight.w500, $(14)),
            ]),
        Spacer(),
        if (imgUrl.isNotEmpty)
          Image.asset(
            Images.ic_arrow_right,
            color: ColorConstant.White,
            width: $(32),
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
