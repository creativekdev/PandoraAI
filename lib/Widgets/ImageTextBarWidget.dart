import 'package:cartoonizer/Common/importFile.dart';

Widget ImageTextBarWidget(String text, String image, bool isShowArrow) {
  return ListTile(
    title: Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        children: [
          Image.asset(
            image,
            height: 12.w,
            width: 12.w,
          ),
          SizedBox(
            width: 3.w,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleTextWidget(text, ColorConstant.TextBlack, FontWeight.w400, 12.sp),
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
    ),
  );
}
