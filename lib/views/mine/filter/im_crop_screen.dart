import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/edition/controller/crop_holder.dart';
import 'package:cartoonizer/views/ai/edition/widget/crop_options.dart';
import 'package:cartoonizer/views/mine/filter/Crop.dart';
import 'package:cartoonizer/views/mine/filter/im_cropper.dart';
import 'package:cropperx/cropperx.dart';
import 'package:image/image.dart' as imgLib;

import '../../../Common/importFile.dart';
import '../../../Widgets/app_navigation_bar.dart';
import '../../../Widgets/image/sync_image_provider.dart';
import '../../../images-res.dart';
import '../../ai/edition/image_edition.dart';

typedef OnGetCropPath = void Function(String path);

class ImCropScreen extends StatefulWidget {
  CropConfig cropItem;
  List<CropConfig> items;

  final String filePath;
  final OnGetCropPath onGetCropPath;

  ImCropScreen({
    Key? key,
    required this.items,
    required this.filePath,
    required this.cropItem,
    required this.onGetCropPath,
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

  @override
  void initState() {
    super.initState();
    currentItem = widget.cropItem;
    items = widget.items;
    filePath = widget.filePath;
  }

  Future<String> onSaveImage() async {
    final imageBytes = await Cropper.crop(
      cropperKey: cropperKey,
    );
    File file = File(filePath);
    final File resultfile = getSavePath(filePath);
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
    await resultfile.writeAsBytes(imgLib.encodeJpg(resImage));
    return resultfile.path;
  }

  onUpdateScale(ScaleUpdateDetails details, double ratio) {}

  onEndScale(ScaleEndDetails details, double ratio) {}

  File getSavePath(String path) {
    final name = path.substring(path.lastIndexOf('/') + 1);
    var newPath = "${storageOperator.cropDir.path}${DateTime.now().millisecondsSinceEpoch}$name";
    return File(newPath);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppNavigationBar(
        trailing: Image.asset(Images.ic_edit_submit, width: $(22), height: $(22)).intoGestureDetector(onTap: () async {
          showLoading().whenComplete(() async {
            String path = await onSaveImage();
            hideLoading().whenComplete(() {
              widget.onGetCropPath(path);
              Navigator.of(context).pop();
            });
          });
        }),
      ),
      body: Column(children: [
        Expanded(
          child: Center(
            child: ImCropper(
                cropperKey: cropperKey,
                crop: currentItem,
                filePath: widget.filePath,
                updateSacle: (details, ratio) {
                  onUpdateScale(details, ratio);
                },
                endSacle: (details, ratio) {
                  onEndScale(details, ratio);
                }),
          ),
        ),

        SizedBox(
          height: $(140) + ScreenUtil.getBottomPadding(context),
          child: Column(
            children: [
              ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: $(5)),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  var item = items[index];
                  bool check = item == currentItem;
                  return buildItem(item, context, check).intoContainer(height: $(40), width: $(40), color: Colors.transparent).intoGestureDetector(onTap: () {
                    if (currentItem != item) {
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
        color: Colors.white,
      );
    } else {
      return Text(
        e.title,
        style: TextStyle(color: check ? Colors.white : Colors.grey.shade700),
      );
    }
  }
}
