import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/views/ai/edition/controller/crop_holder.dart';
import 'package:cartoonizer/views/mine/filter/Crop.dart';
import 'package:cartoonizer/views/mine/filter/im_crop_screen.dart';

class CropOptions extends StatelessWidget {
  CropHolder controller;
  Color checkedColor = Color(0xFF05E0D5);

  CropOptions({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildIcon(context, onCrop: () {
          crop(context);
        }).intoContainer(height: $(50), alignment: Alignment.center),
        buildTitle(context),
      ],
    );
  }

  crop(BuildContext context) {
    Navigator.of(context).push(FadeRouter(
        child: ImCropScreen(
          filePath: controller.originFilePath!,
          cropItem: controller.currentItem,
          onGetCropPath: (String path) {
            controller.resultFilePath = path;
          },
        ),
        settings: RouteSettings(name: '/ImCropScreen')));
  }

  Widget buildIcon(BuildContext context, {required Function onCrop}) {
    CropItem cropItem = controller.currentItem;
    if (cropItem.configs.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        color: Colors.transparent,
      );
    } else if (cropItem.configs.length == 1) {
      return rectangle(
        width: $(20),
        height: $(20),
        checked: true,
      ).intoGestureDetector(onTap: () {
        onCrop.call();
      });
    } else {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cropItem.configs
              .map(
                (e) => rectangle(
                  width: $(50) * e.width / (e.width + e.height),
                  height: $(50) * e.height / (e.width + e.height),
                  checked: e.checked,
                )
                    .intoContainer(
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: $(10)),
                )
                    .intoGestureDetector(onTap: () {
                  if (e.checked) {
                    onCrop.call();
                  } else {
                    cropItem.configs.forEach((element) {
                      element.checked = false;
                    });
                    e.checked = true;
                    controller.update();
                    onCrop.call();
                  }
                }),
              )
              .toList());
    }
  }

  Widget rectangle({required double width, required double height, required bool checked}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular($(4)),
        border: Border.all(
          color: checked ? checkedColor : Colors.white,
          width: 1.5,
        ),
        color: Colors.transparent,
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    List<CropItem> items = controller.items;
    CropItem currentItem = controller.currentItem;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items
          .map(
            (e) => Text(
              e.title,
              style: TextStyle(color: e == currentItem ? checkedColor : Colors.white),
            ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(6), horizontal: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
              controller.currentItem = e;
              if (controller.currentItem.configs.isEmpty) {
                controller.resultFilePath = controller.originFilePath;
              } else if (controller.currentItem.configs.length == 1) {
                crop(context);
              }
            }),
          )
          .toList(),
    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(30)));
  }
}
