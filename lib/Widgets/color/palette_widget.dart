import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/common/background/background_picker.dart';

import '../../Common/event_bus_helper.dart';
import '../../utils/color_util.dart';
import 'circle_color_widget.dart';
import 'slider_color_picker_widgets.dart';

class PaletteWidget extends StatefulWidget {
  Function(Color color, double opacity) onChange;
  BackgroundData selectedData;

  PaletteWidget({
    super.key,
    required this.onChange,
    required this.selectedData,
  });

  @override
  State<PaletteWidget> createState() => _PaletteWidgetState();
}

class _PaletteWidgetState extends State<PaletteWidget> {
  int selectedIndex = -1;
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

  double opacity = 0.5;

  late StreamSubscription onChangeColorListener;

  @override
  void initState() {
    super.initState();
    // selectedIndex = widget.selectedData.index;
    if (widget.selectedData.color != null) {
      String selectedColor = widget.selectedData.color!.hexValue().substring(2);
      for (int i = 0; i < colorList.length; i++) {
        if (colorList[i].hexValue().contains(selectedColor.toUpperCase())) {
          selectedIndex = i;
          setState(() {});
          break;
        }
      }
    }

    onChangeColorListener = EventBusHelper().eventBus.on<OnChangeColorHexReceiveEvent>().listen((event) {
      setState(() {
        widget.selectedData.color = ColorUtil.hexColor(event.data!);
        selectedIndex = -1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    onChangeColorListener.cancel();
  }

  Color getSliderColor(Color indexColor, double progress) {
    int redValue = indexColor.red;
    int greenValue = indexColor.green;
    int blueValue = indexColor.blue;
    if (progress > 0.5) {
      //  变黑
      redValue -= (redValue * (progress - 0.5) / 0.5).toInt();
      if (redValue < 0) {
        redValue = 0;
      }
      greenValue -= (greenValue * (progress - 0.5) / 0.5).toInt();
      if (greenValue < 0) {
        greenValue = 0;
      }
      blueValue -= (blueValue * (progress - 0.5) / 0.5).toInt();
      if (blueValue < 0) {
        blueValue = 0;
      }
    } else if (progress < 0.5) {
      //  变白
      redValue = redValue + ((255 - redValue) * (0.5 - progress) / 0.5).toInt();
      if (redValue > 255) {
        redValue = 255;
      }
      greenValue = greenValue + ((255 - greenValue) * (0.5 - progress) / 0.5).toInt();
      if (greenValue > 255) {
        greenValue = 255;
      }
      blueValue = blueValue + ((255 - blueValue) * (0.5 - progress) / 0.5).toInt();
      if (blueValue > 255) {
        blueValue = 255;
      }
    }
    return Color.fromARGB(255, redValue, greenValue, blueValue);
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
          height: i == 0 && selectedIndex != -1 ? $(38) : 0,
          child: SliderColorPicker(
            progress: 1 - opacity,
            selectorColor: i == 0 && selectedIndex != -1 ? colorList[selectedIndex] : Colors.transparent,
            visible: i == 0 && selectedIndex != -1,
            onChange: (Color selectorColor, double opacity) {
              Color indexColor = colorList[selectedIndex];
              this.opacity = 1 - opacity;
              Color newColor = getSliderColor(indexColor, this.opacity);
              widget.onChange.call(newColor, this.opacity);
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
          height: i == 1 && selectedIndex != -1 ? $(38) : 0,
          child: SliderColorPicker(
            progress: 1 - opacity,
            selectorColor: i == 1 && selectedIndex != -1 ? colorList[selectedIndex] : Colors.transparent,
            visible: i == 1 && selectedIndex != -1,
            onChange: (selectorColor, opacity) {
              Color indexColor = colorList[selectedIndex];
              this.opacity = 1 - opacity;
              Color newColor = getSliderColor(indexColor, this.opacity);
              widget.onChange.call(newColor, this.opacity);
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
          height: i == 2 && selectedIndex != -1 ? $(38) : 0,
          child: SliderColorPicker(
            progress: 1 - opacity,
            selectorColor: i == 2 && selectedIndex != -1 ? colorList[selectedIndex] : Colors.transparent,
            visible: i == 2 && selectedIndex != -1,
            onChange: (selectorColor, opacity) {
              Color indexColor = colorList[selectedIndex];
              this.opacity = 1 - opacity;
              Color newColor = getSliderColor(indexColor, this.opacity);
              widget.onChange.call(newColor, this.opacity);
            },
          ),
        ),
      ],
    );
  }

  Widget colorTile(BuildContext context, int row, int index) {
    return Flexible(
      flex: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleColorWidget(
            height: $(48),
            width: $(48),
            circleColor: colorList[index],
            circleLineColor: Colors.black,
            lineWith: 0,
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              widget.onChange.call(colorList[selectedIndex], this.opacity);
            },
          ),
          if (index == selectedIndex) Image.asset(Images.ic_bg_color_sel, width: $(26))
        ],
      ),
    );
  }
}
