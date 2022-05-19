import 'package:cartoonizer/Common/importFile.dart';

Widget RoundedBorderBtnWidget(String btnText, {Color color = ColorConstant.PrimaryColor}) {
  return Container(
    width: double.maxFinite,
    height: 50,
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color,
        ),
      ),
      child: Center(
        child: TitleTextWidget(btnText, color, FontWeight.w500, 16),
      ),
    ),
  );
}
