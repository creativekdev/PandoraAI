import 'package:cartoonizer/Common/importFile.dart';

Widget IconifiedButtonWidget(String btnText, String image){
  return Container(
    width: double.maxFinite,
    height: 7.5.h,
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    child: Container(
      decoration: BoxDecoration(
        color: ColorConstant.BtnColor,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: ColorConstant.BtnBorderColor, width: 0.5.w,),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Image.asset(image, height: 8.w, width: 8.w,),
          Expanded(
            child: Center(
              child: TitleTextWidget(
                  btnText, ColorConstant.BtnTextColor, FontWeight.w400, 13.sp),
            ),
          ),
        ],
      ),
    ),
  );
}