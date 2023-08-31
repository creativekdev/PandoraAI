import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/color_util.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/edition/controller/filters/filters_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/ie_base_holder.dart';
import 'package:cartoonizer/views/mine/filter/im_remove_bg_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image/image.dart' as imgLib;
import 'package:worker_manager/worker_manager.dart';

import '../../../../Common/event_bus_helper.dart';
import '../../../common/background/background_picker.dart';
import '../../../mine/filter/pin_gesture_views.dart';

class RemoveBgConfig {
  File? removedImage;
  BackgroundData? selectData;
  double ratio = 1;
  double scale = 1;
  double dx = 0;
  double dy = 0;

  RemoveBgConfig();

  @override
  String toString() {
    return 'RemoveBgConfig{removedImage: ${removedImage?.path}, selectData: ${selectData?.toString()}, ratio: $ratio, scale: $scale, dx: $dx, dy: $dy}';
  }
}

class RemoveBgHolder extends ImageEditionBaseHolder {
  late RemoveBgConfig config;

  File? get removedImage => config.removedImage;

  set removedImage(File? file) {
    config.removedImage = file;
    update();
  }

  ui.Image? imageUiFront;
  imgLib.Image? imageFront;

  BackgroundData preBackgroundData = BackgroundData();

  late Uint8List personByte;
  GlobalKey globalKey = GlobalKey(); // 保存图片的key
  RxBool isShowSquar = false.obs; // 显示人像的边框

  GlobalKey _personImageKey = GlobalKey();
  Rect borderRect = Rect.fromLTRB(0, 0, 0, 0);

  LoadBgController bgController = Get.put(LoadBgController());

  RemoveBgHolder({required super.parent});

  @override
  Future setOriginFilePath(String? path, {dynamic conf}) async {
    bool needRemove = true;
    if (conf != null) {
      needRemove = conf as bool;
    }
    if (originFilePath == path || !needRemove) {
      return;
    }
    originFilePath = path;
    await initData();
    update();
  }

  @override
  onInit() {
    config = RemoveBgConfig();
  }

  @override
  Future initData() async {
    await super.initData();
    preBackgroundData.color = Colors.transparent;
    preBackgroundData.filePath = null;
    resultFilePath = '';
    removedImage = null;
    config.scale = 1.0;
    config.dx = 0;
    config.dy = 0;
    imageFront = null;
    imageUiFront = null;
    final imageSize = Size(ScreenUtil.screenSize.width, ScreenUtil.screenSize.height - (kNavBarPersistentHeight + ScreenUtil.getStatusBarHeight() + $(140)));
    await Navigator.push(
      Get.context!,
      NoAnimRouter(
        ImRemoveBgScreen(
          bottomPadding: parent.bottomHeight + ScreenUtil.getBottomPadding(Get.context!),
          filePath: originFilePath!,
          imageRatio: shownImage!.width / shownImage!.height,
          imageHeight: shownImage!.height.toDouble(),
          imageWidth: shownImage!.width.toDouble(),
          onGetRemoveBgImage: (String path) async {
            parent.filtersHolder.cropOperator.currentItem = null;
            parent.filtersHolder.cropOperator.cropData = Rect.zero;
            removedImage = File(path);
            var imageInfo = await SyncFileImage(file: removedImage!).getImage();
            config.ratio = imageInfo.image.width / imageInfo.image.height;
            imageUiFront = await getImage(File(path));
            imageFront = await getLibImage(imageUiFront!);
            shownImage = imageFront;
            bgController.setBackgroundData(null, Colors.transparent);
          },
          size: imageSize,
        ),
        // opaque: true,
        settings: RouteSettings(name: "/ImRemoveBgScreen"),
      ),
    );
  }

  onSavedBackground(BackgroundData data, bool isPopMerge) async {
    if (data.color != Colors.transparent) {
      canReset = true;
    }
    if (isPopMerge) {
      preBackgroundData = config.selectData ?? preBackgroundData;
    } else {
      if (data.filePath != null) {
        File backFile = File(data.filePath!);
        bgController.setBackgroundData(backFile, null);
      } else {
        bgController.setBackgroundData(null, rgbaToAbgr(data.color!));
      }
      config.selectData = data;
    }
    delay(() => onProductShowImage());
  }

  ui.Color rgbaToAbgr(ui.Color rgbaColor) {
    int abgrValue = (rgbaColor.alpha << 24) | (rgbaColor.blue << 16) | (rgbaColor.green << 8) | rgbaColor.red;
    return ui.Color(abgrValue);
  }

  ui.Color abgrToRgba(int abgrValue) {
    int alpha = (abgrValue >> 24) & 0xFF;
    int blue = (abgrValue >> 16) & 0xFF;
    int green = (abgrValue >> 8) & 0xFF;
    int red = abgrValue & 0xFF;

    return Color.fromRGBO(red, green, blue, alpha / 255.0);
  }

  onResetClick() async {
    preBackgroundData.color = Colors.transparent;
    preBackgroundData.filePath = null;
    bgController.setBackgroundData(null, Colors.transparent);
    await onSavedBackground(BackgroundData()..color = Colors.transparent, false);
    if (config.scale != 1 || config.dy != 0 || config.dx != 0) {
      config.scale = 1;
      config.dy = 0;
      config.dx = 0;
    }
    EventBusHelper().eventBus.fire(OnResetScaleEvent());
    delay(() => onProductShowImage());
    canReset = false;
  }

  onProductShowImage() async {
    ui.Image? image = await getBitmapFromContext(globalKey.currentContext!, pixelRatio: ScreenUtil.mediaQuery?.devicePixelRatio ?? 3.0);
    if (image != null) {
      shownImage = await getLibImage(image);
    }
  }

  Rect getMaxRealImageRect(int width, int height, imgLib.Image? image) {
    if (image == null) {
      return Rect.zero;
    }
    int minX = width;
    int maxX = 0;
    int minY = height;
    int maxY = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (!isTransparentInLocation(x, y, image)) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }
    double scale = parent.showImageSize.width / width;

    return Rect.fromLTWH(
      minX * scale.toDouble(),
      minY * scale.toDouble(),
      maxX * scale.toDouble() - minX * scale.toDouble(),
      maxY * scale.toDouble() - minY * scale.toDouble(),
    );
  }

  bool isTransparentInLocation(int x, int y, imgLib.Image image) {
    int pixelColor = image.getPixel(x, y);
    int alpha = imgLib.getAlpha(pixelColor);
    return alpha == 0;
  }

  Widget buildShownImage(Size size, Size showSize) {
    // showedSize = showSize;
    borderRect = getMaxRealImageRect(imageFront?.width ?? 0, imageFront?.height ?? 0, imageFront);
    return RepaintBoundary(
      key: globalKey,
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          isShowSquar.value = true;
        },
        onPointerUp: (PointerUpEvent event) {
          isShowSquar.value = false;
        },
        child: ClipRect(
          child: Container(
            width: showSize.width,
            height: showSize.height,
            child: Stack(alignment: Alignment.center, children: [
              LoadBgView(width: showSize.width, height: showSize.height),
              PinGestureView(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Image.file(
                        key: _personImageKey,
                        removedImage!,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Obx(
                      () => isShowSquar.value
                          ? UnconstrainedBox(
                              child: Container(
                                width: showSize.width,
                                height: showSize.height,
                                padding: EdgeInsets.only(top: borderRect.top, left: borderRect.left),
                                child: CustomPaint(
                                  painter: GradientBorderPainter(
                                    width: borderRect.width,
                                    height: borderRect.height,
                                    strokeWidth: $(2),
                                    borderRadius: $(8),
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFE31ECD),
                                        Color(0xFF243CFF),
                                        Color(0xFFE31ECD),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                    )
                  ],
                ),
                scale: config.scale,
                dx: config.dx,
                dy: config.dy,
                onPinEndCallBack: (bool isSelected, double newScale, double newDx, double newDy) {
                  canReset = true;
                  config.scale = newScale;
                  config.dx = newDx;
                  config.dy = newDy;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onProductShowImage(); // 在这里可以执行你想要的操作，因为重建已完成
                  });
                },
              ),
            ]),
          ),
        ),
      ),
    ).intoCenter().intoContainer(width: size.width, height: size.height, alignment: Alignment.center);
  }

  @override
  dispose() {
    Get.delete<LoadBgController>();
    return super.dispose();
  }

  @override
  Future<String> saveToResult({force = false}) async {
    String? waitToDelete = resultFilePath;
    var key = EncryptUtil.encodeMd5('${config.toString()}');
    var newPath = cacheManager.storageOperator.imageDir.path + key + '.png';
    if (newPath == waitToDelete && File(newPath).existsSync()) {
      return newPath;
    } else {
      var list = await new Executor().execute(arg1: shownImage!, fun1: encodePngThread);
      await File(newPath).writeAsBytes(list);
      resultFilePath = newPath;
      return resultFilePath;
    }
  }
}

class GradientBorderPainter extends CustomPainter {
  final double strokeWidth;
  final double borderRadius;
  final Gradient gradient;
  final double width;
  final double height;

  GradientBorderPainter({
    required this.strokeWidth,
    required this.borderRadius,
    required this.gradient,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    size = Size(width, height);
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(borderRadius)));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(Offset.zero & size);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class LoadBgController extends GetxController {
  File? _backgroundImage;
  ui.Color? _backgroundColor;

  setBackgroundData(File? bgImage, ui.Color? bgColor) {
    _backgroundImage = bgImage;
    _backgroundColor = bgColor;
    update();
  }

  File? get backgroundImage => _backgroundImage;

  ui.Color? get backgroundColor => _backgroundColor;
}

class LoadBgView extends StatefulWidget {
  const LoadBgView({Key? key, required this.width, required this.height}) : super(key: key);
  final double width;
  final double height;

  @override
  State<LoadBgView> createState() => _LoadBgViewState();
}

class _LoadBgViewState extends State<LoadBgView> {
  LoadBgController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoadBgController>(
        init: controller,
        builder: (controller) {
          return Container(
            alignment: Alignment.center,
            color: (controller.backgroundColor ?? Colors.transparent).toArgb(),
            child: controller.backgroundImage != null
                ? Image.file(
                    controller.backgroundImage!,
                    fit: BoxFit.cover,
                    width: widget.width,
                    height: widget.height,
                  )
                : SizedBox(),
            width: widget.width,
            height: widget.height,
          );
        });
    ;
  }
}
