import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Controller/ChoosePhotoScreenController.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:flutter/gestures.dart';
import 'package:vibration/vibration.dart';

class PickPhotoScreen {
  static Future<bool?> push(
    BuildContext context, {
    Key? key,
    required ChoosePhotoScreenController controller,
    required OnPickFromSystem onPickFromSystem,
    required OnPickFromRecent onPickFromRecent,
    required double imageContainerHeight,
  }) {
    return Navigator.of(context).push<bool>(NoAnimRouter(
      _PickPhotoScreen(
        key: key,
        controller: controller,
        onPickFromSystem: onPickFromSystem,
        onPickFromRecent: onPickFromRecent,
        imageContainerHeight: imageContainerHeight,
      ),
    ));
  }
}

typedef OnPickFromSystem = Future<bool> Function(bool takePhoto);
typedef OnPickFromRecent = Future<bool> Function(UploadRecordEntity entity);

class _PickPhotoScreen extends StatefulWidget {
  ChoosePhotoScreenController controller;
  OnPickFromSystem onPickFromSystem;
  OnPickFromRecent onPickFromRecent;
  double imageContainerHeight;

  _PickPhotoScreen({
    Key? key,
    required this.controller,
    required this.onPickFromSystem,
    required this.onPickFromRecent,
    required this.imageContainerHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PickPhotoScreenState();
  }
}

class PickPhotoScreenState extends State<_PickPhotoScreen> with TickerProviderStateMixin {
  late ChoosePhotoScreenController controller;
  late AnimationController entryAnimController;
  late AnimationController dragAnimController;
  late AnimationController titleAlphaController;

  late double appBarHeight;
  bool canBeDragged = true;
  late double maxSlide;
  late double listHeight;
  final double dragWidgetHeight = 44;
  final double deleteContainerHeight = 40;
  late bool lastDragDirection = true;
  late StreamSubscription containerHeightListener;
  late double imageContainerHeight;
  late double lineHeight;

  bool selectedMode = false;

  @override
  dispose() {
    super.dispose();
    containerHeightListener.cancel();
  }

  @override
  initState() {
    super.initState();
    controller = widget.controller;
    imageContainerHeight = widget.imageContainerHeight;
    containerHeightListener = EventBusHelper().eventBus.on<OnPickPhotoHeightChangeEvent>().listen((event) {
      setState(() {
        imageContainerHeight = ((event.data! ~/ lineHeight) + 0.4) * lineHeight;
      });
    });
    calculateListHeight();
    dragAnimController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    entryAnimController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: controller.isPhotoSelect.value ? 300 : 200,
        ));
    entryAnimController.forward();
    delay(() => entryAnimController.duration = Duration(milliseconds: 300), milliseconds: 600);
  }

  void calculateListHeight() {
    appBarHeight = ScreenUtil.getStatusBarHeight() + 44;
    var width = ScreenUtil.screenSize.width - 24;
    lineHeight = width / 4;
    if (controller.imageUploadCache.length > 6) {
      listHeight = width * 0.5 + $(50);
    } else {
      var totalLength = controller.imageUploadCache.length + 2;
      int line = (totalLength) ~/ 4;
      if (totalLength % 4 != 0) {
        line++;
      }
      if (line > 2) {
        line = 2;
      }
      listHeight = width / 4 * line + $(50);
    }
    maxSlide = ScreenUtil.screenSize.height - listHeight - dragWidgetHeight + 10;
  }

  toggle() => dragAnimController.isDismissed ? dragAnimController.forward() : dragAnimController.reverse();
  MyVerticalDragGestureRecognizer dragGestureRecognizer = MyVerticalDragGestureRecognizer();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: GetBuilder(
          init: controller,
          builder: (_) => SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: AnimatedBuilder(
              animation: dragAnimController,
              builder: (context, child) {
                double offsetY = -maxSlide * dragAnimController.value;
                double alpha = 0;
                if (dragAnimController.value > 0.5) {
                  alpha = (dragAnimController.value - 0.5) * 2;
                }
                double titleAlpha = 1;
                if (dragAnimController.value < 0.5) {
                  titleAlpha = (dragAnimController.value - 0.5) * 2;
                }
                return Stack(
                  children: [
                    FadeTransition(
                      opacity: entryAnimController,
                      child: Container(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        color: Color(0x77000000),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, offsetY),
                      child: GestureDetector(
                        onTap: () {
                          if (dragAnimController.isDismissed && controller.isPhotoSelect.value) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          child: AnimatedBuilder(
                              animation: entryAnimController,
                              builder: (context, child) {
                                return Transform.translate(
                                    offset: Offset(0, ScreenUtil.screenSize.height - listHeight * entryAnimController.value),
                                    child: NotificationListener<ScrollStartNotification>(
                                      onNotification: (notification) {
                                        dragGestureRecognizer.needDrag = false; // 内部开始滑动时关闭开关
                                        return false;
                                      },
                                      child: NotificationListener<OverscrollNotification>(
                                        onNotification: (notification) {
                                          if (notification.metrics.axis == Axis.vertical) {
                                            if (notification.dragDetails!.delta.dy > 0) {
                                              dragGestureRecognizer.needDrag = true;
                                            } else {
                                              dragGestureRecognizer.needDrag = false;
                                            }
                                          }
                                          return false;
                                        },
                                        child: Listener(
                                          onPointerDown: (pointer) {
                                            dragGestureRecognizer.addPointer(pointer);
                                            dragGestureRecognizer.onDragStart = onDragStart;
                                            dragGestureRecognizer.onDragUpdate = onDragUpdate;
                                            dragGestureRecognizer.onDragEnd = onDragEnd;
                                          },
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TitleTextWidget("Choose Photo", Color.fromRGBO(255, 255, 255, 1 - titleAlpha), FontWeight.w400, $(14)).intoContainer(
                                                  height: dragWidgetHeight,
                                                  width: double.maxFinite,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                                                    color: ColorConstant.BackgroundColor,
                                                  ),
                                                  alignment: Alignment.centerLeft,
                                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                                ),
                                                GridView.builder(
                                                  physics: (dragAnimController.isDismissed) ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
                                                  padding:
                                                      EdgeInsets.only(left: 12, right: 12, top: dragAnimController.isCompleted ? (selectedMode ? deleteContainerHeight : 0) : 0),
                                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4,
                                                    mainAxisSpacing: $(2),
                                                    crossAxisSpacing: $(2),
                                                  ),
                                                  itemBuilder: (context, pos) {
                                                    return buildListItem(pos, context);
                                                  },
                                                  itemCount: controller.imageUploadCache.length + 2,
                                                ).intoContainer(
                                                  width: double.maxFinite,
                                                  height: dragAnimController.isDismissed ? listHeight : imageContainerHeight,
                                                  color: ColorConstant.BackgroundColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ));
                              }),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: alpha,
                      child: AppNavigationBar(
                          backgroundColor: ColorConstant.BackgroundColor,
                          backAction: () {
                            if (dragAnimController.isCompleted) {
                              dragAnimController.reverse();
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          middle: Text(
                            "Choose Photo",
                            style: TextStyle(color: Colors.white),
                          )).intoContainer(height: appBarHeight),
                    ),
                    Row(
                      children: [
                        TitleTextWidget("Select All", Colors.red, FontWeight.normal, $(15)).paddingSymmetric(vertical: 6, horizontal: 15).intoGestureDetector(onTap: () {
                          controller.imageUploadCache.forEach((element) {
                            element.checked = true;
                          });
                          setState(() {});
                        }),
                        Expanded(
                            child: Container(
                          child: Image.asset(
                            Images.ic_recent_delete,
                            height: $(22),
                          ).intoGestureDetector(onTap: () {
                            showDeleteDialog(context).then((value) {
                              if (value ?? false) {
                                controller.deleteAllCheckedPhotos();
                                setState(() {});
                              }
                            });
                          }),
                        )),
                        TitleTextWidget("  Cancel  ", Colors.white, FontWeight.normal, $(15)).paddingSymmetric(vertical: 6, horizontal: 15).intoGestureDetector(onTap: () {
                          if (controller.imageUploadCache.exist((t) => t.checked)) {
                            controller.imageUploadCache.forEach((element) {
                              element.checked = false;
                            });
                          } else {
                            selectedMode = false;
                          }
                          setState(() {});
                        }),
                      ],
                    )
                        .intoContainer(
                            height: deleteContainerHeight,
                            color: ColorConstant.BackgroundColor,
                            margin: EdgeInsets.only(top: dragAnimController.isDismissed ? ScreenUtil.screenSize.height - deleteContainerHeight : appBarHeight))
                        .visibility(visible: selectedMode && !dragAnimController.isAnimating),
                  ],
                );
              },
            ),
          ),
        ).intoMaterial(color: Colors.transparent),
        onWillPop: () async {
          if (selectedMode) {
            setState(() {
              selectedMode = false;
            });
            return false;
          }
          if (dragAnimController.isCompleted) {
            dragAnimController.reverse();
            return false;
          }
          return true;
        });
  }

  Widget buildListItem(int pos, BuildContext context) {
    if (pos == 0) {
      return Image.asset(
        Images.ic_choose_camera,
        color: ColorConstant.White,
      )
          .intoContainer(
        color: ColorConstant.LineColor,
        padding: EdgeInsets.symmetric(vertical: $(24)),
      )
          .intoGestureDetector(onTap: () {
        widget.onPickFromSystem.call(true).then((value) {
          if (value) {
            Navigator.of(context).pop(true);
          }
        });
      });
    } else if (pos == 1) {
      return Image.asset(
        Images.ic_choose_photo,
        color: ColorConstant.White,
      )
          .intoContainer(
        color: ColorConstant.LineColor,
        padding: EdgeInsets.symmetric(vertical: $(24)),
      )
          .intoGestureDetector(onTap: () {
        widget.onPickFromSystem.call(false).then((value) {
          if (value) {
            Navigator.of(context).pop(true);
          }
        });
      });
    }
    var index = pos - 2;
    var data = controller.imageUploadCache[index];
    return (selectedMode
            ? Stack(
                children: [
                  Image(
                    image: FileImage(File(data.fileName)),
                    fit: BoxFit.cover,
                  ).intoContainer(width: double.maxFinite, height: double.maxFinite),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: data.checked
                        ? Image.asset(Images.ic_recent_checked, width: $(16))
                        : Container(
                            width: $(16),
                            height: $(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                  ),
                ],
              )
            : Image(
                image: FileImage(File(controller.imageUploadCache[index].fileName)),
                fit: BoxFit.cover,
              ).intoContainer(width: double.maxFinite, height: double.maxFinite))
        .intoGestureDetector(onLongPress: () {
      if (!selectedMode) {
        setState(() {
          selectedMode = true;
        });
        Vibration.hasVibrator().then((value) {
          if (value ?? false) {
            Vibration.vibrate(duration: 100);
          }
        });
      }
    }, onTap: () {
      if (selectedMode) {
        setState(() {
          data.checked = !data.checked;
        });
      } else {
        var entity = data;
        if (controller.image.value != null && (controller.image.value as File).path == entity.fileName) {
          CommonExtension().showToast("You've chosen this photo already");
          return;
        }
        widget.onPickFromRecent(entity).then((value) {
          if (value) {
            Navigator.of(context).pop(true);
          }
        });
      }
    });
  }

  onDragStart(DragStartDetails details) {
    canBeDragged = dragAnimController.isDismissed || dragAnimController.isCompleted;
  }

  onDragUpdate(DragUpdateDetails details) {
    if (canBeDragged) {
      double value = -details.primaryDelta! / maxSlide;
      if (value != 0) {
        lastDragDirection = value < 0;
      }
      dragAnimController.value += value;
    }
  }

  onDragEnd(DragEndDetails details) {
    if (dragAnimController.isDismissed || dragAnimController.isCompleted) {
      return;
    }
    if (lastDragDirection) {
      dragAnimController.reverse();
    } else {
      dragAnimController.forward();
    }
  }

  Future<bool?> showDeleteDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Are you sure to delete those photos',
            style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
            textAlign: TextAlign.center,
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
          Row(
            children: [
              Expanded(
                  child: Text(
                'Delete',
                style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.red),
              )
                      .intoContainer(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                            top: BorderSide(color: ColorConstant.LineColor, width: 1),
                            right: BorderSide(color: ColorConstant.LineColor, width: 1),
                          )))
                      .intoGestureDetector(onTap: () async {
                Navigator.pop(context, true);
              })),
              Expanded(
                  child: Text(
                'Cancel',
                style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
              )
                      .intoContainer(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                            top: BorderSide(color: ColorConstant.LineColor, width: 1),
                          )))
                      .intoGestureDetector(onTap: () {
                Navigator.pop(context, false);
              })),
            ],
          ),
        ],
      )
          .intoMaterial(
            color: ColorConstant.EffectFunctionGrey,
            borderRadius: BorderRadius.circular($(16)),
          )
          .intoContainer(
            padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
            margin: EdgeInsets.symmetric(horizontal: $(35)),
          )
          .intoCenter(),
    );
  }
}

class MyVerticalDragGestureRecognizer extends VerticalDragGestureRecognizer {
  bool needDrag = true;
  GestureDragStartCallback? onDragStart;
  GestureDragUpdateCallback? onDragUpdate;
  GestureDragEndCallback? onDragEnd;

  MyVerticalDragGestureRecognizer() {
    this.onStart = (details) {
      if (needDrag) {
        onDragStart?.call(details);
      }
    };
    this.onUpdate = (details) {
      if (needDrag) {
        onDragUpdate?.call(details);
      }
    };
    this.onEnd = (details) {
      if (needDrag) {
        onDragEnd?.call(details);
      }
    };
  }

  @override
  rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
