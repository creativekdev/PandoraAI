import 'dart:math';
import 'dart:ui' as ui;

import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/enums/adjust_function.dart';
import 'package:cartoonizer/views/ai/edition/controller/filters/filters_holder.dart';
import 'package:cartoonizer/views/mine/filter/GridSlider.dart';

class AdjustOptions extends StatelessWidget {
  late FiltersHolder controller;

  AdjustOptions({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    var tWidth = (ScreenUtil.getCurrentWidgetSize(context).width);
    var itemW = (tWidth / 7);
    var paddingH = (tWidth - itemW) / 2;
    controller.adjustOperator.itemWidth = itemW;
    var currentDataIndex = min(controller.adjustOperator.adjIndex, controller.adjustOperator.adjustList.length - 1);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Listener(
          onPointerUp: (details) {
            delay(() => controller.adjustOperator.autoCompleteScroll(), milliseconds: 32);
          },
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: <Color>[
                  Color(0x11ffffff),
                  Color(0x99ffffff),
                  Color(0xffffffff),
                  Color(0x99ffffff),
                  Color(0x11ffffff),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                tileMode: TileMode.mirror,
              ).createShader(bounds);
            },
            child: ListView.builder(
              controller: controller.adjustOperator.scrollController,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: paddingH),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                var data = controller.adjustOperator.adjustList[index];
                bool checked = index == controller.adjustOperator.adjIndex;
                return Stack(
                  children: [
                    AppCircleProgressBar(
                      size: $(34),
                      backgroundColor: Colors.grey.shade900,
                      progress: data.value.toStringAsFixed(0) == data.initValue.toStringAsFixed(0) ? 0 : data.getProgress(),
                      ringWidth: 1.5,
                      loadingColors: [
                        Color(0xFFE31ECD),
                        Color(0xFF243CFF),
                        Color(0xFFE31ECD),
                      ],
                    ),
                    checked && data.value.toStringAsFixed(0) != data.initValue.toStringAsFixed(0)
                        ? Text(
                            (data.value * data.multiple).toStringAsFixed(0),
                            style: TextStyle(
                              color: Color(0xffffffff),
                              fontSize: $(12),
                            ),
                          ).intoContainer(
                            width: $(34),
                            height: $(34),
                            alignment: Alignment.center,
                          )
                        : Image.asset(
                            data.function.icon(),
                            width: $(20),
                            height: $(20),
                            color: Colors.grey.shade300,
                          ).intoContainer(
                            width: $(34),
                            height: $(34),
                            alignment: Alignment.center,
                          ),
                  ],
                ).intoGestureDetector(onTap: () {
                  if (controller.adjustOperator.adjIndex == index) {
                    if (data.value == data.initValue) {
                      data.value = data.previousValue;
                    } else {
                      data.previousValue = data.value;
                      data.value = data.initValue;
                    }
                    // controller.update();
                    controller.buildImage();
                  } else {
                    controller.adjustOperator.adjIndex = index;
                  }
                }).intoContainer(width: itemW, alignment: Alignment.center);
              },
              itemCount: controller.adjustOperator.adjustList.length,
            ).intoContainer(height: $(44)),
          ),
        ),
        SizedBox(height: $(15)),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: <Color>[
                Color(0x11ffffff),
                Color(0x99ffffff),
                Color(0xffffffff),
                Color(0x99ffffff),
                Color(0x11ffffff),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: GridSlider(
              minVal: controller.adjustOperator.adjustList[currentDataIndex].start.toInt(),
              maxVal: controller.adjustOperator.adjustList[currentDataIndex].end.toInt(),
              currentPos: controller.adjustOperator.adjustList[currentDataIndex].value,
              onChanged: (newValue) {
                controller.adjustOperator.adjustList[currentDataIndex].value = newValue;
                controller.update();
                if (DateTime.now().millisecondsSinceEpoch - lastBuildTime > 300) {
                  lastBuildTime = DateTime.now().millisecondsSinceEpoch;
                  // controller.update();
                  controller.buildImage();
                }
              },
              onEnd: () async {
                // delay(() => controller.update(), milliseconds: 150);
                delay(() => controller.buildImage(), milliseconds: 300);
              }),
        ),
        SizedBox(height: 10),
        TitleTextWidget(controller.adjustOperator.adjustList[currentDataIndex].function.title(), Color(0xfff9f9f9), FontWeight.normal, $(12)),
      ],
    );
  }

  int lastBuildTime = 0;
}

class LibImagePainter extends CustomPainter {
  ui.Image image;

  LibImagePainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    var dx = (image.width - size.width) / 2;
    var dy = (image.height - size.height) / 2;
    canvas.drawImage(image, Offset(-dx, -dy), Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
