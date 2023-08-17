import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as imgLib;

import 'utils.dart';

typedef Action = Future Function();

class _Loading extends StatelessWidget {
  Action action;

  _Loading({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    action.call().then((value) {
      Navigator.of(context).pop();
    });
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: CircularProgressIndicator().intoCenter(),
    );
  }
}

Future _complete(Completer<String> callback, String path) async {
  delay(() {
    callback.complete(path);
  }, milliseconds: 32);
}

class ImageUtils {
  static Future<String> onImagePick(
    String tempFilePath,
    String targetPath, {
    bool compress = false,
    int size = 512,
  }) async {
    Completer<String> callback = Completer();
    Navigator.of(Get.context!).push(NoAnimRouter(_Loading(action: () async {
      var source = File(tempFilePath);
      var fileName = await md5File(source);
      if (compress) {
        fileName = '$size' + fileName;
      }
      var fileType = getFileType(tempFilePath);
      var path = targetPath + fileName + '.' + fileType;
      if (!File(path).existsSync()) {
        if (compress) {
          var file = await imageCompressAndGetFile(source, imageSize: size, maxFileSize: 8 * mb);
          await file.copy(path);
        } else {
          await source.copy(path);
        }
      }
      _complete(callback, path);
    }), settings: RouteSettings(name: '/_Loading')));
    return callback.future;
  }

  // Calculate the area that the artwork should display based on the target coordinates
  static Rect getTargetCoverRect(Size source, Size target) {
    double sourceScale = source.width / source.height;
    double targetScale = target.width / target.height;
    if (sourceScale > targetScale) {
      //The original image is wider and scaled to the height to take the middle part.
      double width = source.height * targetScale;
      double x = (source.width - width) / 2;
      return Rect.fromLTWH(x, 0, width, source.height);
    } else {
      //The original image is higher, and the middle part is scaled by width.
      double height = source.width / targetScale;
      double y = (source.height - height) / 2;
      return Rect.fromLTWH(0, y, source.width, height);
    }
  }

  // todo 4领域泛洪填充算法，还没有优化好。
  static List<ui.Path> getBoundaries(imgLib.Image image, ui.Offset center) {
    List<ui.Path> result = [];
    var startPixel = image.getPixel(center.dx.toInt(), center.dy.toInt());
    List<PointPos> points = [];

    List<bool> checkMap = List.generate(image.width * image.height, (index) => false);

    /// 获取图像边界
    getPoints(image, center.dx.toInt(), center.dy.toInt(), startPixel, points, checkMap, -1, -1);

    /// 按x轴排序
    points.sort((a, b) => a.x > b.x ? 1 : -1);

    /// 坐标点分成连续闭合的多条Path
    groupBuild(wipeRepeatPoints(points), result);
    return result;
  }

  static void getPoints(imgLib.Image image, int x, int y, int pixel, List<PointPos> points, List<bool> checkMap, int lastX, int lastY) {
    var pixel2 = image.getPixel(x, y);
    if (checkMap[y * image.width + x]) {
      return;
    }
    if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
      if (pixel2 == pixel) {
        getPoints(image, x + 1, y, pixel, points, checkMap, x, y);
        getPoints(image, x - 1, y, pixel, points, checkMap, x, y);
        getPoints(image, x, y + 1, pixel, points, checkMap, x, y);
        getPoints(image, x, y - 1, pixel, points, checkMap, x, y);
        // getPoints(image, x + 1, y + 1, pixel, points, scanList);
        // getPoints(image, x - 1, y - 1, pixel, points, scanList);
        // getPoints(image, x - 1, y + 1, pixel, points, scanList);
        // getPoints(image, x + 1, y - 1, pixel, points, scanList);
      } else {
        points.add(PointPos(x, y));
      }
      checkMap[y * image.width + x] = true;
    }
  }

  static void groupBuild(List<PointPos> points, List<ui.Path> paths) {
    if (points.isEmpty) {
      return;
    }
    List<PointPos> closePath = [];
    getNeighborPoints(closePath, points);
    if (closePath.isNotEmpty) {
      ui.Path path = ui.Path()..moveTo(closePath.first.x.toDouble(), closePath.first.y.toDouble());
      closePath.removeAt(0);
      for (var value in closePath) {
        path.lineTo(value.x.toDouble(), value.y.toDouble());
      }
      path.close();
      paths.add(path);
      groupBuild(points, paths);
    }
  }

  static void getNeighborPoints(List<PointPos> pos, List<PointPos> points) {
    if (points.isEmpty) {
      return;
    }
    if (pos.isEmpty) {
      pos.add(points.removeAt(0));
    }
    PointPos? target;
    for (var value in points) {
      if ((value.x - pos.last.x).abs() <= 1 && (value.y - pos.last.y).abs() <= 1) {
        target = value;
        break;
      }
    }
    if (target != null) {
      pos.add(target);
      points.remove(target);
      getNeighborPoints(pos, points);
    }
  }

  static List<PointPos> wipeRepeatPoints(List<PointPos> points) {
    return points;
    List<PointPos> result = [];
    for (var value in points) {
      if (!result.exist((t) => t == value)) {
        result.add(value);
      }
    }
    return result;
  }

  static double scaleSize = 1080 / 375;
  static const axisRatioFlag = 0.8;

  static double dp(double source) => source * scaleSize;

  static Future<Uint8List> printAiDrawData(File originalImage, File resultImage, String userEmail) async {
    return printImageData(originalImage, resultImage, userEmail, 'AI-Scribble', arrowRes: Images.ic_ai_draw_arrow);
  }

  static Future<Uint8List> printAiColoringData(File originalImage, File resultImage, String userEmail) async {
    return printImageData(originalImage, resultImage, userEmail, 'AI-Coloring', arrowRes: Images.ic_ai_draw_arrow);
  }

  static Future<Uint8List> printStyleMorphDrawData(File originalImage, File resultImage, String userEmail) async {
    return printImageData(originalImage, resultImage, userEmail, 'StyleMorph', arrowRes: Images.ic_ai_draw_arrow);
  }

  static Future<Uint8List> printCartoonizeDrawData(File originalImage, File resultImage, String userEmail) async {
    return printImageData(originalImage, resultImage, userEmail, 'Cartoonize', arrowRes: Images.ic_ai_draw_arrow);
  }

  static Future<Uint8List> printAnotherMeData(File originalImage, File resultImage, String userEmail) async {
    return printImageData(originalImage, resultImage, userEmail, 'Me-taverse');
  }

  ///375 设计宽度下，对应输出1080宽度下缩放比2.88
  ///appIcon宽度64，二维码宽度64，标题字体17，描述文案字体13
  ///底部app推广高度105
  static Future<Uint8List> printImageData(dynamic originalImage, File resultImage, String userEmail, String functionName, {String? arrowRes}) async {
    var bgSource = await SyncAssetImage(assets: Images.ic_another_me_trans_bg).getImage();
    var bgHeadInfo = await SyncAssetImage(assets: Images.ic_compare_top).getImage();
    var bgHeadArrowInfo = await SyncAssetImage(assets: Images.ic_compare_arrow).getImage();
    var bgMiddleInfo = await SyncAssetImage(assets: Images.ic_mt_result_middle).getImage();
    var bgBottomInfo = await SyncAssetImage(assets: Images.ic_mt_result_bottom).getImage();
    ImageInfo originalImageInfo;
    if (originalImage is File) {
      originalImageInfo = await SyncFileImage(file: originalImage).getImage();
    } else if (originalImage is Uint8List) {
      originalImageInfo = await SyncMemoryImage(list: originalImage).getImage();
    } else {
      throw Exception('wrong originalImage type');
    }
    var resultImageInfo = await SyncFileImage(file: resultImage).getImage();
    var appIconImageInfo = await SyncAssetImage(assets: Images.ic_app).getImage();
    var qrCodeImageInfo = await SyncAssetImage(assets: Images.ic_app_qrcode).getImage();
    var arrowRightImageInfo = await SyncAssetImage(assets: arrowRes ?? Images.ic_another_arrow_right).getImage();
    var arrowDownImageInfo = await SyncAssetImage(assets: Images.ic_another_arrow_down).getImage();

    double width = dp(375);
    double headWidth = dp(360);
    double headBgHeight = headWidth * bgHeadInfo.image.height / bgHeadInfo.image.width;
    Offset functionPos = Offset(dp(25), dp(28));
    Offset userNamePos = Offset(dp(25), dp(65));
    double headHeight = dp(100);
    double bottomBgHeight = headWidth * bgBottomInfo.image.height / bgBottomInfo.image.width;
    double bottomHeight = dp(105);

    double imageContainerWidth = dp(324);

    double appIconSize = dp(64);
    double qrcodeSize = dp(64);
    double functionSize = dp(32);
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

    var functionPainter = TextPainter(
      text: TextSpan(
          text: functionName,
          style: TextStyle(
            fontFamily: 'BlackOpsOne',
            fontWeight: FontWeight.normal,
            color: ColorConstant.White,
            fontSize: functionSize,
          )),
      ellipsis: '...',
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
      textWidthBasis: TextWidthBasis.longestLine,
      maxLines: 2,
    )..layout(maxWidth: headWidth);
    functionPainter.paint(canvas, functionPos);

    var arrowImageSrcRect = Rect.fromLTWH(0, 0, bgHeadArrowInfo.image.width.toDouble(), bgHeadArrowInfo.image.height.toDouble());
    var arrowImageDstRect = Rect.fromLTWH(dp(33) + functionPainter.width, dp(40), dp(42), $(46));
    canvas.drawImageRect(bgHeadArrowInfo.image, arrowImageSrcRect, arrowImageDstRect, Paint());

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
}

CompressFormat _buildCompressFormat(String type) {
  switch (type.toLowerCase()) {
    case 'png':
      return CompressFormat.png;
    case 'jpg':
    case 'jpeg':
      return CompressFormat.jpeg;
    case 'webp':
      return CompressFormat.webp;
    case 'heic':
      return CompressFormat.heic;
    default:
      return CompressFormat.png;
  }
}

class PointPos {
  int x = 0;
  int y = 0;

  PointPos(this.x, this.y);

  operator ==(Object object) {
    if (object is PointPos) {
      return object.x == x && object.y == y;
    } else {
      return false;
    }
  }
}
