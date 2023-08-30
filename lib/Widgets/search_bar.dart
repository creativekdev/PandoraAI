import 'package:cartoonizer/Widgets/widget_extensions.dart';
import 'package:cartoonizer/utils/screen_util.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SearchBar extends StatefulWidget {
  TextEditingController? controller;
  Widget? searchIcon;
  Widget? clearIcon;
  String? hint;
  TextStyle? hintStyle;
  TextStyle? style;
  EdgeInsets? contentPadding;
  bool needIcon;

  Function()? onStartSearch;
  Function(String content)? onChange;
  Function()? onSearchClear;
  bool enable;
  bool autoFocus;
  FocusNode? focusNode;

  SearchBar({
    this.controller,
    this.onStartSearch,
    this.onChange,
    this.onSearchClear,
    this.searchIcon,
    this.clearIcon,
    this.hint,
    this.hintStyle,
    this.style,
    this.contentPadding,
    this.needIcon = true,
    this.enable = true,
    this.autoFocus = false,
    this.focusNode,
  });

  @override
  State<StatefulWidget> createState() {
    return SearchBarState(
      controller: controller,
      onStartSearch: onStartSearch,
      onChange: onChange,
      onSearchClear: onSearchClear,
      searchIcon: searchIcon,
      clearIcon: clearIcon,
      hint: hint,
      contentPadding: contentPadding,
      hintStyle: hintStyle,
      needIcon: needIcon,
      style: style,
      enable: enable,
      autoFocus: autoFocus,
      focusNode: focusNode,
    );
  }
}

class SearchBarState extends State<SearchBar> {
  TextEditingController? controller;
  Function()? onStartSearch;
  Function(String content)? onChange;
  Function()? onSearchClear;
  late bool showClear;
  Widget? searchIcon;
  Widget? clearIcon;
  String? hint;
  EdgeInsets? contentPadding;
  late TextStyle hintStyle;
  TextStyle? style;
  bool needIcon;
  bool enable;
  bool autoFocus;
  FocusNode? focusNode;

  SearchBarState({
    this.controller,
    this.onStartSearch,
    this.onChange,
    this.onSearchClear,
    this.hint,
    this.searchIcon,
    this.clearIcon,
    TextStyle? style,
    this.contentPadding,
    TextStyle? hintStyle,
    required this.needIcon,
    required this.enable,
    required this.autoFocus,
    this.focusNode,
  }) {
    showClear = !TextUtil.isEmpty(controller?.text);
    this.hintStyle = hintStyle ??= TextStyle(
      fontSize: $(14),
      color: Color(0xFF8c8c8c),
      height: 1,
    );
    this.style = style ??= TextStyle(
      fontSize: $(14),
      color: Color(0xFF8c8c8c),
      textBaseline: TextBaseline.alphabetic,
      height: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Offstage(
            offstage: !needIcon,
            child: Row(
              children: [
                searchIcon == null
                    ? Icon(
                        Icons.search,
                        size: $(20),
                        color: Colors.grey,
                      )
                    : searchIcon!,
                Container(
                  width: $(6),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: TextField(
                autofocus: autoFocus,
                textInputAction: TextInputAction.go,
                controller: controller,
                focusNode: focusNode,
                onChanged: (content) {
                  var show = !TextUtil.isEmpty(content);
                  if (showClear != show) {
                    setState(() {
                      showClear = show;
                    });
                  }
                  if (onChange != null) {
                    onChange!(content);
                  }
                },
                onEditingComplete: () {
                  if (onStartSearch != null) {
                    onStartSearch!();
                  }
                },
                style: style,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: hintStyle,
                  contentPadding: contentPadding,
                  border: InputBorder.none,
                ),
                // onChanged: onSearchTextChanged,
              ),
            ),
          ),
          Offstage(
              offstage: !showClear,
              child: clearIcon == null
                  ? IconButton(
                      icon: new Icon(Icons.cancel),
                      color: Colors.grey,
                      iconSize: $(21),
                      onPressed: () {
                        _onClearClick();
                      },
                    )
                  : clearIcon!.intoGestureDetector(onTap: () {
                      _onClearClick();
                    })),
        ],
      ),
      ignoring: !enable,
    );
  }

  void _onClearClick() {
    controller?.clear();
    if (onSearchClear != null) {
      onSearchClear!();
    }
    setState(() {
      showClear = false;
    });
  }
}
