import 'package:cartoonizer/Widgets/color/palette_widget.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/color_util.dart';

class BackColorsPicker extends StatefulWidget {
  Function(Color? color) onPickColor;

  BackColorsPicker({
    super.key,
    required this.onPickColor,
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
          }),
          SizedBox(height: $(16)),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
