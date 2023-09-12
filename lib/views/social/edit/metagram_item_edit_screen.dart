import 'dart:io';

import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:common_utils/common_utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:skeletons/skeletons.dart';

import 'metagram_item_edit_controller.dart';

class MetagramItemEditScreen extends StatefulWidget {
  MetagramItemEntity entity;
  List<List<DiscoveryResource>> items;
  int index;
  bool isSelf;

  MetagramItemEditScreen({
    Key? key,
    required this.entity,
    required this.items,
    required this.index,
    required this.isSelf,
  }) : super(key: key);

  @override
  State<MetagramItemEditScreen> createState() => _MetagramItemEditScreenState();
}

class _MetagramItemEditScreenState extends AppState<MetagramItemEditScreen> {
  late MetagramItemEditController controller;
  int generateCount = 0;
  UserManager userManager = AppDelegate().getManager();

  @override
  void initState() {
    super.initState();
    Posthog().screen(screenName: 'metagram_item_edit_screen');
    controller = Get.put(MetagramItemEditController(entity: widget.entity, items: widget.items, index: widget.index));
    controller.onReadyCallback = () {
      if (controller.originFile != null) {
        delay(() {
          generateAgain(controller);
        });
      }
    };
  }

  @override
  void dispose() {
    Get.delete<MetagramItemEditController>();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
        child: GetBuilder<MetagramItemEditController>(
          builder: (controller) {
            return Scaffold(
              backgroundColor: ColorConstant.BackgroundColor,
              appBar: AppNavigationBar(
                backgroundColor: ColorConstant.BackgroundColor,
                backAction: () {
                  _willPopCallback(context);
                },
                middle: Image.asset(
                  Images.ic_metagram_download,
                  width: $(24),
                )
                    .intoContainer(
                  padding: EdgeInsets.all($(10)),
                  color: Colors.transparent,
                )
                    .intoGestureDetector(onTap: () {
                  saveImage(controller);
                }).offstage(offstage: controller.resultFile == null),
                trailing: Image.asset(
                  Images.ic_metagram_save,
                  width: $(24),
                  height: $(24),
                )
                    .intoContainer(
                  padding: EdgeInsets.all($(10)),
                  color: Colors.transparent,
                )
                    .intoGestureDetector(onTap: () {
                  submit(controller);
                }).offstage(offstage: controller.transResult == null),
              ),
              body: Column(
                children: [
                  Expanded(
                      child: Stack(
                    children: [
                      controller.resultFile == null
                          ? SkeletonAvatar(
                              style: SkeletonAvatarStyle(
                                width: ScreenUtil.screenSize.width,
                                height: ScreenUtil.screenSize.width,
                              ),
                            )
                          : controller.transResult == null
                              ? Image.file(
                                  controller.resultFile!,
                                  width: ScreenUtil.screenSize.width,
                                )
                              : Image.file(
                                  controller.transResult!,
                                  fit: BoxFit.contain,
                                  width: ScreenUtil.screenSize.width,
                                ),
                      controller.originFile == null || !controller.showOrigin
                          ? SizedBox.shrink()
                          : Image.file(
                              controller.originFile!,
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
                  OutlineWidget(
                    radius: $(8),
                    strokeWidth: $(2),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFEC5DD8),
                        Color(0xFF7F97F3),
                        Color(0xFF04F1F9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Text(
                      S.of(context).generate_again,
                      style: TextStyle(
                        color: ColorConstant.White,
                        fontSize: $(16),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                      ),
                    ).intoContainer(
                      padding: EdgeInsets.symmetric(vertical: $(10)),
                      alignment: Alignment.center,
                    ),
                  ).intoMaterial(color: Color(0xff222222), borderRadius: BorderRadius.circular($(8))).intoGestureDetector(onTap: () {
                    generateAgain(controller);
                  }).intoContainer(
                      margin: EdgeInsets.only(
                    left: $(12),
                    right: $(12),
                    bottom: ScreenUtil.getBottomPadding(context) + $(30),
                  )),
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: $(12)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: buildItems(controller),
                    ),
                    scrollDirection: Axis.horizontal,
                  ).intoContainer(margin: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context) + $(15))).offstage(offstage: true),
                ],
              ),
            );
          },
          init: Get.find<MetagramItemEditController>(),
        ),
        onWillPop: () async {
          _willPopCallback(context);
          return false;
        });
  }

  generateAgain(MetagramItemEditController controller) {
    SimulateProgressBarController simulateProgressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(
      context,
      needUploadProgress: false,
      controller: simulateProgressBarController,
      config: SimulateProgressBarConfig.anotherMe(context),
    ).then((value) {
      if (value == null) {
        controller.onError();
      } else if (value.result) {
        Events.metagramCompleteSuccess(photo: 'url');
        generateCount++;
        if (generateCount - 1 > 0) {
          Events.metagramCompleteGenerateAgain(time: generateCount - 1);
        }
        controller.onSuccess();
      } else {
        controller.onError();
        if (value.error != null) {
          showLimitDialog(context, type: value.error!, function: 'metagram', source: 'metagram_result_page');
        } else {
          Navigator.of(context).pop();
        }
      }
    });
    controller.startTransfer().then((value) {
      if (value != null) {
        if (value.entity != null) {
          var image = File(controller.transKey!);
          controller.transResult = image;
          controller.update();
          simulateProgressBarController.loadComplete();
        } else {
          simulateProgressBarController.onError(error: value.type);
        }
      } else {
        simulateProgressBarController.onError();
      }
    });
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
        EffectCategory data = element.data! as EffectCategory;
        var effects = data.effects;
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

  void saveImage(MetagramItemEditController controller) async {
    await showLoading();
    var path = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
    var saveFileName = EncryptUtil.encodeMd5('${controller.originFile?.path}${(controller.transResult ?? controller.resultFile)?.path}');
    var imgPath = path + '${saveFileName}.png';
    if (!File(imgPath).existsSync()) {
      var uint8list =
          await ImageUtils.printAnotherMeData(controller.originFile!, controller.transResult ?? controller.resultFile!, '@${userManager.user?.getShownName() ?? 'Pandora User'}');
      var list = uint8list.toList();
      await File(imgPath).writeAsBytes(list);
    }
    await GallerySaver.saveImage(imgPath, albumName: saveAlbumName);
    await hideLoading();
    Events.metagramCompleteDownload(type: 'image');
    CommonExtension().showImageSavedOkToast(context);
  }

  void submit(MetagramItemEditController controller) {
    showLoading().whenComplete(() {
      controller.updateResult().then((value) {
        hideLoading().whenComplete(() {
          if (value != null) {
            Navigator.of(context).pop();
          }
        });
      });
    });
  }

  _willPopCallback(BuildContext context) async {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: $(20)),
          TitleTextWidget(S.of(context).exit_msg, Colors.white, FontWeight.w600, $(17)),
          SizedBox(height: $(15)),
          TitleTextWidget(S.of(context).exit_msg1, Colors.white, FontWeight.w400, $(13), maxLines: 2).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(25))),
          SizedBox(height: $(15)),
          Divider(height: 1, color: ColorConstant.LightLineColor),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TitleTextWidget(
                  S.of(context).txtContinue,
                  ColorConstant.aiDrawBlue,
                  FontWeight.w400,
                  $(17),
                ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
                  Navigator.pop(context, true);
                }),
              ),
              Container(
                height: $(46),
                width: 0.5,
                color: ColorConstant.LightLineColor,
              ),
              Expanded(
                child: TitleTextWidget(
                  S.of(context).cancel,
                  ColorConstant.aiDrawBlue,
                  FontWeight.w500,
                  $(17),
                ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
                  Navigator.pop(context);
                }),
              ),
            ],
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
        ],
      ).customDialogStyle(),
    ).then((value) {
      if (value ?? false) {
        Navigator.pop(context);
      }
    });
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
