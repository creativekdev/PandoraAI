import 'package:cartoonizer/common/importFile.dart';

Widget ImageTextBarWidget(String text, String image, bool isShowArrow, {Color? color}) {
  return ListTile(
    title: Row(
      children: [
        Image.asset(
          image,
          height: $(24),
          width: $(24),
          color: color,
        ).intoContainer(padding: EdgeInsets.all($(4))),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleTextWidget(text, Colors.white, FontWeight.w400, $(15)),
            ],
          ),
        ),
        if (isShowArrow)
          Image.asset(
            ImagesConstant.ic_right_arrow,
            height: 8.w,
            width: 8.w,
          ),
      ],
    ),
  ).intoContainer(color: ColorConstant.BackgroundColor);
}
