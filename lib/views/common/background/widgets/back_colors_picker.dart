import 'package:cartoonizer/Widgets/color/palette_widget.dart';
import 'package:cartoonizer/common/importFile.dart';

class BackColorsPicker extends StatefulWidget {
  Function(Color? color) onPickColor;
  Function onOk;
  Function(Color? color) onColorChange;

  BackColorsPicker({
    super.key,
    required this.onPickColor,
    required this.onOk,
    required this.onColorChange,
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          PaletteWidget(
            onChange: (color, opacity) {
              setState(() {
                this.color = Color.fromRGBO(color.red, color.green, color.blue, opacity);
                userTypeColor = '#${color.value.toRadixString(16)}';
                widget.onColorChange.call(this.color);
              });
            },
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
          SizedBox(height: $(10)),
          TitleTextWidget(userTypeColor, Colors.white, FontWeight.normal, $(18)),
          TitleTextWidget(S.of(context).ok, ColorConstant.White, FontWeight.w500, $(17))
              .intoContainer(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: $(10)),
            margin: EdgeInsets.symmetric(horizontal: $(15)),
            decoration: BoxDecoration(color: ColorConstant.BlueColor, borderRadius: BorderRadius.circular($(32))),
          )
              .intoGestureDetector(onTap: () {
            widget.onPickColor.call(color);
            widget.onOk.call(color);
          }),
          SizedBox(height: $(16)),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
