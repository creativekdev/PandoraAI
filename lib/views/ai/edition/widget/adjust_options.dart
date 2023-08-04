import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/enums/adjust_function.dart';
import 'package:cartoonizer/views/ai/edition/controller/adjust_controller.dart';
import 'package:cartoonizer/views/ai/edition/controller/image_edition_controller.dart';
import 'package:cartoonizer/views/mine/filter/GridSlider.dart';

class AdjustOptions extends StatelessWidget {
  ImageEditionController imageEditionController;

  AdjustOptions({
    super.key,
    required this.imageEditionController,
  });

  @override
  Widget build(BuildContext context) {
    var paddingH = (ScreenUtil.getCurrentWidgetSize(context).width - $(78)) / 2;
    return GetBuilder<AdjustController>(
      builder: (controller) {
        controller.itemWidth = $(78);
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
                  imageEditionController.update();
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
                        size: $(48),
                        backgroundColor: Colors.grey.shade600,
                        progress: data.getProgress(),
                        ringWidth: 1.5,
                        loadingColors: checked
                            ? [
                                Color(0xFF05E0D5),
                                Color(0xFF05E0D5),
                              ]
                            : [
                                Colors.grey.shade300,
                                Colors.grey.shade300,
                              ],
                      ),
                      checked
                          ? Text(
                              data.value.toStringAsFixed(0),
                              style: TextStyle(
                                color: Color(0xFF05E0D5),
                                fontSize: $(14),
                              ),
                            ).intoContainer(
                              width: $(48),
                              height: $(48),
                              alignment: Alignment.center,
                            )
                          : Image.asset(
                              data.function.icon(),
                              width: $(24),
                              height: $(24),
                              color: Colors.grey.shade300,
                            ).intoContainer(
                              padding: EdgeInsets.all($(12)),
                            ),
                    ],
                  ).intoGestureDetector(onTap: () {
                    controller.index = index;
                  }).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)));
                },
                itemCount: controller.dataList.length,
              ).intoContainer(height: $(52)),
            ),
          ],
        );
      },
      init: imageEditionController.adjustController,
    );
  }
}
