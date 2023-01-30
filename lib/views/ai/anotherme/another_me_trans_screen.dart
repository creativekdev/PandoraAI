import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_controller.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/trans_result_card.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';

import 'anotherme.dart';
import 'widgets/am_opt_container.dart';

class AnotherMeTransScreen extends StatefulWidget {
  XFile file;
  double ratio;

  AnotherMeTransScreen({
    Key? key,
    required this.file,
    required this.ratio,
  }) : super(key: key);

  @override
  State<AnotherMeTransScreen> createState() => _AnotherMeTransScreenState();
}

class _AnotherMeTransScreenState extends AppState<AnotherMeTransScreen> {
  late XFile file;
  late double ratio;
  AnotherMeController controller = Get.find();
  UploadImageController uploadImageController = Get.find();
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
    resultCardHeight = ratio > 1 ? (resultCardWidth - dividerSize) / 2 * ratio : resultCardWidth * ratio * 2 + dividerSize;
    file = widget.file;
    delay(() {
      generate(context, controller, true);
    });
  }

  void generate(BuildContext context, AnotherMeController controller, bool needUpload) {
    SimulateProgressBarController simulateProgressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(
      context,
      needUploadProgress: needUpload,
      controller: simulateProgressBarController,
    ).then((value) {
      controller.update();
    });
    if (needUpload) {
      controller.onTakePhoto(file, uploadImageController).then((value) {
        simulateProgressBarController.uploadComplete();
        if (value) {
          controller.startTransfer(uploadImageController.imageUrl.value).then((value) {
            simulateProgressBarController.loadComplete();
          });
        } else {
          simulateProgressBarController.loadComplete();
        }
      });
    } else {
      controller.startTransfer(uploadImageController.imageUrl.value).then((value) {
        simulateProgressBarController.loadComplete();
      });
    }
  }

  @override
  Widget buildWidget(BuildContext context) => GetBuilder<AnotherMeController>(
        init: controller,
        builder: (controller) {
          if (TextUtil.isEmpty(controller.transKey)) {
            return Image.file(
              File(file.path),
              width: ScreenUtil.screenSize.width,
              height: ScreenUtil.screenSize.height,
              fit: BoxFit.contain,
            );
          }
          return Scaffold(
            backgroundColor: ColorConstant.BackgroundColor,
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            child: TransResultNewCard(
                              originalImage: File(file.path),
                              resultImage: File(controller.transKey!),
                              width: resultCardWidth,
                              height: resultCardHeight,
                              direction: ratio > 1 ? Axis.horizontal : Axis.vertical,
                              dividerSize: dividerSize,
                            ),
                            borderRadius: BorderRadius.circular($(12)),
                          ).intoContainer(
                            margin: EdgeInsets.only(right: 16, left: 16, top: $(72), bottom: $(16)),
                          )
                        ],
                      ),
                    ).intoCenter()),
                    AMOptContainer(
                      key: optKey,
                      onChoosePhotoTap: () {
                        optKey.currentState!.dismiss().whenComplete(() {
                          controller.clear(uploadImageController);
                          Navigator.of(context).pop(true);
                        });
                      },
                      onDownloadTap: () async {
                        await showLoading();
                        var uint8list = await printImageData(File(file.path), File(controller.transKey!));
                        var list = uint8list.toList();
                        var path = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
                        var imgPath = path + '${DateTime.now().millisecondsSinceEpoch}.png';
                        await File(imgPath).writeAsBytes(list);
                        await GallerySaver.saveImage(imgPath, albumName: saveAlbumName);
                        await hideLoading();
                        CommonExtension().showImageSavedOkToast(context);
                      },
                      onGenerateAgainTap: () {
                        controller.clearTransKey();
                        generate(context, controller, false);
                      },
                      onShareDiscoveryTap: () async {
                        if (TextUtil.isEmpty(controller.transKey)) {
                          return;
                        }
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
                            showShareResult();
                          }
                        });
                      },
                      onShareTap: () async {
                        await showLoading();
                        if (TextUtil.isEmpty(controller.transKey)) {
                          return;
                        }
                        var uint8list = await printImageData(File(file.path), File(controller.transKey!));
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
                      },
                    ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context, padding: 32)))
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
                  Navigator.pop(context);
                }),
              ],
            ).intoContainer(
                height: ScreenUtil.screenSize.height,
                width: ScreenUtil.screenSize.width,
                decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images.ic_another_me_trans_bg)))),
          );
        },
      );

  void showShareResult() {
    showShareMetaverseSuccessDialog(context).then((value) {
      if (value ?? false) {
        EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.DISCOVERY.id()]));
        Navigator.of(context).pop();
        //todo 这里不用popUntil是因为trans页面和上一级页面是同一个业务逻辑上的页面，
        //todo trans返回时什么也不带就会自动关闭上一级页面，后续需要优化。
      }
    });
  }

  ///375 设计宽度下，对应输出1080宽度下缩放比2.88
  ///appIcon宽度40，二维码宽度68，标题字体17，描述文案字体13
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
    if (ratio > 1) {
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
    if (ratio > 1) {
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
          text: "PandoraAi App",
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
}
