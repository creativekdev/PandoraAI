import 'dart:ui' as ui;

import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/enums/adjust_function.dart';
import 'package:cartoonizer/views/ai/edition/controller/adjust_holder.dart';
import 'package:cartoonizer/views/mine/filter/GridSlider.dart';

class AdjustOptions extends StatelessWidget {
  late AdjustHolder controller;

  AdjustOptions({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    var paddingH = (ScreenUtil.getCurrentWidgetSize(context).width - $(54)) / 2;
    controller.itemWidth = $(54);
    controller.padding = paddingH;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Listener(
          onPointerUp: (details) {
            delay(() => controller.autoCompleteScroll(), milliseconds: 32);
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
              controller: controller.scrollController,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: paddingH),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                var data = controller.dataList[index];
                bool checked = index == controller.index;
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
                  if (controller.index == index) {
                    if (data.value == data.initValue) {
                      data.value = data.previousValue;
                    } else {
                      data.previousValue = data.value;
                      data.value = data.initValue;
                    }
                    controller.buildResult(true);
                  } else {
                    controller.index = index;
                  }
                }).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(10)));
              },
              itemCount: controller.dataList.length,
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
              minVal: controller.dataList[controller.index].start.toInt(),
              maxVal: controller.dataList[controller.index].end.toInt(),
              currentPos: controller.dataList[controller.index].value,
              onChanged: (newValue) {
                controller.dataList[controller.index].value = newValue;
                controller.update();
                if (DateTime.now().millisecondsSinceEpoch - lastBuildTime > 150) {
                  lastBuildTime = DateTime.now().millisecondsSinceEpoch;
                  controller.buildResult(false);
                }
              },
              onEnd: () async {
                delay(() => controller.buildResult(true), milliseconds: 150);
              }),
        ),
        SizedBox(height: 10),
        TitleTextWidget(controller.dataList[controller.index].function.title(), Color(0xfff9f9f9), FontWeight.normal, $(12)),
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
