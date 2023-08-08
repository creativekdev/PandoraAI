import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/utils/color_util.dart';
import 'package:cartoonizer/views/mine/filter/pin_gesture_views.dart';
import 'package:image/image.dart' as imgLib;

import '../../../Widgets/app_navigation_bar.dart';
import '../../../images-res.dart';
import '../../../utils/utils.dart';
import '../../ai/edition/image_edition.dart';

class ImPinView extends StatefulWidget {
  imgLib.Image personImage;
  imgLib.Image? backgroundImage;
  Color? backgroundColor;
  ui.Image personImageForUI;
  late double posX, posY, ratio;
  Uint8List? personByte, backgroundByte;
  final Function(imgLib.Image) onAddImage;
  final double bottomPadding;
  final double switchButtonPadding;
  final File originFile;

  ImPinView({
    required this.personImage,
    required this.personImageForUI,
    required this.backgroundImage,
    required this.backgroundColor,
    required this.onAddImage,
    this.bottomPadding = 0,
    required this.switchButtonPadding,
    required this.originFile,
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
  bool isShowOrigin = false;
  RxBool isActionBg = false.obs;
  GlobalKey _personImageKey = GlobalKey();

  Future<Uint8List?> getPersonImage() async {
    var byteData = await widget.personImageForUI.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  bool getActionView(Offset tapPosition) {
    RenderBox containerBox = _personImageKey.currentContext!.findRenderObject() as RenderBox;
    Offset containerPosition = containerBox.localToGlobal(Offset.zero);
    double containerWidth = containerBox.size.width;
    double containerHeight = containerBox.size.height;
    bool result = false;
    if (tapPosition.dx >= containerPosition.dx &&
        tapPosition.dx <= containerWidth + dx &&
        tapPosition.dy >= containerPosition.dy &&
        tapPosition.dy <= containerHeight + containerPosition.dy) {
      int pixelColor = widget.personImage.getPixel(tapPosition.dx.toInt(), tapPosition.dy.toInt());
      bool isTransparent = ui.Color(pixelColor).alpha == 0;
      if (!isTransparent) {
        result = false;
      } else {
        result = true;
      }
    } else {
      result = true;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xaa000000),
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
        trailing: Image.asset(Images.ic_edit_submit, width: $(22), height: $(22)).intoGestureDetector(onTap: () async {
          ui.Image? image = await getBitmapFromContext(globalKey.currentContext!, pixelRatio: ScreenUtil.mediaQuery?.devicePixelRatio ?? 3.0);
          if (image != null) {
            imgLib.Image img = await getLibImage(image);
            widget.onAddImage(img);
          }
          Navigator.of(context).pop();
        }).hero(tag: ImageEdition.TagAppbarTagTraining),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              FutureBuilder(
                  future: getPersonImage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      Uint8List byteData = snapshot.data as Uint8List;
                      return Expanded(
                        child: Center(
                          child: Stack(
                            children: [
                              ClipRect(
                                child: RepaintBoundary(
                                  key: globalKey,
                                  child: isShowOrigin
                                      ? Image.file(
                                          widget.originFile,
                                          fit: BoxFit.contain,
                                          width: ScreenUtil.screenSize.width,
                                          height: ScreenUtil.screenSize.width / widget.ratio,
                                        )
                                      : Listener(
                                          onPointerDown: (PointerDownEvent event) {
                                            Offset tapPosition = event.localPosition;
                                            isActionBg.value = getActionView(tapPosition);
                                          },
                                          child: Stack(children: [
                                            Obx(
                                              () => PinGestureView(
                                                  child: widget.backgroundImage != null
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
                                                  scale: bgScale,
                                                  dx: bgDx,
                                                  dy: bgDy,
                                                  minScale: 1.0,
                                                  onPinEndCallBack: (bool isSelected, double newScale, double newDx, double newDy) {
                                                    bgScale = newScale;
                                                    bgDx = newDx;
                                                    bgDy = newDy;
                                                  }).ignore(ignoring: !isActionBg.value),
                                            ),
                                            Obx(
                                              () => PinGestureView(
                                                child: Image.memory(
                                                  key: _personImageKey,
                                                  byteData,
                                                  fit: BoxFit.contain,
                                                  width: ScreenUtil.screenSize.width,
                                                  height: ScreenUtil.screenSize.width / widget.ratio,
                                                ),
                                                scale: scale,
                                                dx: dx,
                                                dy: dy,
                                                onPinEndCallBack: (bool isSelected, double newScale, double newDx, double newDy) {
                                                  scale = newScale;
                                                  dx = newDx;
                                                  dy = newDy;
                                                },
                                              ).ignore(ignoring: isActionBg.value),
                                            ),
                                          ]),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return SizedBox();
                  }),
              SizedBox(height: widget.bottomPadding - ScreenUtil.getBottomPadding(context)),
            ],
          ),
          Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(top: widget.switchButtonPadding - ScreenUtil.getBottomPadding(context) + $(5), right: $(12)),
                  child: Image.asset(Images.ic_switch_images, width: $(24), height: $(24))
                      .intoContainer(
                    padding: EdgeInsets.all($(8)),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular($(32)), color: Color(0x88000000)),
                  )
                      .intoGestureDetector(
                    onTapDown: (details) {
                      isShowOrigin = true;
                      setState(() {});
                    },
                    onTapUp: (details) {
                      isShowOrigin = false;
                      setState(() {});
                    },
                    onTapCancel: () {
                      isShowOrigin = false;
                      setState(() {});
                    },
                  ),
                ),
              ),
              SizedBox(height: widget.bottomPadding - ScreenUtil.getBottomPadding(context)),
            ],
          ),
        ],
      ),
    );
  }
}
