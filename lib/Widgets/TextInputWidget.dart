import 'package:cartoonizer/Common/importFile.dart';

Widget TextInputWidget(
    String hintText,
    String image,
    Color color,
    FontWeight fontWeight,
    double size,
    TextInputAction textInputAction,
    TextInputType textInputType,
    bool isPassword,
    TextEditingController textEditingController) {
  return Container(
    width: double.maxFinite,
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    child: Card(
      elevation: 0.5.h,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 4.w,
          ),
          Image.asset(
            image,
            height: 8.w,
            width: 8.w,
          ),
          SizedBox(
            width: 1.5.w,
          ),
          Container(
            width: 0.5.w,
            height: 4.5.h,
            color: ColorConstant.BorderColor,
          ),
          SizedBox(
            width: 1.5.w,
          ),
          Expanded(
            child: TextField(
              controller: textEditingController,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: color,
                fontWeight: fontWeight,
                fontFamily: 'Poppins',
                fontSize: size,
              ),
              obscureText: isPassword,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(right: 5.w),
                hintText: hintText,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintStyle: TextStyle(
                  color: ColorConstant.HintColor,
                  fontWeight: fontWeight,
                  fontFamily: 'Poppins',
                  fontSize: size,
                ),
              ),
              textInputAction: textInputAction,
              keyboardType: textInputType,
            ),
          ),
        ],
      ),
    ),
  );
}
