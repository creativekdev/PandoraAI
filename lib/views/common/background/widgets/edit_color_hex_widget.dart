import 'package:cartoonizer/images-res.dart';

import '../../../../Common/Extension.dart';
import '../../../../Common/importFile.dart';
import '../../../../utils/color_util.dart';

typedef OnColorSubmit = Function(String colorHex);

class EditColorHexWidget extends StatefulWidget {
  const EditColorHexWidget({Key? key, required this.hexValue, required this.onColorSubmit}) : super(key: key);
  final String hexValue;
  final OnColorSubmit onColorSubmit;

  @override
  State<EditColorHexWidget> createState() => _EditColorHexWidgetState(ColorUtil.hexColor(hexValue), hexValue);
}

class _EditColorHexWidgetState extends State<EditColorHexWidget> {
  FocusNode _focusNode = FocusNode();

  _EditColorHexWidgetState(this.bgColor, this.colorHex) {
    backgroundColor = bgColor.value.obs;
  }

  Color getTextColorForBackground(Color backgroundColor) {
    // 计算背景色的亮度
    double luminance = backgroundColor.computeLuminance();

    // 根据亮度选择文本颜色
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  late RxInt backgroundColor;
  final textController = TextEditingController();
  late ValueNotifier<Color> _textColorNotifier;

  Color bgColor;
  String colorHex;

  final RegExp _colorRegExp = RegExp(r'^#(?:[0-9a-fA-F]{6})$'); // 正则表达式校验色值

  @override
  void initState() {
    super.initState();
    textController.text = colorHex.toUpperCase();
    _textColorNotifier = ValueNotifier<Color>(getTextColorForBackground(bgColor));
    textController.addListener(_updateTextColor);
    _focusNode.requestFocus();
  }

  void _updateTextColor() {
    if (_colorRegExp.hasMatch(textController.text)) {
      bgColor = ColorUtil.hexColor(textController.text);
      backgroundColor.value = bgColor.value;
      _textColorNotifier.value = getTextColorForBackground(bgColor);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    textController.dispose();
    _textColorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Obx(
            () => Container(
              color: Color(backgroundColor.value),
            ),
          ),
          Column(
            children: [
              Image.asset(
                Images.ic_bg_close,
                width: $(24),
              ).intoGestureDetector(onTap: () {
                Navigator.of(context).pop();
              }).intoPadding(padding: EdgeInsets.only(top: $(30), left: ScreenUtil.screenSize.width - $(39))),
              Container(
                margin: EdgeInsets.only(left: $(15), right: $(15), top: $(80)),
                height: $(38),
                alignment: Alignment.center,
                child: ValueListenableBuilder<Color>(
                    valueListenable: _textColorNotifier,
                    builder: (context, textColor, child) {
                      return TextField(
                          controller: textController,
                          textAlign: TextAlign.center,
                          focusNode: _focusNode,
                          // onChanged: (color) {
                          //   if (color.length > 1) {
                          //     _onColorChanged(color);
                          //   }
                          // },
                          style: TextStyle(
                            color: textColor,
                            fontSize: $(18),
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ));
                    }),
              ),
              Expanded(child: SizedBox()),
              TitleTextWidget(
                S.of(context).submit,
                Colors.white,
                FontWeight.w400,
                $(17),
              )
                  .intoContainer(
                      alignment: Alignment.center,
                      height: $(38),
                      width: ScreenUtil.screenSize.width - $(30),
                      margin: EdgeInsets.only(left: $(15), right: $(15), bottom: $(50)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Color(0xFFE31ECD),
                          Color(0xFF243CFF),
                          Color(0xFFE31ECD),
                        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular($(19)),
                      ))
                  .intoGestureDetector(onTap: () {
                if (_colorRegExp.hasMatch(textController.text)) {
                  widget.onColorSubmit.call(textController.text);
                  Navigator.of(context).pop();
                } else {
                  CommonExtension().showToast(S.of(context).enter_the_color_value);
                }
              }),
            ],
          ),
        ],
      ),
    );
  }
}
