import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/mine/refcode/submit_invited_code_screen.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'style_morph_controller.dart';

class StyleMorphScreen extends StatefulWidget {
  String source;

  String path;
  String photoType;

  StyleMorphScreen({
    Key? key,
    required this.source,
    required this.path,
    required this.photoType,
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

  @override
  void initState() {
    super.initState();
    Posthog().screen(screenName: 'stylemorph_screen');
    photoType = widget.photoType;
    source = widget.source;
    uploadImageController = Get.put(UploadImageController());
    controller = Get.put(StyleMorphController(originFile: File(widget.path)));
    itemWidth = ScreenUtil.screenSize.width / 6;
  }

  changeOriginFile(File file) {
    uploadImageController.imageUrl.value = '';
    controller.resultMap.clear();
    controller.originFile = file;
    controller.update();
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
        Events.styleMorphCompleteSuccess(photo: 'gallery');
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
      File compressedImage = await imageCompressAndGetFile(controller.originFile, imageSize: 768);
      await uploadImageController.uploadCompressedImage(compressedImage, key: key);
      if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
        simulateProgressBarController.onError();
      } else {
        simulateProgressBarController.uploadComplete();
      }
    }
    var cachedId = await uploadImageController.getCachedIdByKey(key);
    controller.startTransfer(uploadImageController.imageUrl.value, cachedId).then((value) {
      if (value != null) {
        if (value.entity != null) {
          simulateProgressBarController.loadComplete();
          Events.styleMorphCompleteSuccess(photo: widget.photoType);
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
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
      ),
      body: GetBuilder<StyleMorphController>(
          builder: (controller) {
            return Column(
              children: [
                Expanded(
                  child: buildImage(context, controller).listenSizeChanged(onSizeChanged: (size) {
                    controller.imageStackSize = size;
                    controller.calculatePosY();
                  }),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(Images.ic_camera, height: $(24), width: $(24))
                        .intoGestureDetector(
                          onTap: () => pickPhoto(context, controller),
                        )
                        .intoContainer(padding: EdgeInsets.all($(15))),
                    Image.asset(Images.ic_download, height: $(24), width: $(24))
                        .intoGestureDetector(
                          onTap: () => savePhoto(context, controller),
                        )
                        .intoContainer(padding: EdgeInsets.all($(15))),
                    Image.asset(Images.ic_share_discovery, height: $(24), width: $(24))
                        .intoGestureDetector(
                          onTap: () => shareToDiscovery(context, controller),
                        )
                        .intoContainer(padding: EdgeInsets.all($(15))),
                  ],
                ),
                ScrollablePositionedList.builder(
                  physics: controller.titleNeedScroll ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
                  itemCount: controller.titleList.length,
                  itemScrollController: controller.titleScrollController,
                  itemPositionsListener: controller.titlePositionsListener,
                  itemBuilder: (context, index) {
                    var data = controller.titleList[index];
                    return title(data.title, index == controller.titlePos)
                        .intoContainer(padding: EdgeInsets.symmetric(horizontal: $(12), vertical: $(8)), color: Colors.transparent)
                        .intoGestureDetector(onTap: () {
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
                ScrollablePositionedList.builder(
                  padding: EdgeInsets.symmetric(horizontal: $(10)),
                  itemScrollController: controller.itemScrollController,
                  itemPositionsListener: controller.itemPositionsListener,
                  itemCount: controller.dataList.length,
                  itemBuilder: (context, index) {
                    var data = controller.dataList[index];
                    var checked = data == controller.selectedEffect;
                    return SizedBox(
                      width: itemWidth,
                      height: itemWidth,
                      child: Padding(
                        padding: EdgeInsets.all($(2)),
                        child: item(data, checked).intoGestureDetector(onTap: () {
                          controller.onItemSelected(index);
                          if (controller.selectedEffect != null && controller.resultMap[controller.selectedEffect!.data.key] == null) {
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
            );
          },
          init: Get.find<StyleMorphController>()),
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
    var pickImage = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 512, maxHeight: 512, preferredCameraDevice: CameraDevice.rear, imageQuality: 100);
    if (pickImage != null) {
      photoType = 'camera';
      changeOriginFile(File(pickImage.path));
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
      var file = await medium.file;
      if (file != null) {
        photoType = 'gallery';
        changeOriginFile(file);
        // XFile? result = await CropScreen.crop(context, image: XFile(file.path), brightness: Brightness.light);
      }
    }
  }

  savePhoto(BuildContext context, StyleMorphController controller) async {
    if (controller.selectedEffect == null) {
      CommonExtension().showToast('Please select an effect');
      return;
    }
    await showLoading();
    GallerySaver.saveImage(controller.resultMap[controller.selectedEffect!.data.key]!, albumName: saveAlbumName);
    await hideLoading();
    CommonExtension().showImageSavedOkToast(context);
    Events.styleMorphDownload(type: 'image');
  }

  shareToDiscovery(BuildContext context, StyleMorphController controller) {
    if (controller.selectedEffect == null) {
      CommonExtension().showToast('Please select an effect');
      return;
    }
    AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_stylemorph', callback: () {
      var file = File(controller.resultMap[controller.selectedEffect!.data.key]!);
      ShareDiscoveryScreen.push(
        context,
        effectKey: 'StyleMorph',
        originalUrl: uploadImageController.imageUrl.value,
        image: base64Encode(file.readAsBytesSync()),
        isVideo: false,
        category: DiscoveryCategory.stylemorph,
      ).then((value) {
        if (value ?? false) {
          Events.styleMorphCompleteShare(source: widget.photoType, platform: 'discovery', type: 'image');
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

  Widget item(ChooseTabItemInfo data, bool checked) {
    var image = CachedNetworkImageUtils.custom(
      context: context,
      imageUrl: data.data.imageUrl,
      fit: BoxFit.cover,
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

  Widget buildImage(BuildContext context, StyleMorphController controller) {
    var origin = Stack(
      fit: StackFit.expand,
      children: [
        Image.file(controller.originFile, fit: BoxFit.fill),
        Image.file(
          controller.originFile,
          fit: BoxFit.contain,
        ).intoCenter().blur(),
      ],
    );
    if (controller.selectedEffect == null || controller.resultMap[controller.selectedEffect!.data.key] == null) {
      return origin;
    } else {
      var showFile = controller.showOrigin ? controller.originFile : File(controller.resultMap[controller.selectedEffect!.data.key]!);
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(showFile, fit: BoxFit.fill),
          Image.file(
            showFile,
            fit: BoxFit.contain,
          ).intoCenter().blur(),
          Positioned(
            child: Listener(
              onPointerDown: (details) {
                controller.showOrigin = true;
              },
              onPointerCancel: (details) {
                controller.showOrigin = false;
              },
              onPointerUp: (details) {
                controller.showOrigin = false;
              },
              child: Image.asset(
                Images.ic_metagram_show_origin,
                width: $(28),
              ).intoContainer(padding: EdgeInsets.all($(4))).intoMaterial(
                    color: Color(0x11000000),
                    borderRadius: BorderRadius.circular($(6)),
                    elevation: 1,
                  ),
            ),
            bottom: controller.imagePosBottom + $(12),
            right: controller.imagePosRight + $(12),
          )
        ],
      );
    }
  }
}
