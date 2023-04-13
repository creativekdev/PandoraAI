import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  final double degree;
  final Color color;
  final double dashSize;
  final double space;
  final Axis direction;

  const Separator({
    Key? key,
    this.degree = 1,
    this.color = Colors.black,
    this.dashSize = 10,
    this.space = 10,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double boxWidth;
        double dashHeight, dashWidth;
        int dashCount;
        if (direction == Axis.vertical) {
          boxWidth = degree;
          dashWidth = degree;
          dashHeight = dashSize;
          dashCount =
              (constraints.constrainHeight() / (space / 2 + dashSize)).floor();
        } else {
          boxWidth = constraints.constrainWidth();
          dashWidth = dashSize;
          dashHeight = degree;
          dashCount = (boxWidth / (space / 2 + dashSize)).floor();
        }
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: direction,
        );
      },
    );
  }
}
