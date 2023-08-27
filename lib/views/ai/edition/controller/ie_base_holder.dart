import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/views/ai/edition/controller/filter_holder.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image/image.dart' as imgLib;
import 'package:worker_manager/worker_manager.dart';

import '../../../../utils/utils.dart';
import 'image_edition_controller.dart';

abstract class ImageEditionBaseHolder {
  late ImageEditionController parent;
  CacheManager cacheManager = AppDelegate().getManager();

  String? originFilePath;

  Future setOriginFilePath(String? path) async {
    if (originFilePath == path) {
      return;
    }
    originFilePath = path;
    await initData();
    update();
  }

  File? get originFile => originFilePath == null ? null : File(originFilePath!);

  String? resultFilePath;

  imgLib.Image? _shownImage;

  set shownImage(imgLib.Image? value) {
    if (_shownImage == value) {
      return;
    }
    _shownImage = value;
    parent.setShownImage(value);
  }

  imgLib.Image? get shownImage => _shownImage;

  bool _canReset = false;

  bool get canReset => _canReset;

  set canReset(bool value) {
    if (_canReset == value) {
      return;
    }
    _canReset = value;
    update();
  }

  ///------------------------------------------------------------------------------------
  ImageEditionBaseHolder({required this.parent});

  onInit() {}

  Future initData() async {
    var libImage = await getLibImage(await getImage(originFile!));
    var targetCoverRect = ImageUtils.getTargetCoverRect(parent.showImageSize, Size(libImage.width.toDouble(), libImage.height.toDouble()));
    imgLib.Image resizedImage = imgLib.copyResize(libImage, width: (targetCoverRect.width * 1.2).toInt(), height: (targetCoverRect.height * 1.2).toInt());
    shownImage = resizedImage;
  }

  update() {
    parent.update();
  }

  dispose() {}

  onResetClick() {}

  Future onSwitchImage(imgLib.Image image);

  Future saveToResult() async {
    String? waitToDelete = resultFilePath;
    if (shownImage == null) {
      resultFilePath = null;
    } else {
      var list = await new Executor().execute(arg1: shownImage!, fun1: encodePng);
      var uint8list = Uint8List.fromList(list);
      var key = md5Bytes(uint8list);
      var newPath = cacheManager.storageOperator.imageDir.path + key + '.png';
      if (newPath == waitToDelete) {
        return;
      } else {
        await File(newPath).writeAsBytes(uint8list);
        resultFilePath = newPath;
        if (!TextUtil.isEmpty(waitToDelete)) {
          File(waitToDelete!).exists().then((value) {
            if (value) {
              File(waitToDelete).delete();
            }
          });
        }
      }
    }
  }
}
