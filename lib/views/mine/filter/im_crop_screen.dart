import 'dart:io';

import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/views/mine/filter/Crop.dart';
import 'package:cartoonizer/views/mine/filter/im_cropper.dart';
import 'package:cropperx/cropperx.dart';

import '../../../Common/importFile.dart';
import '../../../Widgets/app_navigation_bar.dart';
import '../../../images-res.dart';

typedef OnGetCropPath = void Function(String path);

class ImCropScreen extends StatefulWidget {
  CropItem cropItem;

  ImCropScreen({Key? key, required this.filePath, required this.cropItem, required this.onGetCropPath}) : super(key: key);
  final String filePath;
  final OnGetCropPath onGetCropPath;

  @override
  State<ImCropScreen> createState() => _ImCropScreenState();
}

class _ImCropScreenState extends AppState<ImCropScreen> {
  final GlobalKey cropperKey = GlobalKey(debugLabel: 'cropperKey');
  GlobalKey cropBackgroundKey = GlobalKey();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late StorageOperator storageOperator = cacheManager.storageOperator;
  late String filePath;

  @override
  void initState() {
    super.initState();
    filePath = widget.filePath;
  }

  Future<String> onSaveImage() async {
    final imageBytes = await Cropper.crop(
      cropperKey: cropperKey,
      pixelRatio: 1,
    );
    final File file = getSavePath(filePath);
    await file.writeAsBytes(imageBytes!);
    return file.path;
  }

  onUpdateScale(ScaleUpdateDetails details, double ratio) {}

  onEndScale(ScaleEndDetails details, double ratio) {}

  File getSavePath(String path) {
    final name = path.substring(path.lastIndexOf('/') + 1);
    var newPath = "${storageOperator.cropDir.path}/${DateTime.now().millisecondsSinceEpoch}$name";
    return File(newPath);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xdd000000),
      appBar: AppNavigationBar(
        backgroundColor: Color(0xdd000000),
        trailing: Image.asset(Images.ic_confirm, width: $(30), height: $(30)).intoGestureDetector(onTap: () async {
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
                crop: widget.cropItem,
                filePath: widget.filePath,
                updateSacle: (details, ratio) {
                  onUpdateScale(details, ratio);
                },
                endSacle: (details, ratio) {
                  onEndScale(details, ratio);
                }),
          ),
        ),
        SizedBox(height: $(55) + ScreenUtil.getBottomPadding(context)),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
