import 'dart:convert';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

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
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'change_password_screen');
  }

  @override
  void dispose() {
    oPassController.dispose();
    passController.dispose();
    cPassController.dispose();
    super.dispose();
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
          trailing: TitleTextWidget(
            S.of(context).change_password,
            ColorConstant.BtnTextColor,
            FontWeight.w600,
            $(18),
          ).intoContainer(alignment: Alignment.center),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 5.h),
              SimpleTextInputWidget(
                  S.of(context).current_pass, ColorConstant.TextBlack, FontWeight.w400, 12.sp, TextInputAction.next, TextInputType.emailAddress, false, oPassController),
              SizedBox(height: 1.4.h),
              SimpleTextInputWidget(
                  S.of(context).new_pass, ColorConstant.TextBlack, FontWeight.w400, 12.sp, TextInputAction.next, TextInputType.emailAddress, true, passController),
              SizedBox(height: 1.4.h),
              SimpleTextInputWidget(
                  S.of(context).confirm_pass, ColorConstant.TextBlack, FontWeight.w400, 12.sp, TextInputAction.done, TextInputType.emailAddress, true, cPassController),
              SizedBox(height: 5.h),
              GestureDetector(
                onTap: () async {
                  if (oPassController.text.trim().isEmpty) {
                    CommonExtension().showToast(S.of(context).pass_validation, gravity: ToastGravity.CENTER);
                  } else if (passController.text.trim().isEmpty) {
                    CommonExtension().showToast(S.of(context).pass_validation, gravity: ToastGravity.CENTER);
                  } else if (cPassController.text.trim().isEmpty) {
                    CommonExtension().showToast(S.of(context).cpass_validation, gravity: ToastGravity.CENTER);
                  } else if (passController.text.trim() != cPassController.text.trim()) {
                    CommonExtension().showToast(S.of(context).pass_validation1, gravity: ToastGravity.CENTER);
                  } else {
                    setState(() {
                      isLoading = true;
                    });

                    var body = {
                      "old_password": oPassController.text.trim(),
                      "new_password": passController.text.trim(),
                    };

                    final response = await API.post("/api/user/change_password", body: body).whenComplete(() {});
                    setState(() {
                      isLoading = false;
                    });
                    if (response.statusCode == 200) {
                      CommonExtension().showToast(S.of(context).change_pwd_successfully);
                      var userManager = AppDelegate.instance.getManager<UserManager>();
                      await userManager.logout();
                      Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
                      delay(() {
                        userManager.doOnLogin(Get.context!, logPreLoginAction: 'change_password');
                      }, milliseconds: 500);
                    } else {
                      CommonExtension().showToast(json.decode(response.body)['message']);
                    }
                  }
                },
                child: ButtonWidget(S.of(context).update_pass),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
