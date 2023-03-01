import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
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
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';

import 'anotherme.dart';
import 'trans_result_anim_screen.dart';
import 'widgets/am_opt_container.dart';
import 'widgets/trans_result_video_build_dialog.dart';

const axisRatioFlag = 0.8;

class AnotherMeTransScreen extends StatefulWidget {
  File file;
  double ratio;
  File? resultFile;

  AnotherMeTransScreen({
    Key? key,
    required this.file,
    required this.ratio,
    this.resultFile,
  }) : super(key: key);

  @override
  State<AnotherMeTransScreen> createState() => _AnotherMeTransScreenState();
}

class _AnotherMeTransScreenState extends AppState<AnotherMeTransScreen> {
  late File file;
  late double ratio;
  AnotherMeController controller = Get.find();
  UploadImageController uploadImageController = Get.find();
  RecentController recentController = Get.find();
  GlobalKey<AMOptContainerState> optKey = GlobalKey();
  late double resultCardWidth;
  late double resultCardHeight;
  late double dividerSize;
  File? transResult;

  @override
  void initState() {
    super.initState();
    ratio = widget.ratio;
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

  void generate(BuildContext _context, AnotherMeController controller) async {
    var key = await md5File(file);
    var needUpload = await uploadImageController.needUploadByKey(key);
    SimulateProgressBarController simulateProgressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(
      _context,
      needUploadProgress: needUpload,
      controller: simulateProgressBarController,
    ).then((value) {
      if (value ?? false) {
        controller.onSuccess();
        setState(() {
          showAnim(context);
        });
      } else {
        controller.onError();
      }
    });
    controller.onTakePhoto(file, uploadImageController, key).then((value) {
      simulateProgressBarController.uploadComplete();
      if (value) {
        uploadImageController.getCachedIdByKey(key).then((cachedId) {
          controller.startTransfer(uploadImageController.imageUrl.value, cachedId).then((value) {
            if (value != null) {
              uploadImageController.updateCachedId(file, value.cacheId ?? '');
              var image = File(controller.transKey!);
              recentController.onMetaverseUsed(file, image);
              transResult = image;
              simulateProgressBarController.loadComplete();
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
                              var uint8list = await printImageData(file, File(controller.transKey!));
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
                        AppDelegate.instance.getManager<UserManager>().doOnLogin(context,
                            logPreLoginAction: 'share_discovery_from_metaverse',
                            callback: () {
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
                                  ShareScreen.startShare(
                                    context,
                                    backgroundColor: Color(0x77000000),
                                    style: 'Me-taverse',
                                    image: value,
                                    isVideo: true,
                                    originalUrl: null,
                                    effectKey: 'Me-taverse',
                                  );
                                  AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
                                }
                              });
                            } else {
                              await showLoading();
                              if (TextUtil.isEmpty(controller.transKey)) {
                                return;
                              }
                              var uint8list = await printImageData(file, File(controller.transKey!));
                              AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
                              await hideLoading();
                              ShareScreen.startShare(
                                context,
                                backgroundColor: Color(0x77000000),
                                style: 'Me-taverse',
                                image: base64Encode(uint8list),
                                isVideo: false,
                                originalUrl: null,
                                effectKey: 'Me-taverse',
                              );
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
                decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images.ic_another_me_trans_bg)))),
          );
        },
      ),
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      });

  ///375 设计宽度下，对应输出1080宽度下缩放比2.88
  ///appIcon宽度64，二维码宽度64，标题字体17，描述文案字体13
  ///底部app推广高度105
  Future<Uint8List> printImageData(File originalImage, File resultImage) async {
    double scaleSize = 2.88; //1080/375;
    var originalImageInfo = await SyncFileImage(file: originalImage).getImage();
    var resultImageInfo = await SyncFileImage(file: resultImage).getImage();
    var appIconImageInfo = await SyncAssetImage(assets: Images.ic_app).getImage();
    var qrCodeImageInfo = await SyncAssetImage(assets: Images.ic_app_qrcode).getImage();
    double appIconSize = 64 * scaleSize; //40*scaleSize
    double qrcodeSize = 64 * scaleSize;
    double titleSize = 17 * scaleSize;
    double descSize = 13 * scaleSize;
    double width = 1080;
    double dividerSize = 8 * scaleSize;
    double padding = 16 * scaleSize;
    double bottomSize = 105 * scaleSize;
    var imageWidth;
    var imageHeight;
    var ratio = originalImageInfo.image.height / originalImageInfo.image.width;
    if (ratio > axisRatioFlag) {
      imageWidth = (width - dividerSize - padding * 2) / 2;
      imageHeight = imageWidth * ratio;
    } else {
      imageWidth = width - padding * 2;
      imageHeight = imageWidth * ratio * 2 + dividerSize;
    }
    double height = imageHeight + padding * 2 + bottomSize; //105*2.88
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset.zero, Offset(width, height)));
    //绘制背景渐变色
    Paint colorfulPaint = Paint();
    var colorfulRect = Rect.fromLTWH(0, 0, width, imageHeight + padding * 2);
    colorfulPaint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF04F1F9),
        Color(0xFF7F97F3),
        Color(0xFFEC5DD8),
      ],
    ).createShader(colorfulRect);
    canvas.drawRect(colorfulRect, colorfulPaint);

    //绘制原图
    var originalImageSrcRect = Rect.fromLTWH(0, 0, originalImageInfo.image.width.toDouble(), originalImageInfo.image.height.toDouble());
    var originalImageDstRect = Rect.fromLTWH(padding, padding, imageWidth, imageWidth * ratio);
    canvas.drawImageRect(originalImageInfo.image, originalImageSrcRect, originalImageDstRect, Paint());

    //绘制结果图
    var resultImageSrcRect = Rect.fromLTWH(0, 0, resultImageInfo.image.width.toDouble(), resultImageInfo.image.height.toDouble());
    Rect resultImageDstRect;
    if (ratio > axisRatioFlag) {
      resultImageDstRect = Rect.fromLTWH(padding + imageWidth + dividerSize, padding, imageWidth, imageWidth * ratio);
    } else {
      resultImageDstRect = Rect.fromLTWH(padding, padding + imageWidth * ratio + dividerSize, imageWidth, imageWidth * ratio);
    }
    canvas.drawImageRect(resultImageInfo.image, resultImageSrcRect, resultImageDstRect, Paint());

    // 绘制底部白色块
    canvas.drawRect(
        Rect.fromLTWH(0, height - bottomSize, width, bottomSize),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);

    // 绘制appicon
    double appIconY = height - bottomSize + 21 * scaleSize;
    canvas.drawImageRect(
      appIconImageInfo.image,
      Rect.fromLTWH(0, 0, appIconImageInfo.image.width.toDouble(), appIconImageInfo.image.height.toDouble()),
      Rect.fromLTWH(padding, appIconY, appIconSize, appIconSize),
      Paint(),
    );
    // 绘制二维码
    double qrCodeY = height - bottomSize + 16 * scaleSize;
    canvas.drawImageRect(
      qrCodeImageInfo.image,
      Rect.fromLTWH(0, 0, qrCodeImageInfo.image.width.toDouble(), qrCodeImageInfo.image.height.toDouble()),
      Rect.fromLTWH(width - padding - qrcodeSize, qrCodeY, qrcodeSize, qrcodeSize),
      Paint(),
    );

    // 绘制标题文本
    var textPainter = TextPainter(
      text: TextSpan(
          text: "PandoraAi",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Color(0xff323232),
            fontSize: titleSize,
          )),
      ellipsis: '...',
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
      textWidthBasis: TextWidthBasis.longestLine,
      maxLines: 2,
    )..layout(maxWidth: width - padding * 2 - appIconSize - qrcodeSize - 8 * scaleSize);
    double titleY = height - bottomSize + 18 * scaleSize;
    textPainter.paint(canvas, Offset(padding + 8 * scaleSize + appIconSize, titleY));

    // 绘制描述文本
    var descPainter = TextPainter(
      text: TextSpan(
          text: "Discover your own anime alter ego!",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.normal,
            color: Color(0xff323232),
            fontSize: descSize,
            height: 1.1,
          )),
      ellipsis: '...',
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
      textWidthBasis: TextWidthBasis.longestLine,
      maxLines: 2,
    )..layout(maxWidth: width - padding * 2 - appIconSize - qrcodeSize - 24 * scaleSize);
    double descY = height - bottomSize + 50 * scaleSize;
    descPainter.paint(canvas, Offset(padding + 8 * scaleSize + appIconSize, descY));

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
