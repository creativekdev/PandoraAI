import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/edition/controller/crop_holder.dart';
import 'package:cropperx/cropperx.dart';
import 'package:image/image.dart' as imgLib;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../Common/importFile.dart';
import '../../../Widgets/app_navigation_bar.dart';
import '../../../Widgets/image/sync_image_provider.dart';
import '../../../images-res.dart';

typedef OnGetCrop = void Function(imgLib.Image image, CropConfig item);
typedef OnScrollChanged = void Function(double scrollPixel);

class ImCropScreen extends StatefulWidget {
  CropConfig cropItem;
  List<CropConfig> items;

  final String filePath;
  final OnGetCrop onGetCrop;
  final OnScrollChanged onScrollChanged;
  double originalRatio;
  double initScrollPixels;

  ImCropScreen({
    Key? key,
    required this.items,
    required this.filePath,
    required this.cropItem,
    required this.onGetCrop,
    required this.onScrollChanged,
    required this.originalRatio,
    required this.initScrollPixels,
  }) : super(key: key);

  @override
  State<ImCropScreen> createState() => _ImCropScreenState();
}

class _ImCropScreenState extends AppState<ImCropScreen> {
  final GlobalKey cropperKey = GlobalKey(debugLabel: 'cropperKey');
  GlobalKey cropBackgroundKey = GlobalKey();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late StorageOperator storageOperator = cacheManager.storageOperator;
  late String filePath;

  late List<CropConfig> items;
  late CropConfig currentItem;

  late Image image;

  Key key = UniqueKey();
  Size? size;
  Rx<bool> switching = false.obs;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    currentItem = widget.cropItem;
    items = widget.items;
    filePath = widget.filePath;
    image = Image.file(File(filePath), fit: BoxFit.fill);
    scrollController = ScrollController(initialScrollOffset: widget.initScrollPixels);
  }

  double getScrollPixels() {
    if (scrollController.positions.isEmpty) {
      return 0;
    }
    return scrollController.position.pixels;
  }

  @override
  dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<imgLib.Image> onSaveImage() async {
    final imageBytes = await Cropper.crop(
      cropperKey: cropperKey,
    );
    File file = File(filePath);
    SyncFileImage syncFileImage = SyncFileImage(file: file);
    ui.Image originImage = (await syncFileImage.getImage()).image;
    SyncMemoryImage memoryImage = SyncMemoryImage(list: imageBytes!);
    ui.Image cropImage = (await memoryImage.getImage()).image;
    imgLib.Image image = await getLibImage(cropImage);
    int targetWidth = originImage.width;
    int targetHeight = originImage.height;
    if (currentItem.width != -1) {
      if (targetWidth > targetHeight) {
        targetHeight = targetWidth ~/ currentItem.ratio;
      } else {
        targetWidth = (targetHeight * currentItem.ratio).toInt();
      }
    }
    imgLib.Image resImage = imgLib.copyResize(image, width: targetWidth, height: targetHeight);
    return resImage;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppNavigationBar(
        backAction: () {
          widget.onScrollChanged.call(getScrollPixels());
          Navigator.of(context).pop();
        },
        trailing: Image.asset(Images.ic_edit_submit, width: $(22), height: $(22))
            .intoContainer(
          padding: EdgeInsets.all($(8)),
          color: Colors.transparent,
        )
            .intoGestureDetector(onTap: () async {
          showLoading().whenComplete(() async {
            var image = await onSaveImage();
            hideLoading().whenComplete(() {
              widget.onGetCrop(image, currentItem);
              widget.onScrollChanged.call(getScrollPixels());
              Navigator.of(context).pop();
            });
          });
        }),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  child: Center(
                child: size != null
                    ? CustomPaint(
                        painter: BorderPainter(),
                        child: SizedBox.fromSize(
                          size: size!,
                        ),
                      )
                    : Container(),
              )),
              SizedBox(
                height: $(140) + ScreenUtil.getBottomPadding(context),
              )
            ],
          ),
          Column(children: [
            Expanded(
              child: Center(
                child: Cropper(
                  key: UniqueKey(),
                  backgroundColor: Colors.transparent,
                  overlayColor: Colors.white,
                  gridLineThickness: 1,
                  cropperKey: cropperKey,
                  overlayType: OverlayType.grid,
                  rotationTurns: 0,
                  aspectRatio: currentItem.width == -1 ? widget.originalRatio : currentItem.ratio,
                  image: image,
                )
                    .intoContainer(
                      decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1)),
                    )
                    .intoContainer(padding: EdgeInsets.all(2))
                    .listenSizeChanged(onSizeChanged: (size) {
                  safeSetState(() {
                    this.size = size;
                  });
                }),
              ),
            ),
            SizedBox(
              height: $(140) + ScreenUtil.getBottomPadding(context),
              child: Column(
                children: [
                  SizedBox(height: $(15)),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: <Color>[
                          Color(0x11ffffff),
                          Color(0x99ffffff),
                          Color(0xffffffff),
                          Color(0x99ffffff),
                          Color(0x11ffffff),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        tileMode: TileMode.mirror,
                      ).createShader(bounds);
                    },
                    child: Row(
                      children: [
                        SizedBox(width: $(15)),
                        buildItem(items.first, context, items.first == currentItem).intoContainer(height: $(44), width: $(44), color: Colors.transparent).intoGestureDetector(
                            onTap: () {
                          switching.value = true;
                          safeSetState(() {
                            key = UniqueKey();
                            currentItem = items.first;
                          });
                          delay(() => switching.value = false, milliseconds: 200);
                        }).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(8))),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.only(right: $(15)),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, pos) {
                              var index = pos + 1;
                              var item = items[index];
                              bool check = item == currentItem;
                              return buildItem(item, context, check).intoContainer(height: $(44), width: $(44), color: Colors.transparent).intoGestureDetector(onTap: () {
                                switching.value = true;
                                safeSetState(() {
                                  key = UniqueKey();
                                  currentItem = item;
                                });
                                delay(() => switching.value = false, milliseconds: 200);
                              }).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(8)));
                            },
                            itemCount: items.length - 1,
                          ),
                        ),
                      ],
                    ).intoContainer(height: $(44)),
                  ),
                ],
              ),
            ),
          ]),
          Obx(() => Column(
                children: [
                  Expanded(
                    child: Container(
                      color: ColorConstant.BackgroundColor,
                    ),
                  ),
                  SizedBox(
                    height: $(140) + ScreenUtil.getBottomPadding(context),
                  )
                ],
              ).visibility(visible: switching.value)),
        ],
        fit: StackFit.expand,
      ),
    );
  }

  Widget buildItem(CropConfig e, BuildContext context, bool check) {
    double width = $(18);
    double height = $(18);
    if (e.width != -1) {
      width = $(40) * (e.width / (e.width + e.height));
      height = $(40) * (e.height / (e.width + e.height));
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        AppCircleProgressBar(
          size: $(44),
          backgroundColor: Color(0xffa2a2a2).withOpacity(0.3),
          progress: check ? 1 : 0,
          ringWidth: 1.4,
          loadingColors: [
            Color(0xFFE31ECD),
            Color(0xFF243CFF),
            Color(0xFFE31ECD),
          ],
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($(4)),
                border: Border.all(
                  style: BorderStyle.solid,
                  color: Color(0xffa2a2a2).withOpacity(0.3),
                  width: 1,
                )),
          ),
        ),
        Align(
          child: buildIcon(e, context, check),
          alignment: Alignment.center,
        ),
      ],
    );
  }

  Widget buildIcon(CropConfig e, BuildContext context, bool check) {
    if (e.width == -1) {
      return Image.asset(
        Images.ic_crop_original,
        width: $(16),
        color: Colors.white,
      );
    } else {
      return Text(
        e.title,
        style: TextStyle(
          color: Colors.white,
          fontSize: $(12),
        ),
      );
    }
  }
}

class BorderPainter extends CustomPainter {
  var mPaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.square;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(1, 1), Offset(30, 1), mPaint);
    canvas.drawLine(Offset(size.width / 2 - 15, 1), Offset(size.width / 2 + 15, 1), mPaint);
    canvas.drawLine(Offset(size.width - 30, 1), Offset(size.width, 1), mPaint);
    canvas.drawLine(Offset(1, size.height - 1), Offset(30, size.height - 1), mPaint);
    canvas.drawLine(Offset(size.width / 2 - 15, size.height - 1), Offset(size.width / 2 + 15, size.height - 1), mPaint);
    canvas.drawLine(Offset(size.width - 30, size.height - 1), Offset(size.width, size.height - 1), mPaint);
    canvas.drawLine(Offset(1, 1), Offset(1, 30), mPaint);
    canvas.drawLine(Offset(1, size.height / 2 - 15), Offset(1, size.height / 2 + 15), mPaint);
    canvas.drawLine(Offset(1, size.height - 30), Offset(1, size.height), mPaint);
    canvas.drawLine(Offset(size.width - 1, 1), Offset(size.width - 1, 30), mPaint);
    canvas.drawLine(Offset(size.width - 1, size.height / 2 - 15), Offset(size.width - 1, size.height / 2 + 15), mPaint);
    canvas.drawLine(Offset(size.width - 1, size.height - 30), Offset(size.width - 1, size.height), mPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
