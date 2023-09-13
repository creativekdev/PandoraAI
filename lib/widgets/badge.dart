import 'package:cartoonizer/common/importFile.dart';

class BadgeView extends StatelessWidget {
  final Widget child;
  int count;
  BadgeType type;

  BadgeView({
    Key? key,
    required this.child,
    this.count = 0,
    this.type = BadgeType.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child.intoContainer(padding: EdgeInsets.all(4)),
        Positioned(
          child: badgeContent(context),
          right: 0,
          top: 0,
        ).visibility(visible: count > 0),
      ],
    );
  }

  Widget badgeContent(BuildContext context) {
    if (type == BadgeType.fill) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    } else {
      return Text(
        '$count',
        style: TextStyle(color: Colors.white, fontSize: $(11)),
        textAlign: TextAlign.center,
      ).intoContainer(
          constraints: BoxConstraints(minWidth: $(12), minHeight: $(12)),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(32),
          ));
    }
  }
}

enum BadgeType {
  count,
  fill,
}
