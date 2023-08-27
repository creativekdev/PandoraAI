import 'dart:io';
import 'dart:ui';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:image/image.dart' as imgLib;

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

  double originRatio = 1;

  imgLib.Image? _shownImage;

  set shownImage(imgLib.Image? value) {
    if (_shownImage == value) {
      return;
    }
    _shownImage = value;
    parent.setShownImage(value);
  }

  imgLib.Image? get shownImage => _shownImage;

  double originSize = 1;

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
    originRatio = libImage.width / libImage.height;
    var targetCoverRect = ImageUtils.getTargetCoverRect(parent.imageContainerSize, Size(libImage.width.toDouble(), libImage.height.toDouble()));
    imgLib.Image resizedImage = imgLib.copyResize(libImage, width: (targetCoverRect.width * 1).toInt(), height: (targetCoverRect.height * 1).toInt());
    originSize = resizedImage.width / libImage.width;
    shownImage = resizedImage;
  }

  update() {
    parent.update();
  }

  dispose() {}

  onResetClick() {}

  Future<String> saveToResult();
}
