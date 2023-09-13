import 'package:flutter/material.dart';

class CircleColorWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? circleColor;
  final Color? circleLineColor;
  final double? lineWith;
  final Function()? onTap;
  final Color? itemColor;

  const CircleColorWidget({Key? key, this.height, this.width, this.circleColor, this.circleLineColor, this.lineWith, this.onTap, this.itemColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: circleColor,
          border: Border.all(
            color: circleLineColor!,
            width: lineWith!,
          ),
        ),
      ),
    );
  }
}
