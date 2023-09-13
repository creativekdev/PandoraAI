import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/widgets/gallery/crop_screen.dart';
import 'package:cartoonizer/widgets/gallery/pick_album.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:cartoonizer/views/ai/drawable/scribble/widget/drawable.dart';
import 'package:image_picker/image_picker.dart';

class DrawableOpt extends StatefulWidget {
  DrawableController controller;

  DrawableOpt({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<DrawableOpt> createState() => DrawableOptState();
}

class DrawableOptState extends State<DrawableOpt> with TickerProviderStateMixin {
  late AnimationController _visibleAnimation;
  late CurvedAnimation _visibleCurve;
  late AnimationController _transAnimation;
  late CurvedAnimation _transCurve;
  late DrawableController controller;
  late double categoryHorizontalSpace;
  late double marginHorizontalSpace;
  late double categoryItemWidth;
  late double animDistance;

  bool aniInProgress = false;
  List<Map<String, dynamic>> optList = [
    {
      'mode': DrawMode.paint,
      'image': Images.ic_pencil,
    },
    {
      'mode': DrawMode.markPaint,
      'image': Images.ic_mark_pen,
    },
    {
      'mode': DrawMode.eraser,
      'image': Images.ic_eraser,
    },
    {
      'mode': DrawMode.camera,
      'image': Images.ic_ai_draw_camera,
    }
  ];

  Completer? _completer;
  int isToRight = 1;
  double baseLeft = 0;

  @override
  void initState() {
    super.initState();
    marginHorizontalSpace = $(15);
    categoryHorizontalSpace = $(50);
    categoryItemWidth = $(36);
    animDistance = (ScreenUtil.screenSize.width - 2 * marginHorizontalSpace - 2 * categoryHorizontalSpace - optList.length * categoryItemWidth) / (optList.length - 1);
    _visibleAnimation = AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    _visibleCurve = CurvedAnimation(parent: _visibleAnimation, curve: Curves.easeInOut);
    _transAnimation = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _transCurve = CurvedAnimation(parent: _transAnimation, curve: Curves.ease);
    controller = widget.controller;
    _transAnimation.addListener(() {
      if (_transAnimation.value > 0.3) {
        if (!aniInProgress) {
          setState(() {
            aniInProgress = true;
          });
        }
      } else {
        if (aniInProgress) {
          setState(() {
            aniInProgress = false;
          });
        }
      }
    });
    _transAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completer?.complete();
      }
    });
  }

  dismiss() {
    if (mounted) {
      if (_visibleAnimation.isCompleted) {
        _visibleAnimation.reverse();
      }
    }
  }

  @override
  void dispose() {
    _visibleAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: null,
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        children: [
          AnimatedBuilder(
              animation: _visibleCurve,
              builder: (context, child) {
                return Container(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PaintWidthSelector(
                          controller: controller,
                          onSelect: (value) {
                            if (controller.drawMode == DrawMode.paint) {
                              controller.paintWidth = value;
                            } else if (controller.drawMode == DrawMode.markPaint) {
                              controller.markPaintWidth = value;
                            } else if (controller.drawMode == DrawMode.eraser) {
                              controller.eraserWidth = value;
                            }
                          },
                        ),
                        AnimatedBuilder(
                          animation: _transCurve,
                          builder: (context, child) {
                            return Container(
                              child: child,
                              margin: EdgeInsets.only(left: baseLeft + isToRight * (categoryItemWidth + animDistance) * _transCurve.value),
                            );
                          },
                          child: Container(
                            child: Image.asset(
                              Images.ic_drawable_arrow,
                              height: $(10),
                              color: ColorConstant.White,
                            ),
                            width: categoryItemWidth,
                            height: $(10),
                            alignment: Alignment.center,
                          ),
                        ).intoContainer(
                          padding: EdgeInsets.symmetric(horizontal: categoryHorizontalSpace),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(),
                              flex: controller.drawMode == DrawMode.paint
                                  ? 1
                                  : controller.drawMode == DrawMode.markPaint
                                      ? 3
                                      : 4,
                            ),
                            Expanded(
                              child: Container(),
                              flex: controller.drawMode == DrawMode.paint
                                  ? 4
                                  : controller.drawMode == DrawMode.markPaint
                                      ? 3
                                      : 1,
                            ),
                          ],
                        ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(6))),
                        SizedBox(height: $(2)),
                      ],
                    ),
                    physics: NeverScrollableScrollPhysics(),
                  ),
                  height: $(64) * _visibleCurve.value,
                ).intoGestureDetector(onTap: () {}).visibility(visible: !_visibleAnimation.isDismissed);
              }),
          buildOptList().intoContainer(
              padding: EdgeInsets.symmetric(vertical: $(8), horizontal: categoryHorizontalSpace),
              decoration: BoxDecoration(
                color: ColorConstant.aiDrawGrey,
                borderRadius: BorderRadius.circular($(8)),
              )),
        ],
      ).intoContainer(
          padding: EdgeInsets.only(
        bottom: ScreenUtil.getBottomPadding(context),
        left: marginHorizontalSpace,
        right: marginHorizontalSpace,
      )),
    );
  }

  Widget buildOptList() {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _transCurve,
          builder: (context, child) {
            return Container(
              child: child,
              margin: EdgeInsets.only(left: baseLeft + isToRight * (categoryItemWidth + animDistance) * _transCurve.value),
            );
          },
          child: Container(
              width: categoryItemWidth,
              height: categoryItemWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($(8)),
                color: ColorConstant.aiDrawBlue,
              )),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: optList.transfer(
            (e, index) {
              DrawMode mode = e['mode'];
              bool check = controller.drawMode == mode;
              return Image.asset(
                e['image'],
                color: aniInProgress
                    ? Colors.black
                    : check
                        ? Colors.white
                        : Colors.black,
              )
                  .intoContainer(
                width: categoryItemWidth,
                height: categoryItemWidth,
                padding: EdgeInsets.all($(4)),
              )
                  .intoGestureDetector(onTap: () {
                if (mode == DrawMode.camera) {
                  if (_visibleAnimation.status == AnimationStatus.completed) {
                    _visibleAnimation.reverse();
                  }
                  showModalBottomSheet<bool>(
                      context: context,
                      builder: (ctxt) {
                        return Column(
                          children: [
                            SizedBox(height: $(5)),
                            Text(
                              S.of(context).take_a_selfie,
                              style: TextStyle(
                                fontSize: $(18),
                                fontFamily: 'Poppins',
                              ),
                            ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
                              Navigator.of(ctxt).pop(true);
                            }),
                            Divider(height: 1, color: ColorConstant.LineColor),
                            Text(
                              S.of(context).select_from_album,
                              style: TextStyle(
                                fontSize: $(18),
                                fontFamily: 'Poppins',
                              ),
                            ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
                              Navigator.of(ctxt).pop(false);
                            }),
                          ],
                          mainAxisSize: MainAxisSize.min,
                        ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context))).intoMaterial();
                      }).then((value) {
                    if (value != null) {
                      if (value) {
                        choosePhoto(context, controller, true);
                      } else {
                        choosePhoto(context, controller, false);
                      }
                    }
                  });
                } else {
                  if (controller.activePens.isNotEmpty && controller.activePens.last.drawMode == DrawMode.camera) {
                    CommonExtension().showToast('Cannot edit on photo mode!');
                    return;
                  }
                  if (controller.drawMode != mode) {
                    switchMode(index, currentIndex()).whenComplete(() {
                      refreshBaseLeft(index);
                      controller.drawMode = mode;
                      _transAnimation.reset();
                      if (_visibleAnimation.status == AnimationStatus.dismissed) {
                        _visibleAnimation.forward();
                      }
                    });
                  } else {
                    if (_visibleAnimation.status == AnimationStatus.dismissed) {
                      _visibleAnimation.forward();
                    } else if (_visibleAnimation.status == AnimationStatus.completed) {
                      _visibleAnimation.reverse();
                    }
                  }
                }
              });
            },
          ),
        ),
      ],
    );
  }

  void choosePhoto(BuildContext context, DrawableController drawableController, bool fromCamera) {
    PermissionsUtil.checkPermissions().then((value) async {
      if (value) {
        XFile? result;
        if (fromCamera) {
          var pickImage = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 512, maxHeight: 512, preferredCameraDevice: CameraDevice.rear, imageQuality: 100);
          if (pickImage != null) {
            Events.aidrawCameraClick(source: drawableController.source, photoType: 'camera');
            var f = await CropScreen.crop(context, image: pickImage, brightness: Brightness.light);
            if (f != null) {
              result = f;
            } else {
              var p = await ImageUtils.onImagePick(pickImage.path, AppDelegate().getManager<CacheManager>().storageOperator.recordAiDrawDir.path);
              result = XFile(p);
            }
          }
        } else {
          var files = await PickAlbumScreen.pickImage(
            context,
            count: 1,
            switchAlbum: true,
          );
          if (files != null && files.isNotEmpty) {
            var medium = files.first;
            var file = await medium.originFile;
            if (file != null) {
              Events.aidrawCameraClick(source: drawableController.source, photoType: 'gallery');
              var f = await CropScreen.crop(context, image: XFile(file.path), brightness: Brightness.light);
              if (f != null) {
                result = f;
              } else {
                var p = await ImageUtils.onImagePick(file.path, AppDelegate().getManager<CacheManager>().storageOperator.recordAiDrawDir.path);
                result = XFile(p);
              }
            }
          }
        }
        if (result != null) {
          var pick = drawableController.activePens.pick((t) => t.drawMode == DrawMode.camera);
          if (pick != null) {
            drawableController.activePens.remove(pick);
          }
          var pick2 = drawableController.checkmatePens.pick((t) => t.drawMode == DrawMode.camera);
          if (pick2 != null) {
            drawableController.checkmatePens.remove(pick2);
          }
          var pen = DrawablePen(drawMode: DrawMode.camera, filePath: result.path, source: fromCamera ? 'camera' : 'gallery');
          await pen.buildImage();
          drawableController.addPens(pen);
        }
      } else {
        PermissionsUtil.permissionDenied(context);
      }
    });
  }

  int currentIndex() {
    return optList.findPosition((data) => data['mode'] == controller.drawMode) ?? 0;
  }

  Future switchMode(int index, int oldIndex) async {
    preAnim(index, oldIndex);
    refreshBaseLeft(oldIndex);
    _completer = Completer();
    _transAnimation.forward();
    return _completer!.future;
  }

  void preAnim(int index, int oldIndex) {
    isToRight = index - oldIndex;
  }

  void refreshBaseLeft(int index) {
    baseLeft = index * (animDistance + categoryItemWidth);
  }
}

class PaintWidthSelector extends StatefulWidget {
  DrawableController controller;
  Function(double value) onSelect;

  PaintWidthSelector({
    Key? key,
    required this.controller,
    required this.onSelect,
  }) : super(key: key);

  @override
  PaintWidthSelectorState createState() {
    return PaintWidthSelectorState();
  }
}

class PaintWidthSelectorState extends State<PaintWidthSelector> with SingleTickerProviderStateMixin {
  late DrawableController controller;

  late AnimationController _transAnimation;
  late CurvedAnimation _transCurve;
  List<Map<String, dynamic>> list = [];
  late double marginHorizontalSpace;
  late double itemWidth;
  late double animDistance;

  Completer? _completer;
  int isToRight = 1;
  double baseLeft = 0;
  bool aniInProgress = false;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    list = controller.getPainSize();
    marginHorizontalSpace = $(15);
    itemWidth = $(36);
    animDistance = (ScreenUtil.screenSize.width - $(30) - 2 * marginHorizontalSpace - list.length * itemWidth) / (list.length - 1);
    _transAnimation = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _transCurve = CurvedAnimation(parent: _transAnimation, curve: Curves.ease);
    _transAnimation.addListener(() {
      if (_transAnimation.value > 0.3) {
        if (!aniInProgress) {
          setState(() {
            aniInProgress = true;
          });
        }
      } else {
        if (aniInProgress) {
          setState(() {
            aniInProgress = false;
          });
        }
      }
    });
    _transAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completer?.complete();
      }
    });
  }

  @override
  void didUpdateWidget(covariant PaintWidthSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    list = controller.getPainSize();
    refreshBaseLeft(currentIndex());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _transCurve,
          builder: (context, child) {
            return Container(
              child: child,
              margin: EdgeInsets.only(left: baseLeft + isToRight * (itemWidth + animDistance) * _transCurve.value),
            );
          },
          child: Container(
              width: itemWidth,
              height: itemWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($(8)),
                color: ColorConstant.aiDrawBlue,
              )),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: list.transfer(
            (e, index) {
              var checked = controller.currentStrokeWidth(controller.drawMode) == e['size'];
              return Image.asset(
                e['image'],
                width: $(24),
                height: $(24),
                color: aniInProgress
                    ? Colors.black
                    : checked
                        ? Colors.white
                        : Colors.black,
              )
                  .intoCenter()
                  .intoContainer(
                    width: itemWidth,
                    height: itemWidth,
                  )
                  .intoContainer(color: Colors.transparent)
                  .intoGestureDetector(onTap: () {
                if (!checked) {
                  switchMode(index, currentIndex()).whenComplete(() {
                    refreshBaseLeft(index);
                    widget.onSelect.call(e['size']);
                    _transAnimation.reset();
                  });
                }
              });
            },
          ),
        ),
      ],
    )
        .intoContainer(
          margin: EdgeInsets.symmetric(vertical: $(8)),
          padding: EdgeInsets.symmetric(horizontal: $(15)),
        )
        .intoMaterial(
          elevation: 10,
          shadowColor: ColorConstant.aiDrawGrey,
          color: Colors.white,
          borderRadius: BorderRadius.circular($(8)),
        );
  }

  int currentIndex() {
    return list.findPosition((data) => data['size'] == controller.currentStrokeWidth(controller.drawMode)) ?? 0;
  }

  Future switchMode(int index, int oldIndex) async {
    preAnim(index, oldIndex);
    refreshBaseLeft(oldIndex);
    _completer = Completer();
    _transAnimation.forward();
    return _completer!.future;
  }

  void preAnim(int index, int oldIndex) {
    isToRight = index - oldIndex;
  }

  void refreshBaseLeft(int index) {
    baseLeft = index * (animDistance + itemWidth);
  }
}
