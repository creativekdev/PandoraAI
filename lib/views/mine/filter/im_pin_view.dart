import 'dart:ui' as ui;

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/utils/color_util.dart';
import 'package:cartoonizer/views/mine/filter/pin_gesture_views.dart';
import 'package:image/image.dart' as imgLib;

import '../../../Common/Extension.dart';
import '../../../Widgets/app_navigation_bar.dart';
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
  final double bottomPadding;

  ImPinView({
    required this.personImage,
    required this.personImageForUI,
    required this.backgroundImage,
    required this.backgroundColor,
    required this.onAddImage,
    this.bottomPadding = 0,
  }) {
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
  double scale = 1;
  double bgScale = 1;
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
    print("127.0.0.1 === ${widget.bottomPadding}");
    return Scaffold(
      backgroundColor: Color(0xaa000000),
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(children: [
        FutureBuilder(
            future: getPersonImage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Uint8List byteData = snapshot.data as Uint8List;
                return Expanded(
                  child: Center(
                    child: Stack(
                      children: [
                        RepaintBoundary(
                          key: globalKey,
                          child: PinGestureViews(
                              dx: dx,
                              dy: dy,
                              bgDx: bgDx,
                              bgDy: bgDy,
                              onPinEndCallBack: (bool isSelected, double newScale, double newDx, double newDy) {
                                if (isSelected == true) {
                                  bgScale = newScale;
                                  bgDx = newDx;
                                  bgDy = newDy;
                                } else {
                                  scale = newScale;
                                  dx = newDx;
                                  dy = newDy;
                                }
                              },
                              scale: scale,
                              bgScale: bgScale,
                              child: Image.memory(
                                byteData,
                                fit: BoxFit.contain,
                                width: ScreenUtil.screenSize.width,
                                height: ScreenUtil.screenSize.width / widget.ratio,
                              ),
                              bgChild: widget.backgroundImage != null
                                  ? Image.memory(
                                      widget.backgroundByte!,
                                      fit: BoxFit.contain,
                                      width: ScreenUtil.screenSize.width,
                                      height: ScreenUtil.screenSize.width / widget.ratio,
                                    )
                                  : Container(
                                      color: widget.backgroundColor!.toArgb(),
                                      width: ScreenUtil.screenSize.width,
                                      height: ScreenUtil.screenSize.width / widget.ratio,
                                    ),
                              isSelectedBg: isSelectedBg),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SizedBox();
            }),
        Container(
          height: $(30),
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
        SizedBox(height: widget.bottomPadding - $(30)),

        // SizedBox(height: ScreenUtil.getBottomPadding(context)),
      ]),
    );
  }
}
