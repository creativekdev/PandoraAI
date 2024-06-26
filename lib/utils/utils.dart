import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/controller/effect_data_controller.dart';
import 'package:cartoonizer/widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/enums/ad_type.dart';
import 'package:cartoonizer/utils/ref_code_util.dart';
import 'package:cartoonizer/views/home_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as imgLib;
import 'package:photo_manager/photo_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worker_manager/worker_manager.dart';

import '../main.dart';

Future<void> loginBack(BuildContext context) async {
  final box = GetStorage();
  String? login_back_page = box.read('login_back_page');
  if (login_back_page != null) {
    Navigator.popUntil(context, ModalRoute.withName(login_back_page));
    box.remove('login_back_page');
  } else {
    if (Navigator.canPop(context)) {
      var histories = MyApp.routeObserver.routeHistory.reversed.toList();
      for (var i = 0; i < histories.length; i++) {
        String historyName = histories[i].settings.name!;
        if (historyName != '/LoginScreen' && historyName != '/SignupScreen' && historyName != '/SocialSignUpScreen') {
          Navigator.popUntil(context, ModalRoute.withName(historyName));
          break;
        }
      }
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

Future<bool> getConnectionStatus() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return (connectivityResult != ConnectivityResult.none);
}

launchURL(String url, {bool force = false}) async {
  var uri = Uri.parse(url);
  if (force) {
    await launchUrl(uri);
  } else {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

bool isShowAdsNew({required AdType type}) {
  // return false;
  var manager = AppDelegate.instance.getManager<UserManager>();
  bool apiOpen;
  switch (type) {
    case AdType.splash:
      apiOpen = manager.adConfig.splash == 1;
      break;
    case AdType.card:
      apiOpen = manager.adConfig.card == 1;
      break;
    case AdType.processing:
      apiOpen = manager.adConfig.processing == 1;
      break;
    case AdType.UNDEFINED:
      apiOpen = true;
      break;
  }
  if (!apiOpen) {
    return false;
  }
  if (manager.isNeedLogin) {
    return true;
  }
  var user = manager.user!;
  if (user.userSubscription.containsKey('id') || user.cartoonizeCredit > 0) {
    return false;
  }
  return true;
}

bool isVip() {
  UserManager userManager = AppDelegate().getManager();
  if (userManager.isNeedLogin) {
    return false;
  } else {
    if (userManager.user!.userSubscription.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}

String getFileName(String url) {
  return url.substring(url.lastIndexOf('/') + 1);
}

String getFileType(String fileName) {
  if (fileName.contains('?')) {
    fileName = fileName.split('?').first;
  }
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

Future<File> imageCompressAndGetFile(File file, {int imageSize = 512, int maxFileSize = 4 * mb}) async {
  var length = await file.length();
  if (length < 200 * kb) {
    return file;
  }

  var quality = 100;
  if (length > maxFileSize) {
    quality = (((maxFileSize) / length) * 100).toInt();
  }

  CacheManager cacheManager = AppDelegate().getManager();
  var dir = cacheManager.storageOperator.tempDir;
  String fileType = getFileType(file.path);
  var targetPath = dir.absolute.path + DateTime.now().millisecondsSinceEpoch.toString() + ".$fileType";
  var imageInfo = await SyncFileImage(file: file).getImage();
  var image = imageInfo.image;
  var wideSide = max(image.width, image.height);
  File result;
  if (wideSide > imageSize) {
    var scale = imageSize / wideSide;
    int width = (image.width * scale).toInt();
    int height = (image.height * scale).toInt();
    var re = (await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: width,
      minHeight: height,
      quality: quality,
      format: _getFormat(fileType),
    ))!;
    result = File(re.path);
  } else {
    result = await file.copy(targetPath);
  }
  return result;
}

CompressFormat _getFormat(String type) {
  switch (type.toLowerCase()) {
    case 'jpg':
    case 'jpeg':
      return CompressFormat.jpeg;
    case 'png':
      return CompressFormat.png;
    case 'heic':
    case 'heif':
      return CompressFormat.heic;
    case 'webp':
      return CompressFormat.webp;
    default:
      return CompressFormat.png;
  }
}

Future<File> imageCompress(
  File file,
  String targetPath, {
  CompressFormat format = CompressFormat.png,
  bool ignoreSize = false,
  int maxFileSize = 4 * mb,
}) async {
  EffectDataController dataController = Get.find();
  int imageSize = dataController.data?.imageMaxl ?? 512;
  var length = await file.length();
  if (length <= maxFileSize && !ignoreSize) {
    return await file.copy(targetPath);
  }

  var quality = 100;
  if (length > maxFileSize) {
    quality = (((maxFileSize) / length) * 100).toInt();
  }
  var re = (await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    minWidth: imageSize,
    minHeight: imageSize,
    quality: quality,
    format: format,
  ))!;
  return File(re.path);
}

Future<File> imageCompressByte(Uint8List image, String targetPath) async {
  var length = image.length;
  if (length <= 512 * 512) {
    var file = File(targetPath);
    await file.writeAsBytes(image);
    return file;
  }

  var quality = 100;
  if (length > 512 * 512) {
    quality = (((512 * 512) / length) * 100).toInt();
  }
  var uint8list = await FlutterImageCompress.compressWithList(
    image,
    minWidth: 512,
    minHeight: 512,
    quality: quality,
    format: CompressFormat.png,
  );
  var file = File(targetPath);
  await file.writeAsBytes(uint8list);
  return file;
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

// add default color is white
Future<Uint8List> cropFile(ui.Image srcImage, Rect rect, {Color color = Colors.white}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromPoints(Offset.zero, Offset(rect.width, rect.height)));

  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  canvas.drawImageRect(srcImage, rect, Rect.fromLTRB(0, 0, rect.width, rect.height), paint);
  final picture = recorder.endRecording();
  final img = await picture.toImage(rect.width.toInt(), rect.height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<File> cropFileToTarget(ui.Image srcImage, Rect rect, String targetPath) async {
  var byteData = await cropFile(srcImage, rect);
  var result = File(targetPath);
  await result.writeAsBytes(byteData.toList());
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
  Events.rateUs();
  if (Platform.isIOS) {
    launchURL(Config.getStoreLink(toRate: true));
  } else {
    const platform = MethodChannel(PLATFORM_CHANNEL);
    platform.invokeMethod<bool>("openAppStore").then((value) {
      if (value == false) {
        launchURL(Config.getStoreLink());
      }
    });
  }
}

Future<String> md5File(File file) async {
  var uint8list = await file.readAsBytes();
  var digest = md5.convert(uint8list);
  return hex.encode(digest.bytes);
}

String md5Bytes(Uint8List bytes) {
  var digest = md5.convert(bytes);
  return hex.encode(digest.bytes);
}

int faceRatio(Size originalSize, Size faceSize) {
  var oriArea = originalSize.width * originalSize.height;
  var faceArea = faceSize.width * faceSize.height;
  return (oriArea / faceArea).round();
}

Future<File?> heicToImage(AssetEntity media) async {
  var sourceFile = await media.originFile;
  return heicFileToImage(sourceFile);
}

Future<File?> heicFileToImage(File? file) async {
  if (file == null) return null;
  const platform = MethodChannel(PLATFORM_CHANNEL);
  if (Platform.isIOS) {
    final String? outPath = await platform.invokeMethod('heic2jpg', file.path);
    if (outPath == null) {
      return null;
    }
    return File(outPath);
  } else {
    CacheManager cacheManager = AppDelegate().getManager();
    String targetPath = '${cacheManager.storageOperator.tempDir.path}${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bool result = await platform.invokeMethod('heic2jpg', {'path': file.path, 'outPath': targetPath});
    if (result) {
      return File(targetPath);
    } else {
      return null;
    }
  }
}

Future<ui.Image> getImage(File file) async {
  var imageInfo = await SyncFileImage(file: file).getImage();
  var image = imageInfo.image;
  return image;
}

Future<imgLib.Image> getLibImage(ui.Image image) async {
  var byteData = await image.toByteData();
  return Executor().execute(arg1: byteData!.buffer.asUint8List(), arg2: image.width, arg3: image.height, fun3: _buildLibImageFromBytes);
}

imgLib.Image _buildLibImageFromBytes(Uint8List list, int width, int height, TypeSendPort port) {
  return imgLib.Image.fromBytes(width, height, list);
}

Future<ui.Image> getUiImage(imgLib.Image image) async {
  var list = imgLib.encodePng(image);
  var bytes = Uint8List.fromList(list);
  var imageInfo = await SyncMemoryImage(list: bytes).getImage();
  return imageInfo.image;
}

Future<bool> judgeInvitationCode() async {
  var userManager = AppDelegate().getManager<UserManager>();
  if (userManager.isNeedLogin) {
    return false;
  }
  if (userManager.user!.isReferred) {
    return false;
  }
  var cacheManager = AppDelegate().getManager<CacheManager>();
  String? code;
  var data = await Clipboard.getData(Clipboard.kTextPlain);
  code = RefCodeUtils.pickRefCode(data?.text);
  if (code == null) {
    LogUtil.d('inv-code not exist in clipboard', tag: 'clipboard');
  } else {
    LogUtil.d('inv-code detected: $code', tag: 'clipboard');
    cacheManager.setString(CacheManager.lastRefLink, code);
  }
  if (TextUtil.isEmpty(code)) {
    LogUtil.d('clipboard is empty, read from cache', tag: 'clipboard');
    code = cacheManager.getString(CacheManager.lastRefLink);
  }
  if (TextUtil.isEmpty(code)) {
    LogUtil.d('inv-code is null', tag: 'clipboard');
    return false;
  }
  var manager = AppDelegate.instance.getManager<UserManager>();
  if (manager.isNeedLogin) {
    LogUtil.d('user is null', tag: 'clipboard');
    return false;
  }
  if (manager.user!.isReferred) {
    LogUtil.d('user has referred', tag: 'clipboard');
    return false;
  }
  if (manager.user!.referLinks.contains(code)) {
    LogUtil.d('is self inv-code', tag: 'clipboard');
    return false;
  }
  delay(() {
    LogUtil.v('code is $code', tag: 'clipboard');
    EventBusHelper().eventBus.fire(OnNewInvitationCodeReceiveEvent(data: code!));
  }, milliseconds: 500);
  return true;
}

Future<String?> getOsVersion() async {
  String? osVersionName;
  if (Platform.isAndroid) {
    var androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
    osVersionName = androidDeviceInfo.version.sdkInt.toString();
  } else if (Platform.isIOS) {
    var iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
    osVersionName = iosDeviceInfo.systemVersion;
  }
  return osVersionName;
}
