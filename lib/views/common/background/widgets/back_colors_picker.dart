import 'package:cartoonizer/Widgets/color/palette_widget.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/color_util.dart';
import 'package:cartoonizer/views/common/background/widgets/edit_color_hex_widget.dart';

import '../../../../Common/event_bus_helper.dart';
import '../../../../Widgets/router/routers.dart';
import '../background_picker.dart';

class BackColorsPicker extends StatefulWidget {
  Function(Color? color) onPickColor;
  Function onOk;
  Function(Color? color) onColorChange;
  final BackgroundData preBackgroundData;

  BackColorsPicker({
    super.key,
    required this.onPickColor,
    required this.onOk,
    required this.onColorChange,
    required this.preBackgroundData,
  });

  @override
  State<BackColorsPicker> createState() => _BackColorsPickerState();
}

class _BackColorsPickerState extends State<BackColorsPicker> with AutomaticKeepAliveClientMixin {
  String userTypeColor = '';
  Color? color;
  late Widget paletteWidget;

  @override
  void initState() {
    super.initState();
    if (widget.preBackgroundData.color != null) {
      userTypeColor = ColorUtil.getHexFromColor(widget.preBackgroundData.color!);
    }
    if (userTypeColor == '#0' || userTypeColor == '') {
      userTypeColor = "#000000";
    }
    this.color = ColorUtil.hexToColor(userTypeColor);
  }

  Color getTextColorForBackground(Color backgroundColor) {
    // 计算背景色的亮度
    double luminance = backgroundColor.computeLuminance();

    // 根据亮度选择文本颜色
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          PaletteWidget(
            selectedData: widget.preBackgroundData,
            onChange: (color, opacity) {
              setState(() {
                this.color = color;
                userTypeColor = ColorUtil.getHexFromColor(color);
                widget.onColorChange.call(this.color);
              });
            },
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
          SizedBox(height: $(10)),
          // if (userTypeColor != "#0")
          TitleTextWidget(userTypeColor, getTextColorForBackground(this.color!), FontWeight.normal, $(18))
              .intoContainer(
            height: $(38),
            width: ScreenUtil.screenSize.width - $(30),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: this.color,
              borderRadius: BorderRadius.circular($(19)),
              border: Border.all(
                color: ColorConstant.loginTitleColor,
                width: $(1),
              ),
            ),
          )
              .intoGestureDetector(onTap: () {
            Navigator.push(
              context,
              Bottom2TopRouter(
                settings: RouteSettings(name: "/EditColorHexWidget"),
                child: EditColorHexWidget(
                    hexValue: userTypeColor,
                    onColorSubmit: (hexValue) {
                      userTypeColor = hexValue;
                      this.color = ColorUtil.hexToColor(userTypeColor);
                      Future.delayed(Duration(milliseconds: 500), () {
                        widget.onColorChange.call(this.color);
                      });
                      EventBusHelper().eventBus.fire(OnChangeColorHexReceiveEvent(data: userTypeColor));
                      setState(() {});
                    }),
              ),
            );
          }),
          SizedBox(height: $(16)),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
