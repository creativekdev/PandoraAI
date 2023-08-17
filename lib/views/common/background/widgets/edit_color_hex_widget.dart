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
  _EditColorHexWidgetState(this.bgColor, this.colorHex);

  final textController = TextEditingController();
  Color bgColor;
  String colorHex;

  final RegExp _colorRegExp = RegExp(r'^#(?:[0-9a-fA-F]{8})$'); // 正则表达式校验色值

  void _onColorChanged(String color) {
    setState(() {
      if (_colorRegExp.hasMatch(color)) {
        textController.text = color.toUpperCase(); // 将输入的色值转换为大写形式
      }
      if (_colorRegExp.hasMatch(textController.text)) {
        bgColor = ColorUtil.hexColor(textController.text);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    textController.text = colorHex.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
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
            child: TextField(
                controller: textController,
                textAlign: TextAlign.center,
                onChanged: (color) {
                  _onColorChanged(color);
                },
                style: TextStyle(
                  color: Colors.white,
                  fontSize: $(18),
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                )),
            decoration: BoxDecoration(
                color: Color(0xff444547),
                borderRadius: BorderRadius.circular($(19)),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                )),
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
              print("请输入正确的色值");
            }
          }),
        ],
      ),
    );
  }
}
