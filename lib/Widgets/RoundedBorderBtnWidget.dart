import 'package:cartoonizer/Common/importFile.dart';

Widget RoundedBorderBtnWidget(String btnText) {
  return Container(
    width: double.maxFinite,
    height: 6.h,
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        border: Border.all(
          color: ColorConstant.PrimaryColor,
          width: 0.5.w,
        ),
      ),
      child: Center(
        child: TitleTextWidget(
            btnText, ColorConstant.PrimaryColor, FontWeight.w600, 13.sp),
      ),
    ),
  );
}
