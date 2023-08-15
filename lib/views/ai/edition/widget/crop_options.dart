import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/views/ai/edition/controller/crop_holder.dart';
import 'package:cartoonizer/views/mine/filter/im_crop_screen.dart';

class CropOptions extends StatelessWidget {
  CropHolder controller;

  CropOptions({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: $(5)),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var item = controller.items[index];
            bool check = item == controller.currentItem;
            return buildItem(item, context, check).intoContainer(height: $(40), width: $(40), color: Colors.transparent).intoGestureDetector(onTap: () {
              if (controller.currentItem != item) {
                crop(context, item);
              }
            }).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(5)));
          },
          itemCount: controller.items.length,
        ).intoContainer(height: $(40)),
      ],
    );
  }

  crop(BuildContext context, CropConfig e) {
    if (e.width == -1) {
      controller.canReset = false;
      controller.currentItem = e;
      controller.resultFilePath = null;
    } else {
      Navigator.of(context).push(FadeRouter(
          child: ImCropScreen(
            items: controller.items,
            filePath: controller.originFilePath!,
            cropItem: e,
            onGetCropPath: (String path) {
              controller.currentItem = e;
              controller.canReset = true;
              controller.resultFilePath = path;
            },
          ),
          settings: RouteSettings(name: '/ImCropScreen')));
    }
  }

  Widget rectangle({required double width, required double height, required bool checked}) {
    return OutlineWidget(
        strokeWidth: 1.5,
        radius: $(4),
        gradient: LinearGradient(
          colors: checked
              ? [
                  Colors.white,
                  Colors.white,
                ]
              : [
                  Colors.grey.shade800,
                  Colors.grey.shade800,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Container(
          width: width,
          height: height,
        ));
  }

  Widget buildItem(CropConfig e, BuildContext context, bool check) {
    double width = $(18);
    double height = $(18);
    if (e.width != -1) {
      width = $(40) * (e.width / (e.width + e.height));
      height = $(40) * (e.height / (e.width + e.height));
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular($(32)),
            border: Border.all(
              color: check ? Colors.white : Colors.grey.shade800,
              width: 1,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($(4)),
                border: Border.all(
                  style: BorderStyle.solid,
                  color: Colors.grey.shade800,
                  width: 1,
                )),
          ),
        ),
        Align(
          child: buildIcon(e, context, check),
          alignment: Alignment.center,
        ),
      ],
    );
  }

  Widget buildIcon(CropConfig e, BuildContext context, bool check) {
    if (e.width == -1) {
      return Icon(
        Icons.fullscreen,
        size: $(18),
        color: Colors.white,
      );
    } else {
      return Text(
        e.title,
        style: TextStyle(color: check ? Colors.white : Colors.grey.shade700),
      );
    }
  }
}
