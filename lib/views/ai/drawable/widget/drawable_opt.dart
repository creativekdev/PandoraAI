import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/drawable/widget/drawable.dart';

class DrawableOpt extends StatefulWidget {
  DrawableController controller;
  Function onCameraTap;

  DrawableOpt({
    Key? key,
    required this.controller,
    required this.onCameraTap,
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
  late Function onCameraTap;

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
      'mode': 'camera',
      'image': Images.ic_ai_draw_camera,
    }
  ];

  Completer? _completer;
  int isToRight = 1;
  double baseLeft = 0;

  @override
  void initState() {
    super.initState();
    onCameraTap = widget.onCameraTap;
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
              if (e['mode'] is String) {
                return Image.asset(
                  e['image'],
                  color: Colors.black,
                )
                    .intoContainer(
                  width: categoryItemWidth,
                  height: categoryItemWidth,
                  padding: EdgeInsets.all($(4)),
                )
                    .intoGestureDetector(onTap: () {
                  onCameraTap.call();
                });
              } else {
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
                });
              }
            },
          ),
        ),
      ],
    );
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
