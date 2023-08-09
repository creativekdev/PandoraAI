import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/utils/utils.dart';
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
  CropItem cropItem;

  ImCropScreen({Key? key, required this.filePath, required this.cropItem, required this.onGetCropPath, this.bottomPadding = 0}) : super(key: key);
  final String filePath;
  final OnGetCropPath onGetCropPath;
  final double bottomPadding;

  @override
  State<ImCropScreen> createState() => _ImCropScreenState();
}

class _ImCropScreenState extends AppState<ImCropScreen> with SingleTickerProviderStateMixin {
  final GlobalKey cropperKey = GlobalKey(debugLabel: 'cropperKey');
  GlobalKey cropBackgroundKey = GlobalKey();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late StorageOperator storageOperator = cacheManager.storageOperator;
  late String filePath;

  late AnimationController _animationController;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    filePath = widget.filePath;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = ColorTween(begin: Color(0x00000000), end: ColorConstant.BackgroundColor).animate(_animationController);
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
      targetHeight = (targetWidth / widget.cropItem.config!.ratio).toInt();
    } else {
      targetWidth = (targetHeight * widget.cropItem.config!.ratio).toInt();
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
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: _animation.value,
            appBar: AppNavigationBar(
              backgroundColor: _animation.value!,
              trailing: Image.asset(Images.ic_edit_submit, width: $(22), height: $(22)).intoGestureDetector(onTap: () async {
                showLoading().whenComplete(() async {
                  String path = await onSaveImage();
                  hideLoading().whenComplete(() {
                    widget.onGetCropPath(path);
                    Navigator.of(context).pop();
                  });
                });
              }).hero(tag: ImageEdition.TagAppbarTagTraining),
            ),
            body: Column(children: [
              Expanded(
                child: Center(
                  child: ImCropper(
                      cropperKey: cropperKey,
                      crop: widget.cropItem,
                      filePath: widget.filePath,
                      updateSacle: (details, ratio) {
                        onUpdateScale(details, ratio);
                      },
                      endSacle: (details, ratio) {
                        onEndScale(details, ratio);
                      }).hero(tag: ImageEdition.TagImageEditView),
                ),
              ),
              SizedBox(height: $(55) + ScreenUtil.getBottomPadding(context)),
            ]),
          );
        });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
