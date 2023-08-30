import 'package:cartoonizer/common/importFile.dart';

Widget SimpleTextInputWidget(String hintText, Color color, FontWeight fontWeight, double size, TextInputAction textInputAction, TextInputType textInputType, bool isPassword,
    TextEditingController textEditingController) {
  return Container(
    width: double.maxFinite,
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    child: Card(
      shadowColor: Color.fromRGBO(0, 0, 0, 0.5),
      elevation: 0.5.h,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Center(
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
      ),
    ),
  );
}
