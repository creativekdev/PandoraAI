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
        item(context, checked: passwordStrength != PasswordStrength.LengthError, text: '长度需6-16位'),
        item(
          context,
          checked: passwordStrength == PasswordStrength.Medium || passwordStrength == PasswordStrength.Strong,
          text: '不能是纯数字/字母/特殊字符',
        ),
      ],
    );
  }

  Widget item(BuildContext context, {required bool checked, required String text}) {
    return Row(
      children: [
        Icon(
          checked ? Icons.check_circle : Icons.check_circle_outline,
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
