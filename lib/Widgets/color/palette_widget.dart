import 'package:cartoonizer/Common/importFile.dart';

import 'circle_color_widget.dart';
import 'slider_color_picker_widgets.dart';

class PaletteWidget extends StatefulWidget {
  Function(Color color, double opacity) onChange;

  PaletteWidget({
    super.key,
    required this.onChange,
  });

  @override
  State<PaletteWidget> createState() => _PaletteWidgetState();
}

class _PaletteWidgetState extends State<PaletteWidget> {
  int selectedIndex = 0;
  List<Color> colorList = [
    Color(0xFF2C2C2C),
    Color(0xFF000Ddd),
    Color(0xFFF2483F),
    Color(0xFFE72866),
    Color(0xFF9B2AAE),
    Color(0xFF673BB4),
    Color(0xFF4051B2),
    Color(0xFF2895EF),
    Color(0xFF17A8F1),
    Color(0xFF16BAD2),
    Color(0xFF0E9587),
    Color(0xFF4EAE53),
    Color(0xFF8BC250),
    Color(0xFFCDDB47),
    Color(0xFFFEEA4C),
    Color(0xFFFEC12E),
    Color(0xFFFD9928),
    Color(0xFFFC5B31),
  ];

  double opacity = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int i = selectedIndex ~/ 6;
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TitleTextWidget("Palette", ColorConstant.White, FontWeight.w500, $(16)),
        ),
        SizedBox(height: $(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            colorTile(context, 0, 0),
            colorTile(context, 0, 1),
            colorTile(context, 0, 2),
            colorTile(context, 0, 3),
            colorTile(context, 0, 4),
            colorTile(context, 0, 5),
          ],
        ),
        SizedBox(height: $(10)),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: i == 0 ? $(40) : 0,
          child: SliderColorPicker(
            progress: 1 - opacity,
            selectorColor: i == 0 ? colorList[selectedIndex] : Colors.transparent,
            visible: i == 0,
            onChange: (Color selectorColor, double opacity) {
              this.opacity = 1 - opacity;
              widget.onChange.call(selectorColor, this.opacity);
              setState(() {});
            },
          ),
        ),
        SizedBox(height: $(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            colorTile(context, 1, 6),
            colorTile(context, 1, 7),
            colorTile(context, 1, 8),
            colorTile(context, 1, 9),
            colorTile(context, 1, 10),
            colorTile(context, 1, 11),
          ],
        ),
        SizedBox(height: $(10)),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: i == 1 ? $(40) : 0,
          child: SliderColorPicker(
            progress: 1- opacity,
            selectorColor: i == 1 ? colorList[selectedIndex] : Colors.transparent,
            visible: i == 1,
            onChange: (selectorColor, opacity) {
              this.opacity = 1 - opacity;
              widget.onChange.call(selectorColor, this.opacity);
              setState(() {});
            },
          ),
        ),
        SizedBox(height: $(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            colorTile(context, 2, 12),
            colorTile(context, 2, 13),
            colorTile(context, 2, 14),
            colorTile(context, 2, 15),
            colorTile(context, 2, 16),
            colorTile(context, 2, 17),
          ],
        ),
        SizedBox(height: $(10)),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: i == 2 ? $(40) : 0,
          child: SliderColorPicker(
            progress: 1 - opacity,
            selectorColor: i == 2 ? colorList[selectedIndex] : Colors.transparent,
            visible: i == 2,
            onChange: (selectorColor, opacity) {
              this.opacity = 1 - opacity;
              widget.onChange.call(selectorColor, this.opacity);
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget colorTile(BuildContext context, int row, int index) {
    return Flexible(
      flex: 1,
      child: CircleColorWidget(
        height: $(45),
        width: $(45),
        circleColor: colorList[index],
        circleLineColor: index == selectedIndex ? Colors.black : colorList[index],
        lineWith: 0,
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
          widget.onChange.call(colorList[selectedIndex], this.opacity);
        },
      ),
    );
  }
}
