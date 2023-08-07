import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/transfer/controller/all_transfer_controller.dart';
import 'package:common_utils/common_utils.dart';

class EffectOptions extends StatelessWidget {
  AllTransferController controller;

  EffectOptions({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    var itemWidth = ScreenUtil.getCurrentWidgetSize(context).width / 6;
    return GetBuilder<AllTransferController>(
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ScrollablePositionedList.builder(
              physics: controller.titleNeedScroll ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
              itemCount: controller.categories.length,
              itemScrollController: controller.titleScrollController,
              itemBuilder: (context, index) {
                var data = controller.categories[index];
                var checked = controller.selectedTitle == data;
                return title(data.title, checked).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(12)), color: Colors.transparent).intoGestureDetector(onTap: () {
                  controller.onTitleSelected(index);
                });
              },
              scrollDirection: Axis.horizontal,
            ).intoContainer(height: $(22)).listenSizeChanged(onSizeChanged: (size) {
              if (size.width >= ScreenUtil.screenSize.width) {
                controller.titleNeedScroll = true;
              } else {
                controller.titleNeedScroll = false;
              }
              controller.update();
            }),
            controller.selectedTitle == null
                ? Container()
                : ScrollablePositionedList.builder(
                    padding: EdgeInsets.symmetric(horizontal: $(10)),
                    itemCount: controller.selectedTitle!.effects.length,
                    itemScrollController: controller.scrollController,
                    itemBuilder: (context, index) {
                      var data = controller.selectedTitle!.effects[index];
                      var checked = data == controller.selectedEffect;
                      return SizedBox(
                        width: itemWidth,
                        height: itemWidth,
                        child: Padding(
                          padding: EdgeInsets.all($(2)),
                          child: item(context, data, checked).intoGestureDetector(onTap: () {
                            controller.onItemSelected(index);
                            if (controller.selectedEffect != null && controller.resultMap[controller.selectedEffect!.key] == null) {
                              controller.parent?.generate(context, controller);
                            }
                          }),
                        ),
                      );
                    },
                    scrollDirection: Axis.horizontal,
                  ).intoContainer(height: itemWidth),
          ],
        );
      },
      init: controller,
    );
  }

  Widget title(String title, bool checked) {
    var text = Text(
      title,
      style: TextStyle(
        color: checked ? ColorConstant.White : ColorConstant.EffectGrey,
        fontSize: $(13),
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
    );
    text;
    if (checked) {
      return ShaderMask(
          shaderCallback: (Rect bounds) => LinearGradient(
                colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(Offset.zero & bounds.size),
          blendMode: BlendMode.srcATop,
          child: text);
    } else {
      return text;
    }
  }

  Widget item(BuildContext context, EffectItem data, bool checked) {
    var image = CachedNetworkImageUtils.custom(
      context: context,
      imageUrl: data.imageUrl,
      fit: BoxFit.cover,
      useOld: false,
    );
    if (checked) {
      return Stack(
        fit: StackFit.expand,
        children: [
          image,
          Container(
            color: Color(0x55000000),
            child: Image.asset(
              Images.ic_metagram_yes,
              width: $(22),
            ).intoCenter(),
          ),
        ],
      );
    }
    return image;
  }
}
