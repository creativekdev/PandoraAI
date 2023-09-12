import 'package:flutter/material.dart';

class BlankAreaIntercept extends StatelessWidget {
  final Widget child;
  final KeyboardInterceptType interceptType;
  Function? onBlankTap;

  BlankAreaIntercept({
    Key? key,
    required this.child,
    this.interceptType = KeyboardInterceptType.hideKeyboard,
    this.onBlankTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        if (interceptType == KeyboardInterceptType.pop) {
          Navigator.of(context).pop();
        } else {
          onBlankTap?.call();
        }
      },
      child: child);
}

enum KeyboardInterceptType {
  hideKeyboard,
  pop,
}
