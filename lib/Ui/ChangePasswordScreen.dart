import 'dart:convert';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oPassController = TextEditingController();
  final passController = TextEditingController();
  final cPassController = TextEditingController();
  bool isLoading = false;
  @override
  void dispose() {
    oPassController.dispose();
    passController.dispose();
    cPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: isLoading,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => {Navigator.pop(context)},
                      child: Image.asset(
                        ImagesConstant.ic_back_dark,
                        height: 10.w,
                        width: 10.w,
                      ),
                    ),
                    TitleTextWidget(StringConstant.change_password, ColorConstant.BtnTextColor, FontWeight.w600, 14.sp),
                    SizedBox(
                      height: 10.w,
                      width: 10.w,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5.h,
                      ),
                      SimpleTextInputWidget(
                          StringConstant.current_pass, ColorConstant.HintColor, FontWeight.w400, 12.sp, TextInputAction.next, TextInputType.emailAddress, false, oPassController),
                      SizedBox(
                        height: 1.4.h,
                      ),
                      SimpleTextInputWidget(
                          StringConstant.new_pass, ColorConstant.HintColor, FontWeight.w400, 12.sp, TextInputAction.next, TextInputType.emailAddress, false, passController),
                      SizedBox(
                        height: 1.4.h,
                      ),
                      SimpleTextInputWidget(
                          StringConstant.confirm_pass, ColorConstant.HintColor, FontWeight.w400, 12.sp, TextInputAction.done, TextInputType.emailAddress, false, cPassController),
                      SizedBox(
                        height: 5.h,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (oPassController.text.trim().isEmpty) {
                            CommonExtension().showToast(StringConstant.pass_validation);
                          } else if (passController.text.trim().isEmpty) {
                            CommonExtension().showToast(StringConstant.pass_validation);
                          } else if (cPassController.text.trim().isEmpty) {
                            CommonExtension().showToast(StringConstant.cpass_validation);
                          } else if (passController.text.trim() != cPassController.text.trim()) {
                            CommonExtension().showToast(StringConstant.pass_validation1);
                          } else {
                            setState(() {
                              isLoading = true;
                            });
                            var sharedPreferences = await SharedPreferences.getInstance();

                            var body = {
                              "old_password": oPassController.text.trim(),
                              "new_password": passController.text.trim(),
                            };

                            final response = await API.post("/api/user/change_password", body: body).whenComplete(() => {
                                  setState(() {
                                    isLoading = false;
                                  }),
                                });
                            if (response.statusCode == 200) {
                              sharedPreferences.clear();
                              CommonExtension().showToast("Password change successfully.");
                              Navigator.pop(context, false);
                            } else {
                              CommonExtension().showToast(json.decode(response.body)['message']);
                            }
                          }
                        },
                        child: ButtonWidget(StringConstant.update_pass),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
