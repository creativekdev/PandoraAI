import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/camera/pai_camera_screen.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/switch_image_card.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
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
import 'package:cartoonizer/views/SignupScreen.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/li_pop_menu.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/mine/refcode/submit_invited_code_screen.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:cartoonizer/views/print/print.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:cartoonizer/views/transfer/controller/cartoonizer_controller.dart';
import 'package:common_utils/common_utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../mine/filter/im_effect_screen.dart';
import '../../mine/filter/im_filter.dart';

class CartoonizeScreen extends StatefulWidget {
  String source;

  RecentEffectModel record;
  String? initKey;
  String photoType;

  CartoonizeScreen({
    Key? key,
    required this.source,
    required this.record,
    required this.photoType,
    this.initKey,
  }) : super(key: key);

  @override
  State<CartoonizeScreen> createState() => _CartoonizeScreenState();
}

class _CartoonizeScreenState extends AppState<CartoonizeScreen> {
  late String source;
  late CartoonizerController controller;
  late UploadImageController uploadImageController;
  late double itemWidth;
  UserManager userManager = AppDelegate.instance.getManager();
  late String photoType;
  int generateCount = 0;
  GlobalKey cropKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Posthog().screen(screenName: 'cartoonize_detail_screen');
    photoType = widget.photoType;
    source = widget.source;
    uploadImageController = Get.put(UploadImageController());
    controller = Get.put(CartoonizerController(
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
        // do nothing
      } else if (value.result) {
        controller.onGenerateSuccess(source: photoType, style: controller.selectedEffect?.key ?? '');
        // generateCount++;
        // if (generateCount - 1 > 0) {
        // Events.facetoonGeneratedAgain(style: controller.selectedEffect?.key ?? '', time: generateCount - 1);
        // }
      } else {
        if (value.error != null) {
          showLimitDialog(context, type: value.error!, function: 'cartoonize', source: 'cartoonize_result_page');
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
      if (response.data != null) {
        var data = response.data;
        if (data['code'] == "DAILY_IP_LIMIT_EXCEEDED") {
          if (userManager.isNeedLogin) {
            delay(() => showDialogLogin(context), milliseconds: 500);
          } else {
            CommonExtension().showToast(S.of(context).DAILY_IP_LIMIT_EXCEEDED);
          }
        }
      }
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

  @override
  void dispose() {
    Get.delete<CartoonizerController>();
    Get.delete<UploadImageController>();
    super.dispose();
  }

  void showDialogLogin(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(2.h),
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    Images.ic_signup_cartoon,
                    width: 60.w,
                    height: 20.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  TitleTextWidget(S.of(context).signup_text1, ColorConstant.TextBlack, FontWeight.w600, 18),
                  SizedBox(
                    height: 1.h,
                  ),
                  TitleTextWidget(S.of(context).signup_text2, ColorConstant.TextBlack, FontWeight.w400, 14, maxLines: 3),
                  SizedBox(
                    height: 2.h,
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      CacheManager cacheManager = AppDelegate.instance.getManager();
                      cacheManager.setString(CacheManager.preSignupAction, 'facetoon_daily_limit');
                      GetStorage().write('login_back_page', '/ChoosePhotoScreen');
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: RouteSettings(name: "/SignupScreen", arguments: "choose_photo"),
                            builder: (context) => SignupScreen(),
                          ));
                      userManager.refreshUser(context: context);
                    },
                    child: RoundedBorderBtnWidget(S.of(context).sign_up, color: ColorConstant.TextBlack),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return GetBuilder<CartoonizerController>(
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
                  ListPopItem(
                      text: S.of(context).share_out,
                      icon: Images.ic_share,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: RouteSettings(name: "/ImFilterScreen"),
                            builder: (context) => ImEffectScreen(
                              tab: TABS.EFFECT,
                              source: widget.source,
                              originFile: controller.originFile,
                              resultFile: controller.originFile!,
                              photoType: widget.photoType,
                              isStyleMorph: false,
                            ),
                          ),
                        );
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
                      mainAxisAlignment: MainAxisAlignment.center,
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
                    ),
                  )
                ],
              ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(12))),
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
      init: Get.find<CartoonizerController>(),
    );
  }

  pickPhoto(BuildContext context, CartoonizerController controller) async {
    var paiCameraEntity = await PAICamera.takePhoto(context);
    if (paiCameraEntity != null) {
      photoType = paiCameraEntity.source;
      CacheManager cacheManager = AppDelegate().getManager();
      var path = await ImageUtils.onImagePick(paiCameraEntity.xFile.path, cacheManager.storageOperator.recordCartoonizeDir.path);
      changeOriginFile(File(path));
    }
  }

  toPrint(BuildContext context, CartoonizerController controller) async {
    var selectedEffect = controller.selectedEffect;
    if (selectedEffect == null || controller.resultMap[selectedEffect.key] == null) {
      CommonExtension().showToast(S.of(context).select_a_style);
      return;
    }
    var filePath = controller.resultMap[selectedEffect.key];
    Print.open(context, source: 'cartoonize', file: File(filePath!));
  }

  savePhoto(BuildContext context, CartoonizerController controller) async {
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

  shareOut(BuildContext context, CartoonizerController controller) async {
    if (controller.selectedEffect == null) {
      CommonExtension().showToast(S.of(context).select_a_style);
      return;
    }
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
    var uint8list = await ImageUtils.printCartoonizeDrawData(
        controller.originFile, File(controller.resultMap[controller.selectedEffect!.key]!), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
    ShareScreen.startShare(context,
        backgroundColor: Color(0x77000000),
        style: controller.selectedEffect!.key,
        image: base64Encode(uint8list),
        isVideo: false,
        originalUrl: null,
        effectKey: controller.selectedEffect!.key, onShareSuccess: (platform) {
      controller.onResultShare(source: source, platform: platform, photo: 'image');
    });
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
  }

  shareToDiscovery(BuildContext context, CartoonizerController controller) async {
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
    AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_cartoonize', callback: () {
      var file = File(controller.resultMap[controller.selectedEffect!.key]!);
      ShareDiscoveryScreen.push(
        context,
        effectKey: controller.selectedEffect!.key,
        originalUrl: uploadImageController.imageUrl.value,
        image: base64Encode(file.readAsBytesSync()),
        isVideo: false,
        category: HomeCardType.cartoonize,
      ).then((value) {
        if (value ?? false) {
          controller.onResultShare(source: source, platform: 'discovery', photo: 'image');
          showShareSuccessDialog(context);
        }
      });
    }, autoExec: true);
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
