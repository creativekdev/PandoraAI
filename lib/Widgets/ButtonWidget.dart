import 'package:cartoonizer/common/importFile.dart';

Widget ButtonWidget(String btnText, {double? radius}) {
  radius ??= 10.w;
  return Container(
    width: double.maxFinite,
    height: 54,
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    child: Card(
      elevation: 2.h,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
      shadowColor: ColorConstant.ShadowColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: RadialGradient(
            colors: [ColorConstant.RadialColor1, ColorConstant.RadialColor2],
            radius: 1.w,
          ),
        ),
        child: Center(
          child: TitleTextWidget(btnText, ColorConstant.White, FontWeight.w600, 16),
        ),
      ),
    ),
  );
}
