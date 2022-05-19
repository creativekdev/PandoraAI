import 'package:cartoonizer/Common/importFile.dart';

Widget ImageTextBarWidget(String text, String image, bool isShowArrow) {
  return ListTile(
    title: Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        children: [
          Image.asset(
            image,
            height: 40,
            width: 40,
          ),
          SizedBox(
            width: 3.w,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleTextWidget(text, Colors.white, FontWeight.w400, 16),
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
