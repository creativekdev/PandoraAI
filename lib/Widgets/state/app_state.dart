import 'package:flutter/material.dart';

///触摸外侧关闭软键盘
///当界面有输入框时最外层的widget需要继承此state类
abstract class AppState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: buildWidget(context),
    );
  }

  @protected
  Widget buildWidget(BuildContext context);
}

mixin AppTabState<T extends StatefulWidget> on State<T> {
  bool _attached = true;

  bool get attached => _attached;

  void onAttached() {
    _attached = true;
  }

  void onDetached() {
    _attached = false;
  }
}
