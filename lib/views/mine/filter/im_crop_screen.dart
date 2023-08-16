import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/edition/controller/crop_holder.dart';
import 'package:cropperx/cropperx.dart';
import 'package:image/image.dart' as imgLib;

import '../../../Common/importFile.dart';
import '../../../Widgets/app_navigation_bar.dart';
import '../../../Widgets/image/sync_image_provider.dart';
import '../../../images-res.dart';

typedef OnGetCrop = void Function(imgLib.Image image);

class ImCropScreen extends StatefulWidget {
  CropConfig cropItem;
  List<CropConfig> items;

  final String filePath;
  final OnGetCrop onGetCrop;
  double originalRatio;

  ImCropScreen({
    Key? key,
    required this.items,
    required this.filePath,
    required this.cropItem,
    required this.onGetCrop,
    required this.originalRatio,
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

  @override
  void initState() {
    super.initState();
    currentItem = widget.cropItem;
    items = widget.items;
    filePath = widget.filePath;
    image = Image.file(File(filePath), fit: BoxFit.fill);
  }

  Future<imgLib.Image> onSaveImage() async {
    final imageBytes = await Cropper.crop(
      cropperKey: cropperKey,
    );
    File file = File(filePath);
    if (currentItem.width == -1) {
      return await getLibImage(await getImage(file));
    } else {
      SyncFileImage syncFileImage = SyncFileImage(file: file);
      ui.Image originImage = (await syncFileImage.getImage()).image;
      SyncMemoryImage memoryImage = SyncMemoryImage(list: imageBytes!);
      ui.Image cropImage = (await memoryImage.getImage()).image;
      imgLib.Image image = await getLibImage(cropImage);
      int targetWidth = originImage.width;
      int targetHeight = originImage.height;
      if (targetWidth > targetHeight) {
        targetHeight = targetWidth ~/ widget.cropItem.ratio;
      } else {
        targetWidth = (targetHeight * widget.cropItem.ratio).toInt();
      }
      imgLib.Image resImage = imgLib.copyResize(image, width: targetWidth, height: targetHeight);
      return resImage;
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppNavigationBar(
        trailing: Image.asset(Images.ic_edit_submit, width: $(22), height: $(22)).intoGestureDetector(onTap: () async {
          showLoading().whenComplete(() async {
            var image = await onSaveImage();
            hideLoading().whenComplete(() {
              widget.onGetCrop(image);
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
                height: $(140),
              )
            ],
          ),
          Column(children: [
            Expanded(
              child: Center(
                child: Cropper(
                  key: key,
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
                  setState(() {
                    this.size = size;
                  });
                }),
              ),
            ),
            SizedBox(
              height: $(140),
              child: Column(
                children: [
                  SizedBox(height: $(15)),
                  ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: $(5)),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      var item = items[index];
                      bool check = item == currentItem;
                      return buildItem(item, context, check).intoContainer(height: $(40), width: $(40), color: Colors.transparent).intoGestureDetector(onTap: () {
                        if (currentItem != item) {
                          key = UniqueKey();
                          setState(() {
                            currentItem = item;
                          });
                        }
                      }).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(5)));
                    },
                    itemCount: items.length,
                  ).intoContainer(height: $(40)),
                ],
              ),
            ),
          ]),
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular($(32)),
            border: Border.all(
              color: check ? Colors.white : Colors.grey.shade800,
              width: 1,
            ),
          ),
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
                  color: Colors.grey.shade800,
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
      return Icon(
        Icons.fullscreen,
        size: $(18),
        color: check ? Colors.white : Colors.grey.shade700,
      );
    } else {
      return Text(
        e.title,
        style: TextStyle(color: check ? Colors.white : Colors.grey.shade700),
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
