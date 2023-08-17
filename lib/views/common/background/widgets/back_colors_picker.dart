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
      userTypeColor = '#${widget.preBackgroundData.color!.value.toRadixString(16)}';
    }
    if (userTypeColor == '#0' || userTypeColor == '') {
      userTypeColor = "#FF000000";
    }
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
                this.color = Color.fromRGBO(color.red, color.green, color.blue, opacity);
                userTypeColor = '#${color.value.toRadixString(16)}';
                widget.onColorChange.call(this.color);
              });
            },
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
          SizedBox(height: $(10)),
          // if (userTypeColor != "#0")
          TitleTextWidget(userTypeColor, Colors.white, FontWeight.normal, $(18))
              .intoContainer(
            height: $(38),
            width: ScreenUtil.screenSize.width - $(30),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xff444547),
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
                      Future.delayed(Duration(milliseconds: 500), () {
                        widget.onColorChange.call(ColorUtil.hexColor(userTypeColor));
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
