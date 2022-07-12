import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SelectedButton extends StatefulWidget {
  final Widget normalImage;
  final Widget selectedImage;
  final Function(bool isSelected) onChange;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;

  bool selected;

  SelectedButton({
    required this.selectedImage,
    required this.normalImage,
    this.selected = false,
    required this.onChange,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  State<StatefulWidget> createState() {
    return _SelectedButtonState();
  }
}

class _SelectedButtonState extends State<SelectedButton> {
  late bool selected;
  @override
  void initState() {
    super.initState();
    selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        child: selected ? widget.selectedImage : widget.normalImage,
        onTap: () {
          setState(() {
            selected = !selected;
            widget.onChange(selected);
          });
        },
      ),
    );
  }
}
