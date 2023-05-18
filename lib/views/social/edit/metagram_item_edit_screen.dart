import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/app/cache/app_feature_operator.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:skeletons/skeletons.dart';

import 'metagram_item_edit_controller.dart';

class MetagramItemEditScreen extends StatefulWidget {
  MetagramItemEntity entity;

  MetagramItemEditScreen({
    Key? key,
    required this.entity,
  }) : super(key: key);

  @override
  State<MetagramItemEditScreen> createState() => _MetagramItemEditScreenState();
}

class _MetagramItemEditScreenState extends State<MetagramItemEditScreen> {
  late MetagramItemEditController controller;
  EffectDataController dataController = Get.find();

  @override
  void initState() {
    super.initState();
    var targetSeries = dataController.data!.effectList('full_body').pick((t) => t.key == 'sleek');
    controller = Get.put(MetagramItemEditController(entity: widget.entity.copy(), fullBody: targetSeries));
  }

  @override
  void dispose() {
    Get.delete<MetagramItemEditController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MetagramItemEditController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstant.BackgroundColor,
          appBar: AppNavigationBar(
            backgroundColor: ColorConstant.BackgroundColor,
            middle: Image.asset(
              Images.ic_metagram_download,
              width: $(24),
            ).offstage(offstage: controller.resultData == null),
            trailing: Image.asset(
              Images.ic_metagram_save,
              width: $(24),
              height: $(24),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                  child: Stack(
                children: [
                  controller.resultData == null
                      ? SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                            width: ScreenUtil.screenSize.width,
                            height: ScreenUtil.screenSize.width,
                          ),
                        )
                      : Image.memory(
                          controller.resultData!,
                          width: double.maxFinite,
                        ),
                  controller.imageData == null || !controller.showOrigin
                      ? SizedBox.shrink()
                      : Image.memory(
                          controller.imageData!,
                          width: double.maxFinite,
                        ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: GestureDetector(
                      child: Image.asset(Images.ic_metagram_show_origin, width: $(26)).intoContainer(
                        color: Colors.transparent,
                        padding: EdgeInsets.all($(12)),
                      ),
                      onTapDown: (details) {
                        controller.showOrigin = true;
                      },
                      onTapUp: (details) {
                        controller.showOrigin = false;
                      },
                      onTapCancel: () {
                        controller.showOrigin = false;
                      },
                    ),
                  )
                ],
              ).intoCenter().intoContainer()),
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: $(12)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: buildItems(controller),
                ),
                scrollDirection: Axis.horizontal,
              ).intoContainer(margin: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context) + $(15))),
            ],
          ),
        );
      },
      init: Get.find<MetagramItemEditController>(),
    );
  }

  List<Widget> buildItems(MetagramItemEditController controller) {
    var width = ScreenUtil.screenSize.width / 5;
    var height = width / 7 * 8;
    List<Widget> items = [];
    controller.optList.forEach((element) {
      if (element.type == HomeCardType.anotherme) {
        bool checked = element.type == controller.currentType;
        items.add(
          Column(
            children: [
              _CheckItemWidget(
                checked: checked,
                child: Image.asset(
                  Images.ic_metagram_opt_another,
                  width: width,
                  height: height,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: $(8)),
              TitleTextWidget(element.type.title(), ColorConstant.White, FontWeight.normal, $(12))
            ],
          ),
        );
      } else if (element.type == HomeCardType.cartoonize) {
        EffectModel data = element.data! as EffectModel;
        var effects = data.effects.values.toList();
        for (int i = 0; i < effects.length; i++) {
          var effectItem = effects[i];
          bool checked;
          if (controller.currentType == HomeCardType.cartoonize) {
            checked = controller.entity.cartoonizeKey == effectItem.key;
          } else {
            checked = false;
          }
          if (i == 0) {
            items.add(
              Column(
                children: [
                  _CheckItemWidget(
                    checked: checked,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular($(8)),
                      child: _imageWidget(
                        context,
                        imageUrl: effectItem.imageUrl,
                        width: width,
                        height: height,
                      ),
                    ),
                  ),
                  SizedBox(height: $(8)),
                  TitleTextWidget(element.type.title(), ColorConstant.White, FontWeight.normal, $(12))
                ],
              ).intoContainer(margin: EdgeInsets.only(left: $(6))),
            );
          } else {
            items.add(
              ClipRRect(
                borderRadius: BorderRadius.circular($(6)),
                child: _CheckItemWidget(
                  checked: checked,
                  child: Stack(
                    children: [
                      _imageWidget(
                        context,
                        imageUrl: effectItem.imageUrl,
                        width: width * 0.8,
                        height: height * 0.8,
                      ),
                      Positioned(
                        child: TitleTextWidget('${i + 1}', ColorConstant.White, FontWeight.normal, $(12), align: TextAlign.center)
                            .intoContainer(alignment: Alignment.center, width: width * 0.8, color: Color(0x99000000)),
                        bottom: 0,
                      ),
                    ],
                  ).intoContainer(width: width * 0.8, height: height * 0.8),
                ),
              ).intoContainer(margin: EdgeInsets.only(left: $(6))),
            );
          }
        }
      }
    });
    return items;
  }

  Widget _imageWidget(BuildContext context, {required String imageUrl, required double width, required double height}) {
    return CachedNetworkImageUtils.custom(
      context: context,
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: width,
      height: height,
      placeholder: (context, url) {
        return Container(
          height: height,
          width: width,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          height: height,
          width: width,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class _CheckItemWidget extends StatelessWidget {
  bool checked;
  final Widget child;

  _CheckItemWidget({Key? key, required this.child, this.checked = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        checked
            ? Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                left: 0,
                child: Image.asset(
                  Images.ic_metagram_yes,
                  width: $(26),
                ).intoCenter().intoContainer(color: Color(0x55000000)),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
