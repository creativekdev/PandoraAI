import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/views/home_screen.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as im;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> loginBack(BuildContext context) async {
  final box = GetStorage();
  String? login_back_page = box.read('login_back_page');
  if (login_back_page != null) {
    Navigator.popUntil(context, ModalRoute.withName(login_back_page));
    box.remove('login_back_page');
  } else {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: "/HomeScreen"),
          builder: (context) => HomeScreen(),
        ),
      );
    }
  }
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

bool isShowAdsNew() {
  var manager = AppDelegate.instance.getManager<UserManager>();
  if (manager.isNeedLogin) {
    return true;
  }
  var user = manager.user!;
  if (user.userSubscription.containsKey('id') || user.cartoonizeCredit > 0) {
    return false;
  }
  return true;
}

String getFileName(String url) {
  return url.substring(url.lastIndexOf('/') + 1);
}

String getFileType(String fileName) {
  return fileName.substring(fileName.lastIndexOf(".") + 1);
}

Future<bool> mkdirByPath(String path) async {
  return mkdir(Directory(path));
}

Future<bool> mkdir(Directory file) async {
  var bool = await file.exists();
  if (!bool) {
    await file.create();
    return true;
  }
  return true;
}

Future<File> imageCompressAndGetFile(File file) async {
  var length = await file.length();
  if (length < 200 * 1024) {
    return file;
  }

  var quality = 100;
  if (length > 8 * 1024 * 1024) {
    quality = (((2 * 1024 * 1024) / length) * 100).toInt();
  } else if (length > 4 * 1024 * 1024) {
    quality = 50;
  } else if (length > 2 * 1024 * 1024) {
    quality = 60;
  } else if (length > 1 * 1024 * 1024) {
    quality = 70;
  } else if (length > 0.5 * 1024 * 1024) {
    quality = 80;
  }

  var dir = await getTemporaryDirectory();
  var targetPath = dir.absolute.path + "/" + DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
  var imageInfo = await SyncFileImage(file: file).getImage();
  var image = imageInfo.image;
  var shortSide = image.width > image.height ? image.height : image.width;
  File result;
  if (shortSide > 1024) {
    var scale = 1024 / shortSide;
    int width = (image.width * scale).toInt();
    int height = (image.height * scale).toInt();
    result = (await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: width,
      minHeight: height,
      quality: quality,
    ))!;
  } else {
    result = await file.copy(targetPath);
  }
  return result;
}

Future<Uint8List> imageCompressWithList(Uint8List image) async {
  var length = image.length;
  if (length < 200 * 1024) {
    return image;
  }

  var quality = 100;
  if (length > 8 * 1024 * 1024) {
    quality = (((2 * 1024 * 1024) / length) * 100).toInt();
  } else if (length > 4 * 1024 * 1024) {
    quality = 50;
  } else if (length > 2 * 1024 * 1024) {
    quality = 60;
  } else if (length > 1 * 1024 * 1024) {
    quality = 70;
  } else if (length > 0.5 * 1024 * 1024) {
    quality = 80;
  }
  var uint8list = await FlutterImageCompress.compressWithList(
    image,
    quality: quality,
  );
  return Uint8List.fromList(uint8list.toList());
}

Future<File> cropFileToTarget(ui.Image srcImage, Rect rect, String targetPath) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromPoints(Offset.zero, Offset(rect.width, rect.height)));

  final paint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  canvas.drawImageRect(srcImage, rect, Rect.fromLTRB(0, 0, rect.width, rect.height), paint);
  final picture = recorder.endRecording();
  final img = await picture.toImage(rect.width.toInt(), rect.height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  var result = File(targetPath);
  await result.writeAsBytes(Uint8List.fromList(byteData!.buffer.asUint8List().toList()));
  return result;
}

Future<Uint8List> addWaterMark({
  required ui.Image image,
  ui.Image? watermark,
  double widthRate = 0.22,
  double bottomRate = 0.07,
  ui.Image? originalImage,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromPoints(Offset.zero, Offset(image.width.toDouble(), image.height.toDouble())));

  final paint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.fill;

  canvas.drawImage(image, Offset.zero, paint);

  if (originalImage != null) {
    double targetWatermarkWidth = image.width / 5;
    double targetWatermarkHeight = targetWatermarkWidth;

    canvas.drawImageRect(
      originalImage,
      Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()),
      Rect.fromLTWH(
        image.width / 20,
        image.height / 20 * 19 - targetWatermarkHeight,
        targetWatermarkWidth,
        targetWatermarkHeight,
      ),
      paint,
    );
  }
  if (watermark != null) {
    double targetWatermarkWidth = image.width * (1 - widthRate * 2);
    var scale = watermark.width / watermark.height;
    double targetWatermarkHeight = targetWatermarkWidth / scale;

    canvas.drawRect(
      Rect.fromLTWH(
        (image.width - targetWatermarkWidth) / 2 + 7,
        image.height * (1 - bottomRate) - targetWatermarkHeight + 7,
        targetWatermarkWidth - 14,
        targetWatermarkHeight - 14,
      ),
      Paint()
        ..color = Color(0x66000000)
        ..style = PaintingStyle.fill,
    );

    canvas.drawImageRect(
      watermark,
      Rect.fromLTWH(0, 0, watermark.width.toDouble(), watermark.height.toDouble()),
      Rect.fromLTWH(
        (image.width - targetWatermarkWidth) / 2,
        image.height * (1 - bottomRate) - targetWatermarkHeight,
        targetWatermarkWidth,
        targetWatermarkHeight,
      ),
      paint,
    );
  }

  final picture = recorder.endRecording();
  final img = await picture.toImage(image.width, image.height);
  final outBytes = await img.toByteData(format: ui.ImageByteFormat.png);
  // var outBytes = await img.toByteData();
  return Uint8List.fromList(outBytes!.buffer.asUint8List().toList());
}

Future<ui.Image?> createImageFromWidget(Widget widget, {Duration? wait, required Size imageSize}) async {
  var devicePixelRatio = ui.window.devicePixelRatio;
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
  final RenderView renderView = RenderView(
    window: ui.PlatformDispatcher.instance.views.single,
    child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      size: imageSize,
      devicePixelRatio: devicePixelRatio,
    ),
  );

  final PipelineOwner pipelineOwner = PipelineOwner();
  final BuildOwner buildOwner = BuildOwner();

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();
  final RenderObjectToWidgetElement<RenderBox> rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      )).attachToRenderTree(buildOwner);
  if (wait != null) {
    await Future.delayed(wait);
  }
  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();
  final ui.Image image = await repaintBoundary.toImage(pixelRatio: devicePixelRatio);
  return image;
}

///从组件获取位图
///@param: context:组件上下文
///@param: pixelRatio:根据分辨率展示倍图
Future<ui.Image?> getBitmapFromContext(BuildContext context, {double pixelRatio = 1.0}) async {
  try {
    RenderRepaintBoundary boundary = context.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage(pixelRatio: pixelRatio);
    return image;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<void> rateApp() async {
  if (Platform.isIOS) {
    launchURL(Config.getStoreLink(toRate: true));
  } else {
    launchURL(Config.getStoreLink());
  }
}

Future<String> md5File(File file) async {
  var uint8list = await file.readAsBytes();
  var digest = md5.convert(uint8list);
  return hex.encode(digest.bytes);
}
