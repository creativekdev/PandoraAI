import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/camera/pai_camera_screen.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/switch_image_card.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/li_pop_menu.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/print/print.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../controller/style_morph_controller.dart';

class StyleMorphScreen extends StatefulWidget {
  String source;

  RecentStyleMorphModel record;
  String? initKey;
  String photoType;

  StyleMorphScreen({
    Key? key,
    required this.source,
    required this.record,
    required this.photoType,
    this.initKey,
  }) : super(key: key);

  @override
  State<StyleMorphScreen> createState() => _StyleMorphScreenState();
}

class _StyleMorphScreenState extends AppState<StyleMorphScreen> {
  late String source;
  late StyleMorphController controller;
  UploadImageController uploadImageController = Get.find();
  late double itemWidth;
  UserManager userManager = AppDelegate.instance.getManager();
  late String photoType;
  int generateCount = 0;
  GlobalKey cropKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Posthog().screen(screenName: 'stylemorph_screen');
    photoType = widget.photoType;
    source = widget.source;
    controller = Get.put(StyleMorphController(
      originalPath: widget.record.originalPath!,
      itemList: widget.record.itemList,
      initKey: widget.initKey,
    ));
    itemWidth = ScreenUtil.screenSize.width / 6;
    delay(() {
      if (controller.selectedEffect != null && controller.resultMap[controller.selectedEffect?.key] == null) {
        generate();
      }
    });
  }

  changeOriginFile(File file) {
    controller.resultMap.clear();
    controller.originFile = file;
    generateCount = 0;
    controller.update();
    if (controller.selectedEffect != null) {
      generate();
    }
  }

  generate() async {
    var needUpload = TextUtil.isEmpty(uploadImageController.imageUrl(controller.originFile).value);
    SimulateProgressBarController simulateProgressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(
      context,
      needUploadProgress: needUpload,
      controller: simulateProgressBarController,
      config: SimulateProgressBarConfig.cartoonize(context),
    ).then((value) {
      if (value == null) {
        controller.onError();
      } else if (value.result) {
        controller.onGenerateSuccess(source: widget.source, photoType: widget.photoType, style: controller.selectedEffect?.key ?? '');
        generateCount++;
        if (generateCount - 1 > 0) {
          controller..onGenerateAgainSuccess(time: generateCount - 1, photoType: widget.photoType, source: widget.photoType, style: controller.selectedEffect?.key ?? '');
        }
        controller.onSuccess();
      } else {
        controller.onError();
        if (value.error != null) {
          showLimitDialog(context, type: value.error!, function: 'stylemorph', source: 'stylemorph_result_page');
        } else {
          // Navigator.of(context).pop();
        }
      }
    });

    uploadImageController.upload(file: controller.originFile).then((value) async {
      if (TextUtil.isEmpty(value)) {
        simulateProgressBarController.onError();
      } else {
        simulateProgressBarController.uploadComplete();
        var cachedId = await uploadImageController.getCachedId(controller.originFile);
        controller.startTransfer(value!, cachedId, onFailed: (response) {
          uploadImageController.deleteUploadData(controller.originFile);
        }).then((value) {
          if (value != null) {
            if (value.entity != null) {
              simulateProgressBarController.loadComplete();
            } else {
              simulateProgressBarController.onError(error: value.type);
            }
          } else {
            simulateProgressBarController.onError();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    Get.delete<StyleMorphController>();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return GetBuilder<StyleMorphController>(
      builder: (controller) {
        var child = Scaffold(
          backgroundColor: ColorConstant.BackgroundColor,
          appBar: AppNavigationBar(
            backgroundColor: ColorConstant.BackgroundColor,
            backAction: () async {
              if (await _willPopCallback(context)) {
                Navigator.of(context).pop();
              }
            },
            trailing: Image.asset(
              Images.ic_more,
              height: $(24),
              width: $(24),
              color: Colors.white,
            )
                .intoContainer(
              alignment: Alignment.centerRight,
              width: ScreenUtil.screenSize.width,
            )
                .intoGestureDetector(onTap: () {
              LiPopMenu.showLinePop(
                context,
                listData: [
                  ListPopItem(
                      text: S.of(context).share_to_discovery,
                      icon: Images.ic_share_discovery,
                      onTap: () {
                        shareToDiscovery(context, controller);
                      }),
                  ListPopItem(
                      text: S.of(context).share_out,
                      icon: Images.ic_share,
                      onTap: () {
                        shareOut(context, controller);
                      }),
                ],
              );
            }),
          ),
          body: Column(
            children: [
              Expanded(
                child: Obx(() => SwitchImageCard(
                      origin: controller.originFile,
                      result: controller.resultFile,
                      containsOrigin: controller.containsOriginal.value,
                      cropKey: cropKey,
                    )),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            controller.containsOriginal.value ? Images.ic_checked : Images.ic_unchecked,
                            width: 17,
                            height: 17,
                          ),
                          SizedBox(width: $(6)),
                          TitleTextWidget(S.of(context).in_original, ColorConstant.BtnTextColor, FontWeight.w500, 14),
                          SizedBox(width: $(20)),
                        ],
                      ).intoGestureDetector(onTap: () {
                        controller.containsOriginal.value = !controller.containsOriginal.value;
                      })),
                  Container(
                    height: $(16),
                    width: $(2),
                    color: ColorConstant.White,
                    margin: EdgeInsets.only(right: $(20)),
                  ),
                  Expanded(
                      child: Row(
                    children: [
                      Expanded(
                        child: Image.asset(Images.ic_camera, height: $(24), width: $(24))
                            .intoGestureDetector(
                              onTap: () => pickPhoto(context, controller),
                            )
                            .intoContainer(padding: EdgeInsets.all($(15))),
                      ),
                      Expanded(
                        child: Image.asset(Images.ic_share_print, height: $(24), width: $(24))
                            .intoGestureDetector(
                              onTap: () => toPrint(context, controller),
                            )
                            .intoContainer(padding: EdgeInsets.all($(15))),
                      ),
                      Expanded(
                        child: Image.asset(Images.ic_download, height: $(24), width: $(24))
                            .intoGestureDetector(
                              onTap: () => savePhoto(context, controller),
                            )
                            .intoContainer(padding: EdgeInsets.all($(15))),
                      ),
                    ],
                  ))
                ],
              ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(12))),
              OutlineWidget(
                radius: $(12),
                strokeWidth: $(2),
                gradient: LinearGradient(
                  colors: [Color(0xFF04F1F9), Color(0xFF7F97F3), Color(0xFFEC5DD8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Text(
                  S.of(context).generate_again,
                  style: TextStyle(
                    color: ColorConstant.White,
                    fontSize: $(17),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ).intoContainer(
                  height: $(48),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all($(2)),
                ),
              )
                  .intoGestureDetector(onTap: () {
                    generate();
                  })
                  .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(8)))
                  .visibility(visible: controller.selectedEffect != null && controller.resultMap[controller.selectedEffect!.key] != null),
              ScrollablePositionedList.builder(
                physics: controller.titleNeedScroll ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  var data = controller.categories[index];
                  var checked = controller.selectedTitle == data;
                  return title(data.title, checked).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(12), vertical: $(8)), color: Colors.transparent).intoGestureDetector(
                      onTap: () {
                    controller.onTitleSelected(index);
                  });
                },
                scrollDirection: Axis.horizontal,
              ).intoContainer(height: $(32)).listenSizeChanged(onSizeChanged: (size) {
                if (size.width >= ScreenUtil.screenSize.width) {
                  controller.titleNeedScroll = true;
                } else {
                  controller.titleNeedScroll = false;
                }
                controller.update();
              }),
              SizedBox(height: $(10)),
              controller.selectedTitle == null
                  ? Container()
                  : ScrollablePositionedList.builder(
                      padding: EdgeInsets.symmetric(horizontal: $(10)),
                      itemCount: controller.selectedTitle!.effects.length,
                      itemBuilder: (context, index) {
                        var data = controller.selectedTitle!.effects[index];
                        var checked = data == controller.selectedEffect;
                        return SizedBox(
                          width: itemWidth,
                          height: itemWidth,
                          child: Padding(
                            padding: EdgeInsets.all($(2)),
                            child: item(data, checked).intoGestureDetector(onTap: () {
                              controller.onItemSelected(index);
                              if (controller.selectedEffect != null && controller.resultMap[controller.selectedEffect!.key] == null) {
                                generate();
                              }
                            }),
                          ),
                        );
                      },
                      scrollDirection: Axis.horizontal,
                    ).intoContainer(height: itemWidth),
              SizedBox(height: ScreenUtil.getBottomPadding(context)),
            ],
          ),
        );
        if (controller.resultMap.isNotEmpty) {
          return WillPopScope(
              child: child,
              onWillPop: () async {
                return _willPopCallback(context);
              });
        }
        return child;
      },
      init: Get.find<StyleMorphController>(),
    );
  }

  pickPhoto(BuildContext context, StyleMorphController controller) {
    PAICamera.takePhoto(context).then((value) async {
      if (value == null) {
        return;
      }
      photoType = value.source;
      CacheManager cacheManager = AppDelegate().getManager();
      var path = await ImageUtils.onImagePick(value.xFile.path, cacheManager.storageOperator.recordStyleMorphDir.path);
      changeOriginFile(File(path));
    });
  }

  toPrint(BuildContext context, StyleMorphController controller) async {
    var selectedEffect = controller.selectedEffect;
    if (selectedEffect == null || controller.resultMap[selectedEffect.key] == null) {
      CommonExtension().showToast(S.of(context).select_a_style);
      return;
    }
    var filePath = controller.resultMap[selectedEffect.key];
    Print.open(context, source: 'stylemorph', file: File(filePath!));
  }

  savePhoto(BuildContext context, StyleMorphController controller) async {
    if (controller.selectedEffect == null) {
      CommonExtension().showToast(S.of(context).select_a_style);
      return;
    }
    if (controller.resultFile == null) {
      CommonExtension().showToast(S.of(context).select_a_style);
      return;
    }
    await showLoading();
    if (controller.containsOriginal.value) {
      ui.Image? cropImage;
      if (cropKey.currentContext != null) {
        cropImage = await getBitmapFromContext(cropKey.currentContext!, pixelRatio: 10);
      }
      var resultImage = await SyncFileImage(file: controller.resultFile!).getImage();
      var uint8list = await addWaterMark(originalImage: cropImage, image: resultImage.image);
      String imgDir = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
      var file = File(imgDir + "${DateTime.now().millisecondsSinceEpoch}.png");
      await file.writeAsBytes(uint8list.toList());
      await GallerySaver.saveImage(file.path, albumName: saveAlbumName);
      file.delete();
    } else {
      GallerySaver.saveImage(controller.resultFile!.path, albumName: saveAlbumName);
    }
    await hideLoading();
    CommonExtension().showImageSavedOkToast(context);
    controller.onSavePhoto(photo: 'image');
  }

  shareOut(BuildContext context, StyleMorphController controller) async {
    if (controller.selectedEffect == null) {
      CommonExtension().showToast(S.of(context).select_a_style);
      return;
    }
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
    var uint8list = await ImageUtils.printStyleMorphDrawData(
        controller.originFile, File(controller.resultMap[controller.selectedEffect!.key]!), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
    ShareScreen.startShare(context,
        backgroundColor: Color(0x77000000),
        style: 'StyleMorph',
        image: base64Encode(uint8list),
        isVideo: false,
        originalUrl: null,
        effectKey: 'StyleMorph', onShareSuccess: (platform) {
      controller.onResultShare(source: photoType, platform: platform, photo: 'image');
    });
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
  }

  shareToDiscovery(BuildContext context, StyleMorphController controller) async {
    if (controller.selectedEffect == null) {
      CommonExtension().showToast(S.of(context).select_a_style);
      return;
    }
    showLoading().whenComplete(() {
      uploadImageController.upload(file: controller.originFile).then((value) {
        hideLoading().whenComplete(() {
          if (!TextUtil.isEmpty(value)) {
            AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_stylemorph', callback: () {
              var file = File(controller.resultMap[controller.selectedEffect!.key]!);
              ShareDiscoveryScreen.push(
                context,
                effectKey: controller.selectedEffect!.key,
                originalUrl: value,
                image: base64Encode(file.readAsBytesSync()),
                isVideo: false,
                category: HomeCardType.stylemorph,
              ).then((value) {
                if (value ?? false) {
                  controller.onResultShare(source: photoType, platform: 'discovery', photo: 'image');
                  showShareSuccessDialog(context);
                }
              });
            }, autoExec: true);
          }
        });
      });
    });
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

  Widget item(EffectItem data, bool checked) {
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

  Future<bool> _willPopCallback(BuildContext context) async {
    if (controller.resultMap.isNotEmpty) {
      showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: $(20)),
            TitleTextWidget(S.of(context).exit_msg, ColorConstant.White, FontWeight.w600, 18),
            SizedBox(height: $(15)),
            TitleTextWidget(S.of(context).exit_msg1, ColorConstant.HintColor, FontWeight.w400, 14),
            SizedBox(height: $(15)),
            TitleTextWidget(
              S.of(context).exit_editing,
              ColorConstant.White,
              FontWeight.w600,
              16,
            )
                .intoContainer(
              margin: EdgeInsets.symmetric(horizontal: $(25)),
              padding: EdgeInsets.symmetric(vertical: $(10)),
              width: double.maxFinite,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: ColorConstant.BlueColor),
            )
                .intoGestureDetector(onTap: () {
              Navigator.pop(context, true);
            }),
            TitleTextWidget(
              S.of(context).cancel,
              ColorConstant.White,
              FontWeight.w400,
              16,
            ).intoPadding(padding: EdgeInsets.only(top: $(15), bottom: $(25))).intoGestureDetector(onTap: () {
              Navigator.pop(context);
            }),
          ],
        ).intoContainer(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: ColorConstant.EffectFunctionGrey,
            borderRadius: BorderRadius.only(topLeft: Radius.circular($(32)), topRight: Radius.circular($(32))),
          ),
        ),
      ).then((value) {
        if (value ?? false) {
          pop();
        }
      });
      return false;
    } else {
      return true;
    }
  }
}
