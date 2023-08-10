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
        GridSlider(
            minVal: controller.dataList[controller.index].start.toInt(),
            maxVal: controller.dataList[controller.index].end.toInt(),
            currentPos: controller.dataList[controller.index].value,
            onChanged: (newValue) {
              controller.dataList[controller.index].value = newValue;
              controller.update();
            },
            onEnd: () async {
              controller.buildResult();
            }),
        SizedBox(height: $(20)),
        Listener(
          onPointerUp: (details) {
            delay(() => controller.autoCompleteScroll(), milliseconds: 32);
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
                    size: $(44),
                    backgroundColor: Colors.grey.shade800,
                    progress: data.getProgress(),
                    ringWidth: 1.5,
                    loadingColors: [
                      Color(0xFF05E0D5),
                      Color(0xFF05E0D5),
                    ],
                  ),
                  checked && data.value != data.initValue
                      ? Text(
                          data.value.toStringAsFixed(0),
                          style: TextStyle(
                            color: Color(0xFF05E0D5),
                            fontSize: $(14),
                          ),
                        ).intoContainer(
                          width: $(44),
                          height: $(44),
                          alignment: Alignment.center,
                        )
                      : Image.asset(
                          data.function.icon(),
                          width: $(20),
                          height: $(20),
                          color: Colors.grey.shade300,
                        ).intoContainer(
                          padding: EdgeInsets.all($(12)),
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
                  controller.buildResult();
                } else {
                  controller.index = index;
                }
              }).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(5)));
            },
            itemCount: controller.dataList.length,
          ).intoContainer(height: $(44)),
        ),
      ],
    );
  }
}
