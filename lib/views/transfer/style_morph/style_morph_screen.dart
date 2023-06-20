import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/switch_image_card.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/li_pop_menu.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/mine/refcode/submit_invited_code_screen.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:cartoonizer/views/print/print.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'style_morph_controller.dart';

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
  late UploadImageController uploadImageController;
  late double itemWidth;
  UserManager userManager = AppDelegate.instance.getManager();
  late String photoType;
  int generateCount = 0;

  @override
  void initState() {
    super.initState();
    Posthog().screen(screenName: 'stylemorph_screen');
    photoType = widget.photoType;
    source = widget.source;
    uploadImageController = Get.put(UploadImageController());
    controller = Get.put(StyleMorphController(record: widget.record, initKey: widget.initKey));
    itemWidth = ScreenUtil.screenSize.width / 6;
  }

  changeOriginFile(File file) {
    uploadImageController.imageUrl.value = '';
    controller.resultMap.clear();
    controller.originFile = file;
    generateCount = 0;
    controller.update();
    if (controller.selectedEffect != null) {
      generate();
    }
  }

  generate() async {
    String key = await md5File(controller.originFile);
    var needUpload = await uploadImageController.needUploadByKey(key);
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
        Events.styleMorphCompleteSuccess(photo: widget.photoType);
        generateCount++;
        if (generateCount - 1 > 0) {
          Events.metaverseCompleteGenerateAgain(time: generateCount - 1);
        }
        controller.onSuccess();
      } else {
        controller.onError();
        if (value.error != null) {
          showLimitDialog(context, value.error!);
        } else {
          // Navigator.of(context).pop();
        }
      }
    });
    if (needUpload) {
      EffectManager effectManager = AppDelegate().getManager();
      var imageSize = effectManager.data?.imageMaxl ?? 512;
      File compressedImage = await imageCompressAndGetFile(controller.originFile, imageSize: imageSize);
      await uploadImageController.uploadCompressedImage(compressedImage, key: key);
      if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
        simulateProgressBarController.onError();
      } else {
        simulateProgressBarController.uploadComplete();
      }
    }
    if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
      return;
    }
    var cachedId = await uploadImageController.getCachedIdByKey(key);
    controller.startTransfer(uploadImageController.imageUrl.value, cachedId, onFailed: (response) {
      uploadImageController.deleteUploadData(controller.originFile, key: key);
    }).then((value) {
      if (value != null) {
        if (value.entity != null) {
          simulateProgressBarController.loadComplete();
          Events.styleMorphCompleteSuccess(photo: photoType);
        } else {
          simulateProgressBarController.onError(error: value.type);
        }
      } else {
        simulateProgressBarController.onError();
      }
    });
  }

  @override
  void dispose() {
    Get.delete<StyleMorphController>();
    Get.delete<UploadImageController>();
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
              LiPopMenu.showLinePop(context, listData: [
                ListPopItem(text: S.of(context).tabDiscovery, icon: Images.ic_share_discovery),
                ListPopItem(text: S.of(context).share, icon: Images.ic_share),
              ], clickCallback: (index, title) {
                if (index == 0) {
                  shareToDiscovery(context, controller);
                } else {
                  shareOut(context, controller);
                }
              });
            }),
          ),
          body: Column(
            children: [
              Expanded(
                  child: SwitchImageCard(
                origin: controller.originFile,
                result: controller.resultFile,
                imageStackSize: controller.imageStackSize,
              ).listenSizeChanged(onSizeChanged: (size) {
                controller.imageStackSize = size;
                controller.update();
              })),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(Images.ic_camera, height: $(24), width: $(24))
                      .intoGestureDetector(
                        onTap: () => pickPhoto(context, controller),
                      )
                      .intoContainer(
                        padding: EdgeInsets.all($(15)),
                        margin: EdgeInsets.symmetric(horizontal: $(20)),
                      ),
                  Image.asset(Images.ic_share_print, height: $(24), width: $(24))
                      .intoGestureDetector(
                        onTap: () => toPrint(context, controller),
                      )
                      .intoContainer(
                        padding: EdgeInsets.all($(15)),
                        margin: EdgeInsets.symmetric(horizontal: $(20)),
                      ),
                  Image.asset(Images.ic_download, height: $(24), width: $(24))
                      .intoGestureDetector(
                        onTap: () => savePhoto(context, controller),
                      )
                      .intoContainer(
                        padding: EdgeInsets.all($(15)),
                        margin: EdgeInsets.symmetric(horizontal: $(20)),
                      ),
                ],
              ),
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
    showModalBottomSheet<bool>(
        context: context,
        builder: (ctxt) {
          return Column(
            children: [
              SizedBox(height: $(5)),
              Text(
                S.of(context).take_a_selfie,
                style: TextStyle(
                  fontSize: $(18),
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
                Navigator.of(ctxt).pop(true);
              }),
              Divider(height: 1, color: ColorConstant.LineColor),
              Text(
                S.of(context).select_from_album,
                style: TextStyle(
                  fontSize: $(18),
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
                Navigator.of(ctxt).pop(false);
              }),
            ],
            mainAxisSize: MainAxisSize.min,
          ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context))).intoMaterial(color: ColorConstant.BackgroundColor);
        }).then((value) {
      if (value != null) {
        if (value) {
          pickPhotoFromCamera(context, controller);
        } else {
          pickPhotoFromAlbum(context, controller);
        }
      }
    });
  }

  pickPhotoFromCamera(BuildContext context, StyleMorphController controller) async {
    var pickImage = await ImagePicker().pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear, imageQuality: 100);
    if (pickImage != null) {
      photoType = 'camera';
      CacheManager cacheManager = AppDelegate().getManager();
      var path = await ImageUtils.onImagePick(pickImage.path, cacheManager.storageOperator.recordStyleMorphDir.path);
      changeOriginFile(File(path));
      // XFile? result = await CropScreen.crop(context, image: pickImage, brightness: Brightness.light);
    }
  }

  pickPhotoFromAlbum(BuildContext context, StyleMorphController controller) async {
    var files = await PickAlbumScreen.pickImage(
      context,
      count: 1,
      switchAlbum: true,
    );
    if (files != null && files.isNotEmpty) {
      var medium = files.first;
      var file = await medium.originFile;
      if (file != null) {
        CacheManager cacheManager = AppDelegate().getManager();
        var path = await ImageUtils.onImagePick(file.path, cacheManager.storageOperator.recordStyleMorphDir.path);
        photoType = 'gallery';
        changeOriginFile(File(path));
        // XFile? result = await CropScreen.crop(context, image: XFile(file.path), brightness: Brightness.light);
      }
    }
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
    await showLoading();
    GallerySaver.saveImage(controller.resultMap[controller.selectedEffect!.key]!, albumName: saveAlbumName);
    await hideLoading();
    CommonExtension().showImageSavedOkToast(context);
    Events.styleMorphDownload(type: 'image');
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
      Events.styleMorphCompleteShare(source: photoType, platform: platform, type: 'image');
    });
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
  }

  shareToDiscovery(BuildContext context, StyleMorphController controller) async {
    if (controller.selectedEffect == null) {
      CommonExtension().showToast(S.of(context).select_a_style);
      return;
    }
    if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
      await showLoading();
      String key = await md5File(controller.originFile);
      var needUpload = await uploadImageController.needUploadByKey(key);
      if (needUpload) {
        File compressedImage = await imageCompressAndGetFile(controller.originFile);
        await uploadImageController.uploadCompressedImage(compressedImage, key: key);
        await hideLoading();
        if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
          return;
        }
      } else {
        await hideLoading();
      }
    }
    AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_stylemorph', callback: () {
      var file = File(controller.resultMap[controller.selectedEffect!.key]!);
      ShareDiscoveryScreen.push(
        context,
        effectKey: controller.selectedEffect!.key,
        originalUrl: uploadImageController.imageUrl.value,
        image: base64Encode(file.readAsBytesSync()),
        isVideo: false,
        category: HomeCardType.style_morph,
      ).then((value) {
        if (value ?? false) {
          Events.styleMorphCompleteShare(source: photoType, platform: 'discovery', type: 'image');
          showShareSuccessDialog(context);
        }
      });
    }, autoExec: true);
  }

  showLimitDialog(BuildContext context, AccountLimitType type) {
    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: $(27)),
                Image.asset(
                  Images.ic_limit_icon,
                ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(22))),
                SizedBox(height: $(16)),
                TitleTextWidget(
                  type.getContent(context, 'Style Morph'),
                  ColorConstant.White,
                  FontWeight.w500,
                  $(13),
                  maxLines: 100,
                  align: TextAlign.center,
                ).intoContainer(
                  width: double.maxFinite,
                  padding: EdgeInsets.only(
                    bottom: $(30),
                    left: $(30),
                    right: $(30),
                  ),
                  alignment: Alignment.center,
                ),
                Text(
                  type.getSubmitText(context),
                  style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(14)),
                )
                    .intoContainer(
                  width: double.maxFinite,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular($(8)), color: ColorConstant.DiscoveryBtn),
                  padding: EdgeInsets.only(top: $(10), bottom: $(10)),
                  alignment: Alignment.center,
                )
                    .intoGestureDetector(onTap: () {
                  Navigator.of(context).pop(false);
                }),
                type.getPositiveText(context) != null
                    ? Text(
                        type.getPositiveText(context)!,
                        style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(14)),
                      )
                        .intoContainer(
                        width: double.maxFinite,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular($(8)), color: Color(0xff292929)),
                        padding: EdgeInsets.only(top: $(10), bottom: $(10)),
                        margin: EdgeInsets.only(top: $(16), bottom: $(24)),
                        alignment: Alignment.center,
                      )
                        .intoGestureDetector(onTap: () {
                        Navigator.pop(_, true);
                      })
                    : SizedBox.shrink(),
              ],
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(25))).customDialogStyle()).then((value) {
      if (value == null) {
        Navigator.of(context).pop();
      } else if (value) {
        switch (type) {
          case AccountLimitType.guest:
            userManager.doOnLogin(context,
                logPreLoginAction: 'stylemorph_generate_limit',
                callback: () {
                  Navigator.of(context).pop();
                },
                autoExec: true,
                onCancel: () {
                  Navigator.of(context).pop();
                });
            break;
          case AccountLimitType.normal:
            userManager.doOnLogin(context,
                logPreLoginAction: 'stylemorph_generate_limit',
                callback: () {
                  PaymentUtils.pay(context, 'stylemorph_generate_limit').then((value) {
                    Navigator.of(context).pop();
                  });
                },
                autoExec: true,
                onCancel: () {
                  Navigator.of(context).pop();
                });
            break;
          case AccountLimitType.vip:
            break;
        }
      } else {
        userManager.doOnLogin(context, logPreLoginAction: 'stylemorph_generate_limit', callback: () {
          Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
          EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.MINE.id()]));
          delay(() => SubmitInvitedCodeScreen.push(Get.context!), milliseconds: 500);
          // Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
        }, autoExec: true);
      }
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
          Navigator.pop(context);
        }
      });
      return false;
    } else {
      return true;
    }
  }
}
