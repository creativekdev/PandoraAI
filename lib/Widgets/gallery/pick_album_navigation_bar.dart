import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

class PickAlbumNavigationBar extends StatelessWidget {
  late Widget statusBar;
  late Widget backIcon;
  late Widget trailing;
  Widget? leading;
  Widget? middle;
  Color backgroundColor;
  double elevation;

  PickAlbumNavigationBar({
    Key? key,
    Widget? backIcon,
    Widget? trailing,
    this.leading,
    this.middle,
    this.backgroundColor = ColorConstant.BackgroundColor,
    this.elevation = 0,
  }) : super(key: key) {
    statusBar = Container(color: Colors.transparent, height: ScreenUtil.getStatusBarHeight());
    this.backIcon = backIcon ?? Image.asset(Images.ic_back, height: $(24), width: $(24));
    this.trailing = trailing ?? SizedBox(width: $(24));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        statusBar,
        Row(
          children: [
            backIcon.intoContainer(padding: EdgeInsets.symmetric(horizontal: 8)).intoGestureDetector(onTap: () {
              Navigator.of(context).pop();
            }),
            leading ?? SizedBox.shrink(),
            Expanded(child: (middle ?? SizedBox.shrink()).intoCenter()),
            trailing,
          ],
        ).intoContainer(height: 44),
      ],
    ).intoMaterial(
      elevation: elevation,
      color: backgroundColor,
    );
  }
}
