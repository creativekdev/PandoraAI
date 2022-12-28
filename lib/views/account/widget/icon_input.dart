import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/input_text.dart';

Widget iconInput({
  required String title,
  required String iconRes,
  bool showClear = false,
  bool passwordInput = false,
  String? passwordIcon,
  String? plainIcon,
  required TextEditingController controller,
  required TextInputAction inputAction,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TitleTextWidget(title, ColorConstant.loginTitleColor, FontWeight.w400, $(14)),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: $(12)),
          Image.asset(
            iconRes,
            height: 24,
            color: ColorConstant.White,
          ),
          SizedBox(width: $(12)),
          Expanded(
            child: InputText(
              showClear: showClear,
              passwordInput: passwordInput,
              passwordIcon: passwordIcon == null
                  ? null
                  : Image.asset(
                      passwordIcon,
                      width: 20,
                    ).intoContainer(padding: const EdgeInsets.all(10)),
              plainIcon: plainIcon == null
                  ? null
                  : Image.asset(
                      plainIcon,
                      width: 20,
                    ).intoContainer(padding: const EdgeInsets.all(10)),
              controller: controller,
              textInputAction: inputAction,
              style: TextStyle(
                color: ColorConstant.White,
                fontFamily: 'Poppins',
                fontSize: $(14),
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: title,
                hintStyle: TextStyle(
                  color: ColorConstant.loginTitleColor,
                  fontFamily: 'Poppins',
                  fontSize: $(14),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ).intoContainer(
          decoration: BoxDecoration(
            color: Color(0xff161719),
            borderRadius: BorderRadius.circular($(8)),
          ),
          margin: EdgeInsets.only(top: $(8))),
    ],
  );
}
