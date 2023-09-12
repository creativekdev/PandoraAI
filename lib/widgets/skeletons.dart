import 'package:cartoonizer/common/importFile.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonLoading extends StatelessWidget {
  final SkeletonAvatarStyle style;

  const SkeletonLoading({Key? key, this.style = const SkeletonAvatarStyle()}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
      child: Padding(
        padding: style.padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: ((style.randomWidth != null && style.randomWidth!) || (style.randomWidth == null && (style.minWidth != null && style.maxWidth != null)))
                  ? doubleInRange(style.minWidth ?? ((style.maxWidth ?? constraints.maxWidth) / 3), style.maxWidth ?? constraints.maxWidth)
                  : style.width,
              height: ((style.randomHeight != null && style.randomHeight!) || (style.randomHeight == null && (style.minHeight != null && style.maxHeight != null)))
                  ? doubleInRange(style.minHeight ?? ((style.maxHeight ?? constraints.maxHeight) / 3), style.maxHeight ?? constraints.maxHeight)
                  : style.height,
              decoration: BoxDecoration(
                color: Color(0x33ffffff),
                shape: style.shape,
                borderRadius: style.shape != BoxShape.circle ? style.borderRadius : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
