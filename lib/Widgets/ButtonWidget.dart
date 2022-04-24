import 'package:cartoonizer/Common/importFile.dart';

Widget ButtonWidget(String btnText) {
  return Container(
    width: double.maxFinite,
    height: 55,
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    child: Card(
      elevation: 2.h,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
      shadowColor: ColorConstant.ShadowColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          gradient: RadialGradient(
            colors: [ColorConstant.RadialColor1, ColorConstant.RadialColor2],
            radius: 1.w,
          ),
        ),
        child: Center(
          child: TitleTextWidget(btnText, ColorConstant.White, FontWeight.w600, 13.sp),
        ),
      ),
    ),
  );
}
