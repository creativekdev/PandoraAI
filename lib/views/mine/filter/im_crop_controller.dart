import 'dart:io';

import 'package:cropperx/cropperx.dart';

import '../../../Common/importFile.dart';
import '../../../app/app.dart';
import '../../../app/cache/cache_manager.dart';
import '../../../app/cache/storage_operator.dart';
import 'Crop.dart';

class ImCropController extends GetxController {
  late String filePath;
  Crop crop = new Crop();
  final GlobalKey cropperKey = GlobalKey(debugLabel: 'cropperKey');
  GlobalKey cropBackgroundKey = GlobalKey();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late StorageOperator storageOperator = cacheManager.storageOperator;

  Future<String> onSaveImage() async {
    final imageBytes = await Cropper.crop(
      cropperKey: cropperKey,
    );
    final File file = getSavePath(filePath);
    await file.writeAsBytes(imageBytes!);
    return file.path;
  }

  onUpdateScale(ScaleUpdateDetails details, double ratio) {}

  onEndScale(ScaleEndDetails details, double ratio) {}

  File getSavePath(String path) {
    final name = path.substring(path.lastIndexOf('/') + 1);
    var newPath = "${storageOperator.cropDir.path}$name";
    return File(newPath);
  }
}
