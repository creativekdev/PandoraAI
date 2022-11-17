import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Controller/ChoosePhotoScreenController.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/refresh/headers.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Controller/album_controller.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/photo_source.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:cartoonizer/views/transfer/choose_tab_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vibration/vibration.dart';

class PickPhotoScreen {
  static Future<bool?> push(
    BuildContext context, {
    Key? key,
    required ChoosePhotoScreenController controller,
    required OnPickFromSystem onPickFromSystem,
    required OnPickFromRecent onPickFromRecent,
    required Widget floatWidget,
  }) {
    return Navigator.of(context).push<bool>(NoAnimRouter(
      _PickPhotoScreen(
        key: key,
        controller: controller,
        onPickFromSystem: onPickFromSystem,
        onPickFromRecent: onPickFromRecent,
        floatWidget: floatWidget,
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
  Widget floatWidget;

  _PickPhotoScreen({
    Key? key,
    required this.controller,
    required this.onPickFromSystem,
    required this.onPickFromRecent,
    required this.floatWidget,
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
  late double lineHeight;
  late Widget floatWidget;

  bool selectedMode = false;

  bool result = false;
  MyVerticalDragGestureRecognizer dragGestureRecognizer = MyVerticalDragGestureRecognizer();

  List<PhotoSource> tabs = [PhotoSource.recent, PhotoSource.albumFace, PhotoSource.album];
  int currentIndex = 0;

  AlbumController albumController = Get.find();

  @override
  dispose() {
    super.dispose();
    entryAnimController.dispose();
    dragAnimController.dispose();
  }

  @override
  initState() {
    super.initState();
    floatWidget = widget.floatWidget;
    controller = widget.controller;
    dragGestureRecognizer.onDragStart = onDragStart;
    dragGestureRecognizer.onDragUpdate = onDragUpdate;
    dragGestureRecognizer.onDragEnd = onDragEnd;
    calculateListHeight();
    dragAnimController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    entryAnimController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: controller.isPhotoSelect.value ? 300 : 300,
        ));
    entryAnimController.forward();
    entryAnimController.addStatusListener((status) {
      if (status == AnimationStatus.reverse) {
        Navigator.of(context).pop(result);
      }
    });
    dragAnimController.addStatusListener((status) {
      if (status == AnimationStatus.reverse) {
        setState(() {
          selectedMode = false;
        });
      }
    });
    delay(() => entryAnimController.duration = Duration(milliseconds: 300), milliseconds: 600);
  }

  onBackClick(bool result) {
    this.result = result;
    entryAnimController.reverse();
  }

  void calculateListHeight() {
    appBarHeight = ScreenUtil.getStatusBarHeight() + 44;
    var width = ScreenUtil.screenSize.width - 24;
    lineHeight = width / 4;
    if (controller.imageUploadCache.length > 6) {
      listHeight = width * 0.5 + $(70);
    } else {
      var totalLength = controller.imageUploadCache.length + 2;
      int line = (totalLength) ~/ 4;
      if (totalLength % 4 != 0) {
        line++;
      }
      if (line > 2) {
        line = 2;
      }
      listHeight = lineHeight * line + $(70);
    }
    listHeight += ScreenUtil.getBottomBarHeight();
    maxSlide = ScreenUtil.screenSize.height - listHeight - (Platform.isIOS ? 38 : 20);
  }

  toggle() => dragAnimController.isDismissed ? dragAnimController.forward() : dragAnimController.reverse();

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      child: WillPopScope(
          child: GetBuilder(
            init: controller,
            builder: (_) => SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Stack(
                children: [
                  FadeTransition(
                    opacity: entryAnimController,
                    child: Container(
                      width: ScreenUtil.screenSize.width,
                      height: ScreenUtil.screenSize.height,
                      color: Color(0x77000000),
                    ).intoGestureDetector(onTap: () {
                      if (dragAnimController.isDismissed) {
                        if (selectedMode) {
                          setState(() {
                            selectedMode = false;
                          });
                        } else {
                          onBackClick(false);
                        }
                      }
                    }),
                  ),
                  AnimatedBuilder(
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
                          Transform.translate(
                            offset: Offset(0, offsetY),
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
                                                if ((notification.dragDetails?.delta.dy ?? 1) > 0) {
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
                                                    ChooseTabBar(
                                                      tabList: tabs.map((e) => e.title().toString()).toList(),
                                                      onTabClick: (index) {
                                                        if (tabs[index].isAiSource()) {
                                                          albumController.checkPermissions().then((value) {
                                                            if (value.isGranted) {
                                                              albumController.syncFromAlbum();
                                                              setState(() {
                                                                currentIndex = index;
                                                              });
                                                            } else {
                                                              CommonExtension().showToast("Please grant permissions");
                                                            }
                                                          });
                                                        } else {
                                                          setState(() {
                                                            currentIndex = index;
                                                          });
                                                        }
                                                      },
                                                      currentIndex: currentIndex,
                                                      height: 36,
                                                    ).intoContainer(color: ColorConstant.BackgroundColor),
                                                    (tabs[currentIndex].isAiSource() ? buildFromAiSource() : buildFromRecent()).intoContainer(
                                                      width: double.maxFinite,
                                                      height: dragAnimController.isDismissed ? listHeight : ScreenUtil.screenSize.height - appBarHeight - dragWidgetHeight,
                                                      color: ColorConstant.BackgroundColor,
                                                    ),
                                                    Container(height: MediaQuery.of(context).padding.bottom + 20, color: ColorConstant.BackgroundColor),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ));
                                  }),
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
                                  onBackClick(false);
                                }
                              },
                              middle: Text(
                                "Choose Photo",
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: TitleTextWidget(selectedMode ? 'Cancel' : 'Edit', Colors.white, FontWeight.w400, $(15)).intoGestureDetector(
                                onTap: () {
                                  if (!dragAnimController.isCompleted) {
                                    return;
                                  }
                                  if (!selectedMode) {
                                    setState(() {
                                      selectedMode = true;
                                    });
                                    Vibration.hasVibrator().then((value) {
                                      if (value ?? false) {
                                        Vibration.vibrate(duration: 50);
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      selectedMode = false;
                                    });
                                  }
                                },
                              ),
                            ).intoContainer(height: appBarHeight),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TitleTextWidget(controller.imageUploadCache.exist((t) => !t.checked) ? "Select All" : "Unselect", ColorConstant.BlueColor, FontWeight.normal, $(15))
                                  .paddingSymmetric(vertical: 6, horizontal: 15)
                                  .intoGestureDetector(onTap: () {
                                if (controller.imageUploadCache.exist((t) => !t.checked)) {
                                  controller.imageUploadCache.forEach((element) {
                                    element.checked = true;
                                  });
                                } else {
                                  controller.imageUploadCache.forEach((element) {
                                    element.checked = false;
                                  });
                                }
                                setState(() {});
                              }),
                              TitleTextWidget("Delete", controller.imageUploadCache.exist((t) => t.checked) ? Colors.white : ColorConstant.EffectGrey, FontWeight.normal, $(15))
                                  .paddingSymmetric(vertical: 6, horizontal: 15)
                                  .intoGestureDetector(onTap: () {
                                if (!controller.imageUploadCache.exist((t) => t.checked)) {
                                  return;
                                }
                                showDeleteDialog(context).then((value) {
                                  if (value ?? false) {
                                    controller.deleteAllCheckedPhotos();
                                    setState(() {});
                                  }
                                });
                              }),
                            ],
                          )
                              .intoContainer(
                                  height: deleteContainerHeight,
                                  color: ColorConstant.BackgroundColor,
                                  margin: EdgeInsets.only(top: ScreenUtil.screenSize.height - deleteContainerHeight - ScreenUtil.getBottomBarHeight()))
                              .visibility(visible: selectedMode && !dragAnimController.isAnimating),
                        ],
                      );
                    },
                  ),
                  floatCurrentItem(),
                ],
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
            onBackClick(false);
            return false;
          }),
      removeTop: true,
    );
  }

  Positioned floatCurrentItem() => Positioned(
        child: AnimatedBuilder(
          animation: dragAnimController,
          builder: (context, child) {
            double alpha = 0;
            if (dragAnimController.value > 0.5) {
              alpha = (dragAnimController.value - 0.5) * 2;
            }
            return Opacity(
              opacity: alpha,
              child: Container(
                width: lineHeight,
                height: lineHeight,
                child: OutlineWidget(
                    radius: $(6),
                    strokeWidth: 3,
                    gradient: LinearGradient(
                      colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Container(
                      padding: EdgeInsets.all($(3)),
                      child: ClipRRect(
                        child: floatWidget,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
              ),
            );
          },
        ),
        top: appBarHeight + 30,
        right: 12,
      );

  Widget buildFromAiSource() => GetBuilder<AlbumController>(
        builder: (albumController) {
          var itemCount = (tabs[currentIndex] == PhotoSource.album ? albumController.otherList.length : albumController.faceList.length) + 2 + (albumController.loading ? 1 : 0);
          return GridView.builder(
            physics: (dragAnimController.isDismissed) ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
            padding: EdgeInsets.only(left: 12, right: 12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: $(2),
              crossAxisSpacing: $(2),
            ),
            itemBuilder: (context, index) {
              if (index < 2) {
                return buildSystemAlbumItem(index, context)!;
              }
              if (albumController.loading) {
                if (index == 2) {
                  return FrameAnimatedSvg(
                    child: SvgPicture.asset(Images.ic_refresh_header),
                  ).intoContainer(width: $(20), height: $(20)).intoCenter();
                } else {
                  return buildAiSourceItem(index - 3, context, albumController);
                }
              } else {
                return buildAiSourceItem(index - 2, context, albumController);
              }
            },
            itemCount: itemCount,
          );
        },
        init: albumController,
      );

  Widget buildAiSourceItem(int index, BuildContext context, AlbumController controller) {
    var dataList = tabs[currentIndex] == PhotoSource.albumFace ? controller.faceList : controller.otherList;
    var data = dataList[index];
    return Image(
      image: FileImage(File(data.thumbPath!)),
      fit: BoxFit.cover,
    );
  }

  Widget buildFromRecent() => GridView.builder(
        physics: (dragAnimController.isDismissed) ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
        padding: EdgeInsets.only(left: 12, right: 12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: $(2),
          crossAxisSpacing: $(2),
        ),
        itemBuilder: (context, index) {
          if (index < 2) {
            return buildSystemAlbumItem(index, context)!;
          }
          return buildRecentListItem(index - 2, context);
        },
        itemCount: controller.imageUploadCache.length + 2,
      );

  Widget buildRecentListItem(int index, BuildContext context) {
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
        .intoGestureDetector(
      onTap: () {
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
              onBackClick(true);
            }
          });
        }
      },
    );
  }

  Widget? buildSystemAlbumItem(int pos, BuildContext context) {
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
            onBackClick(true);
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
            onBackClick(true);
          }
        });
      });
    }
    return null;
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
    if (details.velocity.pixelsPerSecond.dy.abs() > 200) {
      double visualVelocity = details.velocity.pixelsPerSecond.dy / ScreenUtil.screenSize.height;
      dragAnimController.fling(velocity: -visualVelocity);
    } else {
      if (lastDragDirection) {
        dragAnimController.reverse();
      } else {
        dragAnimController.forward();
      }
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
