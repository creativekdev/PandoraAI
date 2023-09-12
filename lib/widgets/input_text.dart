import 'package:cartoonizer/widgets/widget_extensions.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';

class InputText extends StatefulWidget {
  bool autofocus;
  TextEditingController controller;
  late Widget clearIcon;
  bool enabled;
  bool expands;
  FocusNode? focusNode;
  late TextInputType keyboardType;
  int? maxLength;
  int maxLines;
  int minLines;
  VoidCallback? onEditingComplete;
  GestureTapCallback? onTap;
  ValueChanged<String>? onChanged;
  ValueChanged<String>? onSubmitted;
  late Widget passwordIcon;
  bool passwordInput;
  late Widget plainIcon;
  late TextStyle style;
  bool showClear;
  bool showCursor;
  TextInputAction textInputAction;
  TextCapitalization textCapitalization;
  TextAlign textAlign;
  TextAlignVertical? textAlignVertical;
  InputDecoration? decoration;
  Widget? icon;

  InputText({
    Key? key,
    this.autofocus = false,
    this.focusNode,
    this.decoration,
    TextInputType? keyboardType,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    TextStyle? style,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.showCursor = true,
    this.maxLines = 1,
    this.minLines = 1,
    this.expands = false,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled = true,
    this.onTap,
    this.showClear = false,
    this.passwordInput = false,
    Widget? passwordIcon,
    Widget? plainIcon,
    Widget? clearIcon,
    this.icon,
    required this.controller,
  }) : super(key: key) {
    this.keyboardType = keyboardType ??= (maxLines == 1 ? TextInputType.text : TextInputType.multiline);
    this.clearIcon = clearIcon ??= const Icon(
      Icons.close,
      color: Colors.grey,
      size: 20,
    ).intoContainer(padding: const EdgeInsets.all(10));
    this.passwordIcon = passwordIcon ??= const Icon(
      Icons.remove_red_eye_outlined,
      size: 20,
      color: Colors.grey,
    ).intoContainer(padding: const EdgeInsets.all(10));
    this.plainIcon = plainIcon ??= const Icon(
      Icons.remove_red_eye,
      color: Colors.blue,
      size: 20,
    ).intoContainer(padding: const EdgeInsets.all(10));
    this.style = style ??= const TextStyle(
      textBaseline: TextBaseline.alphabetic,
    );
  }

  @override
  State<StatefulWidget> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  late bool obscureText;
  late TextStyle style;
  VoidCallback? onEditingComplete;
  GestureTapCallback? onTap;
  ValueChanged<String>? onChanged;
  ValueChanged<String>? onSubmitted;
  TextInputType? keyboardType;
  late TextInputAction textInputAction;
  late TextCapitalization textCapitalization;
  late TextAlign textAlign;
  TextAlignVertical? textAlignVertical;
  late bool autofocus;
  late int maxLines;
  late bool showCursor;
  late int minLines;
  late bool expands;
  int? maxLength;
  late bool enabled;
  late bool showClear;
  late bool passwordInput;
  late Widget passwordIcon;
  late Widget plainIcon;
  late Widget clearIcon;
  FocusNode? focusNode;
  late EdgeInsetsGeometry contentPadding;
  late TextEditingController textEditingController;
  InputDecoration? decoration;
  Widget? icon;

  @override
  void initState() {
    super.initState();
    textEditingController = widget.controller;
    style = widget.style;
    onEditingComplete = widget.onEditingComplete;
    onTap = widget.onTap;
    onChanged = widget.onChanged;
    onSubmitted = widget.onSubmitted;
    keyboardType = widget.keyboardType;
    textAlign = widget.textAlign;
    textAlignVertical = widget.textAlignVertical;
    textInputAction = widget.textInputAction;
    textCapitalization = widget.textCapitalization;
    autofocus = widget.autofocus;
    maxLines = widget.maxLines;
    showCursor = widget.showCursor;
    minLines = widget.minLines;
    expands = widget.expands;
    maxLength = widget.maxLength;
    enabled = widget.enabled;
    showClear = widget.showClear;
    passwordInput = widget.passwordInput;
    passwordIcon = widget.passwordIcon;
    clearIcon = widget.clearIcon;
    focusNode = widget.focusNode;
    plainIcon = widget.plainIcon;
    decoration = widget.decoration;
    icon = widget.icon;
  }

  ///切换密码，明文展示，只有[passwordInput]为true才允许切换
  _setObscureText(bool o) {
    if (passwordInput) {
      setState(() {
        obscureText = o;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (passwordInput) {
      obscureText = true;
    } else {
      obscureText = false;
    }
  }

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          widget.icon ?? Container(),
          Expanded(
            child: TextField(
              textInputAction: textInputAction,
              autofocus: autofocus,
              textAlign: textAlign,
              enabled: enabled,
              focusNode: focusNode,
              expands: expands,
              keyboardType: keyboardType,
              maxLength: maxLength,
              maxLines: maxLines,
              minLines: minLines,
              showCursor: showCursor,
              textAlignVertical: textAlignVertical,
              controller: textEditingController,
              textCapitalization: textCapitalization,
              onChanged: (content) {
                setState(() {});
                if (onChanged != null) {
                  onChanged!(content);
                }
              },
              onSubmitted: onSubmitted,
              onEditingComplete: onEditingComplete,
              style: style,
              obscureText: obscureText,
              decoration: decoration,
            ),
          ),
          Offstage(
            offstage: !(showClear && !TextUtil.isEmpty(textEditingController.text)),
            child: clearIcon.intoGestureDetector(onTap: () {
              textEditingController.clear();
              setState(() {});
            }),
          ),
          Offstage(
            offstage: !passwordInput,
            child: (obscureText ? passwordIcon : plainIcon).intoGestureDetector(onTap: () {
              _setObscureText(!obscureText);
            }),
          ),
        ],
      );
}
