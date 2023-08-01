import 'dart:ui' as ui;

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/utils/color_util.dart';
import 'package:cartoonizer/views/mine/filter/pin_gesture_views.dart';
import 'package:image/image.dart' as imgLib;

import '../../../images-res.dart';
import '../../../utils/utils.dart';

class ImPinView extends StatefulWidget {
  imgLib.Image personImage;
  imgLib.Image? backgroundImage;
  Color? backgroundColor;
  ui.Image personImageForUI;
  late double posX, posY, ratio;
  Uint8List? personByte, backgroundByte;
  final Function(imgLib.Image) onAddImage;

  ImPinView({
    required this.personImage,
    required this.personImageForUI,
    required this.backgroundImage,
    required this.backgroundColor,
    required this.onAddImage,
  }) {
    // personByte = Uint8List.fromList(imgLib.encodeJpg(personImage));

    if (backgroundImage != null) {
      backgroundByte = Uint8List.fromList(imgLib.encodeJpg(backgroundImage!));
    }
    posX = posY = 0;
    ratio = 1;
  }

  @override
  _ImageMergingWidgetState createState() => _ImageMergingWidgetState();
}

class _ImageMergingWidgetState extends State<ImPinView> {
  bool isSelectedBg = false;
  GlobalKey globalKey = GlobalKey();
  double ratio = 1;
  double bgRatio = 1;
  double dx = 0;
  double dy = 0;
  double bgDx = 0;
  double bgDy = 0;

  Future<Uint8List?> getPersonImage() async {
    var byteData = await widget.personImageForUI.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xaa000000),
      appBar: AppBar(
        backgroundColor: Color(0xaa000000),
      ),
      body: Center(
        child: Column(children: [
          Container(
            height: ScreenUtil.getStatusBarHeight() + ScreenUtil.getNavigationBarHeight(),
          ),
          FutureBuilder(
              future: getPersonImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Uint8List byteData = snapshot.data as Uint8List;
                  return Expanded(
                    child: RepaintBoundary(
                      key: globalKey,
                      child: PinGestureViews(
                          dx: dx,
                          dy: dy,
                          bgDx: bgDx,
                          bgDy: bgDy,
                          onPinEndCallBack: (bool isSelected, double newRatio, double newDx, double newDy) {
                            if (isSelected == true) {
                              bgRatio = newRatio;
                              bgDx = newDx;
                              bgDy = newDy;
                            } else {
                              ratio = newRatio;
                              dx = newDx;
                              dy = newDy;
                            }
                          },
                          scale: ratio,
                          bgScale: bgRatio,
                          child: Image.memory(
                            byteData,
                            fit: BoxFit.contain,
                          ),
                          bgChild: widget.backgroundImage != null
                              ? Image.memory(
                                  widget.backgroundByte!,
                                  fit: BoxFit.contain,
                                )
                              : Container(
                                  color: widget.backgroundColor!.toArgb(),
                                ),
                          isSelectedBg: isSelectedBg),
                    ),
                  );
                }
                return SizedBox();
              }),
          Container(
            height: $(115),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: $(20),
                ),
                if (widget.backgroundImage != null)
                  Image.asset(
                    Images.ic_switch_images,
                    width: $(24),
                  ).intoGestureDetector(onTap: () {
                    isSelectedBg = !isSelectedBg;
                    if (isSelectedBg) {
                      CommonExtension().showToast("已切换到缩放后边的图片");
                    } else {
                      CommonExtension().showToast("已切换到缩放前边的图片");
                    }
                    setState(() {});
                  }),
                SizedBox(
                  width: $(20),
                ),
                Image.asset(
                  Images.ic_confirm,
                  width: $(24),
                ).intoGestureDetector(onTap: () async {
                  ui.Image? image = await getBitmapFromContext(globalKey.currentContext!, pixelRatio: ScreenUtil.mediaQuery?.devicePixelRatio ?? 3.0);
                  if (image != null) {
                    imgLib.Image img = await getLibImage(image);
                    widget.onAddImage(img);
                  }
                  Navigator.of(context).pop();
                }),
                SizedBox(
                  width: $(20),
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenUtil.getBottomPadding(context)),
        ]),
      ),
    );
  }
}
