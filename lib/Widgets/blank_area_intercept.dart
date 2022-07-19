import 'package:flutter/material.dart';

class BlankAreaIntercept extends StatelessWidget {
  final Widget child;
  final KeyboardInterceptType interceptType;

  BlankAreaIntercept({
    Key? key,
    required this.child,
    this.interceptType = KeyboardInterceptType.hideKeyboard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        if (interceptType == KeyboardInterceptType.pop) {
          Navigator.of(context).pop();
        }
      },
      child: child);
}

enum KeyboardInterceptType {
  hideKeyboard,
  pop,
}
