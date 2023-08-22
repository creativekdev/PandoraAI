import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/edition/controller/crop_holder.dart';
import 'package:cartoonizer/views/mine/filter/im_crop_screen.dart';

class CropOptions extends StatelessWidget {
  CropHolder controller;

  CropOptions({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: <Color>[
                Color(0xffffffff),
                Color(0xffffffff),
                Color(0xffffffff),
                Color(0x99ffffff),
                Color(0x11ffffff),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: Row(
            children: [
              SizedBox(width: $(15)),
              buildItem(controller.items.first, context, controller.items.first == controller.currentItem)
                  .intoContainer(height: $(44), width: $(44), color: Colors.transparent)
                  .intoGestureDetector(onTap: () {
                crop(context, controller.items.first);
              }).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(8))),
              Expanded(
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.only(right: $(15)),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, pos) {
                    var index = pos + 1;
                    var item = controller.items[index];
                    bool check = item == controller.currentItem;
                    return buildItem(item, context, check).intoContainer(height: $(44), width: $(44), color: Colors.transparent).intoGestureDetector(onTap: () {
                      crop(context, item);
                    }).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(8)));
                  },
                  itemCount: controller.items.length - 1,
                ),
              ),
            ],
          ).intoContainer(height: $(44)),
        ),
      ],
    );
  }

  crop(BuildContext context, CropConfig e) {
    Navigator.of(context).push(FadeRouter(
        child: ImCropScreen(
          items: controller.items,
          filePath: controller.originFilePath!,
          originalRatio: controller.originalRatio,
          initScrollPixels: controller.scrollController.positions.isEmpty ? 0 : controller.scrollController.position.pixels,
          cropItem: e,
          onScrollChanged: (scrollPixel) {
            controller.scrollController.jumpTo(scrollPixel);
          },
          onGetCrop: (image, config) async {
            controller.shownImage = image;
            controller.currentItem = config;
          },
        ),
        settings: RouteSettings(name: '/ImCropScreen')));
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
        AppCircleProgressBar(
          size: $(44),
          backgroundColor: Color(0xffa2a2a2).withOpacity(0.3),
          progress: check ? 1 : 0,
          ringWidth: 1.4,
          loadingColors: [
            Color(0xFFE31ECD),
            Color(0xFF243CFF),
            Color(0xFFE31ECD),
          ],
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
                  color: Color(0xffa2a2a2).withOpacity(0.3),
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
      return Image.asset(
        Images.ic_crop_original,
        width: $(16),
        color: Colors.white,
      );
    } else {
      return Text(
        e.title,
        style: TextStyle(
          color: Colors.white,
          fontSize: $(12),
        ),
      );
    }
  }
}
