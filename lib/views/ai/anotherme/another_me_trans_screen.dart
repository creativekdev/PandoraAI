import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_controller.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/trans_result_card.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'anotherme.dart';
import 'trans_result_anim_screen.dart';
import 'widgets/am_opt_container.dart';
import 'widgets/trans_result_video_build_dialog.dart';

const axisRatioFlag = 0.8;

class AnotherMeTransScreen extends StatefulWidget {
  File file;
  double ratio;
  File? resultFile;
  String photoType;

  AnotherMeTransScreen({
    Key? key,
    required this.file,
    required this.ratio,
    this.resultFile,
    required this.photoType,
  }) : super(key: key);

  @override
  State<AnotherMeTransScreen> createState() => _AnotherMeTransScreenState();
}

class _AnotherMeTransScreenState extends AppState<AnotherMeTransScreen> {
  late File file;
  late double ratio;
  UserManager userManager = AppDelegate().getManager();
  AnotherMeController controller = Get.find();
  UploadImageController uploadImageController = Get.find();
  RecentController recentController = Get.find();
  GlobalKey<AMOptContainerState> optKey = GlobalKey();
  late double resultCardWidth;
  late double resultCardHeight;
  late double dividerSize;
  File? transResult;
  late String photoType;
  int generateCount = 0;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'metaverse_generate_screen');
    ratio = widget.ratio;
    photoType = widget.photoType;
    dividerSize = $(8);
    resultCardWidth = ScreenUtil.screenSize.width - $(32);
    resultCardHeight = ratio > axisRatioFlag ? (resultCardWidth - dividerSize) / 2 * ratio : resultCardWidth * ratio * 2 + dividerSize;
    file = widget.file;
    transResult = widget.resultFile;
    delay(() {
      if (transResult == null) {
        generate(context, controller);
      } else {
        md5File(file).then((value) {
          uploadImageController.needUploadByKey(value);
        });
        controller.sourcePhoto = file;
        controller.transKey = transResult!.path;
        controller.onSuccess();
      }
    });
  }

  showLimitDialog(BuildContext context, String title, String content) {
    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: $(27)),
                Image.asset(
                  Images.ic_warning,
                  width: $(32),
                  color: Color(0xFFFD4245),
                ).intoContainer(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFFD4245), width: 1),
                      borderRadius: BorderRadius.circular($(48)),
                    )),
                SizedBox(height: $(20)),
                TitleTextWidget(
                  title,
                  Color(0xFFFD4245),
                  FontWeight.w500,
                  $(17),
                  maxLines: 100,
                  align: TextAlign.center,
                ).intoContainer(
                  width: double.maxFinite,
                  padding: EdgeInsets.symmetric(horizontal: $(30)),
                  alignment: Alignment.center,
                ),
                SizedBox(height: $(8)),
                TitleTextWidget(
                  content,
                  ColorConstant.White,
                  FontWeight.w500,
                  $(13),
                  maxLines: 100,
                  align: TextAlign.center,
                ).intoContainer(
                  width: double.maxFinite,
                  padding: EdgeInsets.only(
                    bottom: $(40),
                    left: $(30),
                    right: $(30),
                  ),
                  alignment: Alignment.center,
                ),
                Container(height: 1, color: ColorConstant.LineColor),
                Row(
                  children: [
                    isVip()
                        ? SizedBox.shrink()
                        : Expanded(
                            child: Text(
                              S.of(context).buy,
                              style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.DiscoveryBtn, fontSize: $(17)),
                            )
                                .intoContainer(
                              width: double.maxFinite,
                              color: Colors.transparent,
                              padding: EdgeInsets.only(top: $(10), bottom: $(12)),
                              alignment: Alignment.center,
                            )
                                .intoGestureDetector(onTap: () {
                              Navigator.pop(_, true);
                            }),
                          ),
                    isVip() ? SizedBox.shrink() : Container(height: $(48), color: ColorConstant.LineColor, width: 1),
                    Expanded(
                      child: Text(
                        S.of(context).ok,
                        style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.DiscoveryBtn, fontSize: $(17)),
                      )
                          .intoContainer(
                        width: double.maxFinite,
                        color: Colors.transparent,
                        padding: EdgeInsets.only(top: $(10), bottom: $(12)),
                        alignment: Alignment.center,
                      )
                          .intoGestureDetector(onTap: () {
                        Navigator.pop(_, false);
                      }),
                    ),
                  ],
                ),
              ],
            ).customDialogStyle()).then((value) {
      if (value ?? false) {
        userManager.doOnLogin(context, logPreLoginAction: 'metaverse_generate_limit', callback: () {
          PaymentUtils.pay(context, 'metaverse_result_page');
        }, autoExec: true);
      } else {
        userManager.doOnLogin(context, logPreLoginAction: 'metaverse_generate_limit');
      }
    });
  }

  void generate(BuildContext _context, AnotherMeController controller) async {
    var key = await md5File(file);
    var needUpload = await uploadImageController.needUploadByKey(key);
    SimulateProgressBarController simulateProgressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(
      _context,
      needUploadProgress: needUpload,
      controller: simulateProgressBarController,
      config: SimulateProgressBarConfig.anotherMe(),
    ).then((value) {
      if (value == null || value.isEmpty) {
        controller.onError();
      } else if (value.first ?? false) {
        Events.metaverseCompleteSuccess(photo: photoType);
        generateCount++;
        if (generateCount - 1 > 0) {
          Events.metaverseCompleteGenerateAgain(time: generateCount - 1);
        }
        controller.onSuccess();
        setState(() {
          showAnim(context);
        });
      } else {
        if (value.length == 3) {
          if (!TextUtil.isEmpty(value.last)) {
            showLimitDialog(context, value[1], value[2]);
          }
        }
        controller.onError();
      }
    });
    controller.onTakePhoto(file, uploadImageController, key).then((value) {
      simulateProgressBarController.uploadComplete();
      if (value) {
        uploadImageController.getCachedIdByKey(key).then((cachedId) {
          controller.startTransfer(uploadImageController.imageUrl.value, cachedId).then((value) {
            if (value != null) {
              if (value.entity != null) {
                uploadImageController.updateCachedId(file, value.entity!.cacheId ?? '');
                var image = File(controller.transKey!);
                recentController.onMetaverseUsed(file, image);
                transResult = image;
                simulateProgressBarController.loadComplete();
              } else {
                simulateProgressBarController.onError(errorTitle: value.msgTitle, errorContent: value.msgContent);
              }
            } else {
              simulateProgressBarController.onError();
            }
          });
        });
      } else {
        simulateProgressBarController.onError();
      }
    });
  }

  Future<void> showAnim(BuildContext context) async {
    return Navigator.of(context).push<void>(NoAnimRouter(TransResultAnimScreen(
      origin: file,
      result: transResult!,
      ratio: ratio,
    )));
  }

  @override
  Widget buildWidget(BuildContext context) => WillPopScope(
      child: GetBuilder<AnotherMeController>(
        init: controller,
        builder: (controller) {
          if (TextUtil.isEmpty(controller.transKey)) {
            return Scaffold(
                backgroundColor: ColorConstant.BackgroundColor,
                body: Stack(children: [
                  Image.file(
                    File(file.path),
                    width: ScreenUtil.screenSize.width,
                    height: ScreenUtil.screenSize.height,
                    fit: BoxFit.contain,
                  ),
                  Image.asset(
                    Images.ic_back,
                    height: $(24),
                    width: $(24),
                  )
                      .intoContainer(
                        padding: EdgeInsets.all($(10)),
                        margin: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight(), left: $(5)),
                      )
                      .hero(tag: AnotherMe.logoBackTag)
                      .intoGestureDetector(onTap: () {
                    Navigator.pop(context, true);
                  }),
                  controller.error()
                      ? Positioned(
                          bottom: ScreenUtil.getBottomPadding(context, padding: 32),
                          child: OutlineWidget(
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
                              decoration: BoxDecoration(color: Color(0x44000000), borderRadius: BorderRadius.circular($(12))),
                              padding: EdgeInsets.all($(2)),
                            ),
                          ).intoGestureDetector(onTap: () {
                            controller.clearTransKey();
                            generate(context, controller);
                          }).intoContainer(width: ScreenUtil.screenSize.width - $(160), margin: EdgeInsets.symmetric(horizontal: $(80))),
                        )
                      : Container(),
                ]));
          }
          return Scaffold(
            backgroundColor: ColorConstant.BackgroundColor,
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        child: TransResultNewCard(
                          originalImage: file,
                          resultImage: File(controller.transKey!),
                          width: resultCardWidth,
                          height: resultCardHeight,
                          direction: ratio > axisRatioFlag ? Axis.horizontal : Axis.vertical,
                          dividerSize: dividerSize,
                        ),
                        borderRadius: BorderRadius.circular($(12)),
                      )
                          .intoContainer(
                            margin: EdgeInsets.only(right: 2, left: 2),
                          )
                          .intoCenter()
                          .intoContainer(
                              padding: EdgeInsets.only(top: 48),
                              margin: EdgeInsets.only(right: 14, left: 14, top: 50 + ScreenUtil.getStatusBarHeight(), bottom: $(13)),
                              decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images.ic_trans_result_bg), fit: BoxFit.fill))),
                    ),
                    AMOptContainer(
                      key: optKey,
                      onChoosePhotoTap: () {
                        optKey.currentState!.dismiss().whenComplete(() {
                          controller.clear(uploadImageController);
                          Events.metaverseCompleteTakeAgain();
                          Navigator.of(context).pop(false);
                        });
                      },
                      onDownloadTap: () async {
                        showSaveDialog(context, true).then((value) async {
                          if (value != null) {
                            if (value) {
                              showDialog(context: context, barrierDismissible: false, builder: (_) => TransResultVideoBuildDialog(result: transResult!, origin: file, ratio: ratio))
                                  .then((value) async {
                                if (!TextUtil.isEmpty(value)) {
                                  await showLoading();
                                  await GallerySaver.saveVideo(value!.toString(), true, toDcim: true, albumName: saveAlbumName);
                                  await hideLoading();
                                  CommonExtension().showVideoSavedOkToast(context);
                                }
                              });
                            } else {
                              await showLoading();
                              var uint8list = await printImageData(file, File(controller.transKey!), '@${userManager.user?.getShownEmail() ?? 'Pandora User'}');
                              var list = uint8list.toList();
                              var path = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
                              var imgPath = path + '${DateTime.now().millisecondsSinceEpoch}.png';
                              await File(imgPath).writeAsBytes(list);
                              await GallerySaver.saveImage(imgPath, albumName: saveAlbumName);
                              await hideLoading();
                              CommonExtension().showImageSavedOkToast(context);
                            }
                          }
                        });
                      },
                      onGenerateAgainTap: () {
                        controller.clearTransKey();
                        generate(context, controller);
                      },
                      onShareDiscoveryTap: () async {
                        if (TextUtil.isEmpty(controller.transKey)) {
                          return;
                        }
                        AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_metaverse', callback: () {
                          var file = File(controller.transKey!);
                          ShareDiscoveryScreen.push(
                            context,
                            effectKey: 'Me-taverse',
                            originalUrl: uploadImageController.imageUrl.value,
                            image: base64Encode(file.readAsBytesSync()),
                            isVideo: false,
                            category: DiscoveryCategory.another_me,
                          ).then((value) {
                            if (value ?? false) {
                              Events.metaverseCompleteShare(source: photoType == 'recently' ? 'recently' : 'metaverse', platform: 'discovery', type: 'image');
                              showShareSuccessDialog(context);
                            }
                          });
                        }, autoExec: true);
                      },
                      onShareTap: () async {
                        showSaveDialog(context, false).then((value) async {
                          if (value != null) {
                            if (value) {
                              showDialog(context: context, barrierDismissible: false, builder: (_) => TransResultVideoBuildDialog(result: transResult!, origin: file, ratio: ratio))
                                  .then((value) async {
                                if (!TextUtil.isEmpty(value)) {
                                  await showLoading();
                                  if (TextUtil.isEmpty(value)) {
                                    await hideLoading();
                                    return;
                                  }
                                  AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
                                  await hideLoading();
                                  ShareScreen.startShare(context,
                                      backgroundColor: Color(0x77000000),
                                      style: 'Me-taverse',
                                      image: value,
                                      isVideo: true,
                                      originalUrl: null,
                                      effectKey: 'Me-taverse', onShareSuccess: (platform) {
                                    Events.metaverseCompleteShare(source: photoType == 'recently' ? 'recently' : 'metaverse', platform: platform, type: 'video');
                                  });
                                  AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
                                }
                              });
                            } else {
                              await showLoading();
                              if (TextUtil.isEmpty(controller.transKey)) {
                                return;
                              }
                              var uint8list = await printImageData(file, File(controller.transKey!), '@${userManager.user?.getShownEmail() ?? 'Pandora User'}');
                              AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
                              await hideLoading();
                              ShareScreen.startShare(context,
                                  backgroundColor: Color(0x77000000),
                                  style: 'Me-taverse',
                                  image: base64Encode(uint8list),
                                  isVideo: false,
                                  originalUrl: null,
                                  effectKey: 'Me-taverse', onShareSuccess: (platform) {
                                Events.metaverseCompleteShare(source: photoType == 'recently' ? 'recently' : 'metaverse', platform: platform, type: 'image');
                              });
                              AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
                            }
                          }
                        });
                      },
                    ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context) + $(35)))
                  ],
                ).intoContainer(
                  width: ScreenUtil.screenSize.width,
                  height: ScreenUtil.screenSize.height,
                ),
                Image.asset(
                  Images.ic_back,
                  height: $(24),
                  width: $(24),
                )
                    .intoContainer(
                      padding: EdgeInsets.all($(10)),
                      margin: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight(), left: $(5)),
                    )
                    .hero(tag: AnotherMe.logoBackTag)
                    .intoGestureDetector(onTap: () {
                  Navigator.pop(context, true);
                }),
              ],
            ).intoContainer(
                height: ScreenUtil.screenSize.height,
                width: ScreenUtil.screenSize.width,
                decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images.ic_another_me_trans_bg), fit: BoxFit.fill))),
          );
        },
      ),
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      });

  double scaleSize = 1080 / 375;

  double dp(double source) => source * scaleSize;

  ///375 设计宽度下，对应输出1080宽度下缩放比2.88
  ///appIcon宽度64，二维码宽度64，标题字体17，描述文案字体13
  ///底部app推广高度105
  Future<Uint8List> printImageData(File originalImage, File resultImage, String userEmail) async {
    var bgSource = await SyncAssetImage(assets: Images.ic_another_me_trans_bg).getImage();
    var bgHeadInfo = await SyncAssetImage(assets: Images.ic_mt_result_top).getImage();
    var bgMiddleInfo = await SyncAssetImage(assets: Images.ic_mt_result_middle).getImage();
    var bgBottomInfo = await SyncAssetImage(assets: Images.ic_mt_result_bottom).getImage();
    var originalImageInfo = await SyncFileImage(file: originalImage).getImage();
    var resultImageInfo = await SyncFileImage(file: resultImage).getImage();
    var appIconImageInfo = await SyncAssetImage(assets: Images.ic_app).getImage();
    var qrCodeImageInfo = await SyncAssetImage(assets: Images.ic_app_qrcode).getImage();
    var arrowRightImageInfo = await SyncAssetImage(assets: Images.ic_another_arrow_right).getImage();
    var arrowDownImageInfo = await SyncAssetImage(assets: Images.ic_another_arrow_down).getImage();

    double width = dp(375);
    double headWidth = dp(360);
    double headBgHeight = headWidth * bgHeadInfo.image.height / bgHeadInfo.image.width;
    Offset userNamePos = Offset(dp(25), dp(70));
    double headHeight = dp(100);
    double bottomBgHeight = headWidth * bgBottomInfo.image.height / bgBottomInfo.image.width;
    double bottomHeight = dp(105);

    double imageContainerWidth = dp(324);

    double appIconSize = dp(64);
    double qrcodeSize = dp(64);
    double titleSize = dp(17);
    double nameSize = dp(13);
    double descSize = dp(13);
    double dividerSize = dp(8);
    double padding = dp(16);

    var imageWidth;
    var imageHeight;
    var ratio = originalImageInfo.image.height / originalImageInfo.image.width;
    if (ratio > axisRatioFlag) {
      imageWidth = (imageContainerWidth - dividerSize) / 2;
      imageHeight = imageWidth * ratio;
    } else {
      imageWidth = imageContainerWidth;
      imageHeight = imageWidth * ratio * 2 + dividerSize;
    }
    double height = imageHeight + headHeight + bottomHeight + padding * 2;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset.zero, Offset(width, height)));

    //绘制背景
    var bgSrcRect = Rect.fromLTWH(0, 0, bgSource.image.width.toDouble(), bgSource.image.height.toDouble());
    var bgDstRect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawImageRect(bgSource.image, bgSrcRect, bgDstRect, Paint());

    var headSrcRect = Rect.fromLTWH(0, 0, bgHeadInfo.image.width.toDouble(), bgHeadInfo.image.height.toDouble());
    var headDstRect = Rect.fromLTWH(dp(8), padding, headWidth, headBgHeight);
    canvas.drawImageRect(bgHeadInfo.image, headSrcRect, headDstRect, Paint());

    var middleSrcRect = Rect.fromLTWH(0, 0, bgMiddleInfo.image.width.toDouble(), bgMiddleInfo.image.height.toDouble());
    var middleHeight = height - headBgHeight - padding * 2 - bottomBgHeight;
    var middleDstRect = Rect.fromLTWH(dp(8), headBgHeight + padding, headWidth, middleHeight);
    canvas.drawImageRect(bgMiddleInfo.image, middleSrcRect, middleDstRect, Paint());

    var bottomSrcRect = Rect.fromLTWH(0, 0, bgBottomInfo.image.width.toDouble(), bgBottomInfo.image.height.toDouble());
    var bottomDstRect = Rect.fromLTWH(dp(8), headBgHeight + padding + middleHeight, headWidth, bottomBgHeight);
    canvas.drawImageRect(bgBottomInfo.image, bottomSrcRect, bottomDstRect, Paint());

    // 绘制标题文本
    var emailPainter = TextPainter(
      text: TextSpan(
          text: userEmail,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: ColorConstant.White,
            fontSize: nameSize,
          )),
      ellipsis: '...',
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
      textWidthBasis: TextWidthBasis.longestLine,
      maxLines: 2,
    )..layout(maxWidth: headWidth);
    emailPainter.paint(canvas, userNamePos);

    //绘制原图
    var originalImageSrcRect = Rect.fromLTWH(0, 0, originalImageInfo.image.width.toDouble(), originalImageInfo.image.height.toDouble());
    var originalImageDstRect = Rect.fromLTWH(dp(25), headHeight, imageWidth, imageWidth * ratio);
    canvas.drawImageRect(originalImageInfo.image, originalImageSrcRect, originalImageDstRect, Paint());

    //绘制结果图
    var resultImageSrcRect = Rect.fromLTWH(0, 0, resultImageInfo.image.width.toDouble(), resultImageInfo.image.height.toDouble());
    Rect resultImageDstRect;
    if (ratio > axisRatioFlag) {
      resultImageDstRect = Rect.fromLTWH(dp(25) + imageWidth + dividerSize, headHeight, imageWidth, imageWidth * ratio);
    } else {
      resultImageDstRect = Rect.fromLTWH(dp(25), headHeight + imageWidth * ratio + dividerSize, imageWidth, imageWidth * ratio);
    }
    canvas.drawImageRect(resultImageInfo.image, resultImageSrcRect, resultImageDstRect, Paint());

    // 绘制箭头
    if (ratio > axisRatioFlag) {
      Rect arrowRightSrcRect = Rect.fromLTWH(0, 0, arrowRightImageInfo.image.width.toDouble(), arrowRightImageInfo.image.height.toDouble());
      Rect arrowRightDstRect = Rect.fromLTWH(dp(20) + imageWidth, headHeight + imageHeight / 2 - dp(10), dp(20), dp(20));
      canvas.drawImageRect(arrowRightImageInfo.image, arrowRightSrcRect, arrowRightDstRect, Paint());
    } else {
      Rect arrowDownSrcRect = Rect.fromLTWH(0, 0, arrowDownImageInfo.image.width.toDouble(), arrowDownImageInfo.image.height.toDouble());
      Rect arrowDownDstRect = Rect.fromLTWH(width / 2 - dp(10), headHeight + imageHeight / 2 - dp(10), dp(20), dp(20));
      canvas.drawImageRect(arrowDownImageInfo.image, arrowDownSrcRect, arrowDownDstRect, Paint());
    }

    // 绘制底部白色块
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(dp(25), height - bottomHeight - padding - dividerSize, imageContainerWidth, dp(90)),
          topLeft: Radius.circular(dp(4)),
          topRight: Radius.circular(dp(4)),
          bottomLeft: Radius.circular(dp(4)),
          bottomRight: Radius.circular(dp(4)),
        ),
        Paint()
          ..color = Color(0x2bffffff)
          ..style = PaintingStyle.fill);

    // 绘制appicon
    double appIconY = height - bottomHeight - padding + dp(5);
    canvas.drawImageRect(
      appIconImageInfo.image,
      Rect.fromLTWH(0, 0, appIconImageInfo.image.width.toDouble(), appIconImageInfo.image.height.toDouble()),
      Rect.fromLTWH(dp(33), appIconY, appIconSize, appIconSize),
      Paint(),
    );
    // 绘制二维码
    double qrCodeY = height - bottomHeight - padding + dp(5);
    canvas.drawImageRect(
      qrCodeImageInfo.image,
      Rect.fromLTWH(0, 0, qrCodeImageInfo.image.width.toDouble(), qrCodeImageInfo.image.height.toDouble()),
      Rect.fromLTWH(width - qrcodeSize - dp(33), qrCodeY, qrcodeSize, qrcodeSize),
      Paint(),
    );

    // 绘制标题文本
    var textPainter = TextPainter(
      text: TextSpan(
          text: "PandoraAi",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: titleSize,
          )),
      ellipsis: '...',
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
      textWidthBasis: TextWidthBasis.longestLine,
      maxLines: 2,
    )..layout(maxWidth: width - dp(74) - appIconSize - qrcodeSize);
    double titleY = height - bottomHeight - padding + dp(8);
    textPainter.paint(canvas, Offset(dp(41) + appIconSize, titleY));

    // 绘制描述文本
    var descPainter = TextPainter(
      text: TextSpan(
          text: "Discover your own anime alter ego!",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.normal,
            color: Colors.white,
            fontSize: descSize,
            height: 1.1,
          )),
      ellipsis: '...',
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
      textWidthBasis: TextWidthBasis.longestLine,
      maxLines: 2,
    )..layout(maxWidth: width - dp(74) - appIconSize - qrcodeSize);
    double descY = height - bottomHeight + dp(20);
    descPainter.paint(canvas, Offset(dp(41) + appIconSize, descY));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final outBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    // var outBytes = await img.toByteData();
    return Uint8List.fromList(outBytes!.buffer.asUint8List().toList());
  }

  Future<bool?> showSaveDialog(BuildContext context, bool isSave) {
    return showModalBottomSheet<bool>(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitleTextWidget(isSave ? S.of(context).metaverse_save_video : S.of(context).metaverse_share_video, ColorConstant.White, FontWeight.normal, $(17))
                  .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                color: Colors.transparent,
              )
                  .intoGestureDetector(onTap: () {
                Navigator.of(context).pop(true);
              }),
              Divider(height: 0.5, color: ColorConstant.EffectGrey).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(25))),
              TitleTextWidget(isSave ? S.of(context).metaverse_save_image : S.of(context).metaverse_share_image, ColorConstant.White, FontWeight.normal, $(17))
                  .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                color: Colors.transparent,
              )
                  .intoGestureDetector(onTap: () {
                Navigator.of(context).pop(false);
              }),
            ],
          ).intoContainer(
              padding: EdgeInsets.only(top: $(15), bottom: $(10) + ScreenUtil.getBottomPadding(context)),
              decoration: BoxDecoration(
                  color: ColorConstant.EffectFunctionGrey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular($(24)),
                    topRight: Radius.circular($(24)),
                  )));
        },
        backgroundColor: Colors.transparent);
  }
}
