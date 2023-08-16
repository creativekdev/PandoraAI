import 'package:cartoonizer/Widgets/color/palette_widget.dart';
import 'package:cartoonizer/common/importFile.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.preBackgroundData.color != null) {
      userTypeColor = '#${widget.preBackgroundData.color!.value.toRadixString(16)}';
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
          if (userTypeColor != "#0")
            TitleTextWidget(userTypeColor, Colors.white, FontWeight.normal, $(18)).intoContainer(
                height: $(38),
                width: ScreenUtil.screenSize.width - $(30),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Color(0xff444547),
                    borderRadius: BorderRadius.circular($(19)),
                    border: Border.all(
                      color: ColorConstant.loginTitleColor,
                      width: $(1),
                    ))),
          // TitleTextWidget(S.of(context).ok, ColorConstant.White, FontWeight.w500, $(17))
          //     .intoContainer(
          //   width: double.maxFinite,
          //   padding: EdgeInsets.symmetric(vertical: $(10)),
          //   margin: EdgeInsets.symmetric(horizontal: $(15)),
          //   decoration: BoxDecoration(color: ColorConstant.BlueColor, borderRadius: BorderRadius.circular($(32))),
          // )
          //     .intoGestureDetector(onTap: () {
          //   widget.onPickColor.call(color);
          //   widget.onOk.call(color);
          // }),
          SizedBox(height: $(16)),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
