import 'dart:math';

import 'package:cartoonizer/views/ai/drawable/widget/drawable.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

class DrawableOpt extends StatefulWidget {
  DrawableController controller;

  DrawableOpt({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<DrawableOpt> createState() => _DrawableOptState();
}

class _DrawableOptState extends State<DrawableOpt> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late DrawableController controller;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    controller = widget.controller;
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.onUpdated?.call();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _animController.status == AnimationStatus.dismissed ? null : 0,
      left: $(15),
      right: $(15),
      bottom: 0,
      child: Column(
        children: [
          _animController.status == AnimationStatus.dismissed
              ? Container()
              : Expanded(
                  child: Container(
                    color: Colors.transparent,
                  ).intoGestureDetector(onTap: () {
                    _animController.reverse();
                  }),
                ),
          AnimatedBuilder(
              animation: _animController,
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
                        ).intoContainer(
                            padding: EdgeInsets.symmetric(horizontal: $(15)),
                            decoration: BoxDecoration(
                              color: ColorConstant.aiDrawGrey,
                              borderRadius: BorderRadius.circular($(8)),
                            )),
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
                            Image.asset(
                              Images.ic_drawable_arrow,
                              height: $(10),
                              color: ColorConstant.aiDrawGrey,
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
                  height: $(58) * _animController.value,
                ).intoGestureDetector(onTap: () {}).visibility(visible: !_animController.isDismissed);
              }),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Image.asset(
                Images.ic_pencil,
                width: $(28),
                color: controller.drawMode == DrawMode.paint ? Colors.white : Colors.black,
              )
                  .intoContainer(
                      padding: EdgeInsets.all($(4)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular($(8)),
                        color: controller.drawMode == DrawMode.paint ? ColorConstant.DiscoveryBtn : Colors.transparent,
                      ))
                  .intoGestureDetector(onTap: () {
                if (controller.drawMode != DrawMode.paint) {
                  controller.drawMode = DrawMode.paint;
                }
                if (_animController.status == AnimationStatus.dismissed) {
                  _animController.forward();
                }
              }),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Image.asset(
                Images.ic_mark_pen,
                width: $(28),
                color: controller.drawMode == DrawMode.markPaint ? Colors.white : Colors.black,
              )
                  .intoContainer(
                      padding: EdgeInsets.all($(4)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular($(8)),
                        color: controller.drawMode == DrawMode.markPaint ? ColorConstant.DiscoveryBtn : Colors.transparent,
                      ))
                  .intoGestureDetector(onTap: () {
                if (controller.drawMode != DrawMode.markPaint) {
                  controller.drawMode = DrawMode.markPaint;
                }

                if (_animController.status == AnimationStatus.dismissed) {
                  _animController.forward();
                }
              }),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Image.asset(
                Images.ic_eraser,
                width: $(28),
                color: controller.drawMode == DrawMode.eraser ? Colors.white : Colors.black,
              )
                  .intoContainer(
                      padding: EdgeInsets.all($(4)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular($(8)),
                        color: controller.drawMode == DrawMode.eraser ? ColorConstant.DiscoveryBtn : Colors.transparent,
                      ))
                  .intoGestureDetector(onTap: () {
                if (controller.drawMode != DrawMode.eraser) {
                  controller.drawMode = DrawMode.eraser;
                }

                if (_animController.status == AnimationStatus.dismissed) {
                  _animController.forward();
                }
              }),
              Expanded(
                flex: 1,
                child: Container(),
              ),
            ],
          ).intoContainer(
              padding: EdgeInsets.symmetric(vertical: $(8)),
              decoration: BoxDecoration(
                color: ColorConstant.aiDrawGrey,
                borderRadius: BorderRadius.circular($(8)),
              )),
        ],
      ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context))),
    );
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

class PaintWidthSelectorState extends State<PaintWidthSelector> {
  late DrawableController controller;

  List<Map<String, dynamic>> list = [];

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    list = controller.getPainSize();
  }

  @override
  void didUpdateWidget(covariant PaintWidthSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    list = controller.getPainSize();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: list.map(
        (e) {
          var checked = controller.currentStrokeWidth() == e['size'];
          return Image.asset(
            e['image'],
            width: $(24),
            height: $(24),
            color: checked ? Colors.white : Colors.black,
          )
              .intoCenter()
              .intoContainer(
                  width: $(36),
                  height: $(36),
                  margin: EdgeInsets.symmetric(vertical: $(5)),
                  decoration: checked
                      ? BoxDecoration(
                          color: ColorConstant.DiscoveryBtn,
                          borderRadius: BorderRadius.circular($(8)),
                        )
                      : null)
              .intoContainer(color: Colors.transparent)
              .intoGestureDetector(onTap: () {
            widget.onSelect.call(e['size']);
            delay(() {
              setState(() {});
            }, milliseconds: 32);
          });
        },
      ).toList(),
    );
  }
}
