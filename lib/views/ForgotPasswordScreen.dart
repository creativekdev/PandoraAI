import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:flutter/cupertino.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  var isLoading = false;
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
    Posthog().screenWithUser(screenName: 'forgot_password_screen');
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
          backgroundColor: ColorConstant.BackgroundColor,
          appBar: AppNavigationBar(
            blurAble: false,
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 2.h,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: TitleTextWidget(S.of(context).forgot_your_password, ColorConstant.BtnTextColor, FontWeight.w600, 14.sp),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: TitleTextWidget(S.of(context).forgot_password_text, ColorConstant.HintColor, FontWeight.w400, 12.sp, maxLines: 2),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Image.asset(
                  ImagesConstant.ic_jelly_email,
                  height: 35.h,
                ),
                SizedBox(
                  height: 5.h,
                ),
                SimpleTextInputWidget(
                    S.of(context).email, ColorConstant.TextBlack, FontWeight.w400, 12.sp, TextInputAction.done, TextInputType.emailAddress, false, emailController),
                SizedBox(
                  height: 3.h,
                ),
                GestureDetector(
                  onTap: () async {
                    if (emailController.text.trim().isEmpty) {
                      CommonExtension().showToast(S.of(context).email_validation);
                    } else if (!CommonExtension().isValidEmail(emailController.text.trim())) {
                      CommonExtension().showToast(S.of(context).email_validation1);
                    } else {
                      setState(() {
                        isLoading = true;
                      });
                      var body = {"email": emailController.text.trim()};
                      final response = await API.post("/password_retrieve", body: body);
                      setState(() {
                        isLoading = false;
                      });
                      print(response.body);
                      if (response.statusCode == 200) {
                        showAlertDialog(context);
                      } else {
                        CommonExtension().showToast(response.body);
                      }
                    }
                  },
                  child: ButtonWidget(S.of(context).send),
                ),
              ],
            ),
          )),
    );
  }

  showAlertDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        content: Text(
          S.of(context).sent_email_already,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          CupertinoDialogAction(
              child: Text(
                S.of(context).okay,
                style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }
}
