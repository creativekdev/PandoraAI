import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

class PromptBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final Color color;

  const PromptBorder({
    Key? key,
    required this.child,
    required this.radius,
    this.padding = EdgeInsets.zero,
    this.color = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child.intoContainer(
          padding: padding,
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        Image.asset(
          Images.ic_prompt_tripple_arrow,
          color: Color(0xcc0000000),
          height: $(5),
        ).intoContainer(margin: EdgeInsets.only(left: $(20))),
      ],
    );
  }
}
