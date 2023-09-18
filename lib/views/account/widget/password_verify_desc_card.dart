import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/utils/password_util.dart';
import 'package:flutter/material.dart';

class PasswordVerifyDescCard extends StatelessWidget {
  final PasswordStrength passwordStrength;

  const PasswordVerifyDescCard({
    super.key,
    required this.passwordStrength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        item(context, checked: passwordStrength != PasswordStrength.LengthError, text: S.of(context).password_length_tips),
      ],
    );
  }

  Widget item(BuildContext context, {required bool checked, required String text}) {
    return Row(
      children: [
        Icon(
          checked ? Icons.check_circle : Icons.circle_outlined,
          size: $(18),
          color: checked ? ColorConstant.BlueColor : ColorConstant.loginTitleColor,
        ),
        SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(color: checked ? ColorConstant.BlueColor : ColorConstant.loginTitleColor),
        ),
      ],
    );
  }
}
