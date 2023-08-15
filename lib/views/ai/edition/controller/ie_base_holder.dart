import 'dart:io';

import 'package:cartoonizer/Widgets/background_card.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:image/image.dart' as imgLib;

import '../../../../Widgets/lib_image_widget/lib_image_widget.dart';
import '../../../../utils/utils.dart';
import 'image_edition_controller.dart';

abstract class ImageEditionBaseHolder {
  late ImageEditionController parent;

  Widget? shownImageWidget;

  String? originFilePath;

  setOriginFilePath(String? path) {
    if (originFilePath == path) {
      return;
    }
    originFilePath = path;
    initData();
    update();
  }

  File? get originFile => originFilePath == null ? null : File(originFilePath!);

  ///------------------------------------------------------------------------------------

  String? _resultFilePath;

  set resultFilePath(String? path) {
    if (_resultFilePath == path) {
      return;
    }
    _resultFilePath = path;
    update();
  }

  File? get resultFile => _resultFilePath == null ? null : File(_resultFilePath!);

  // ui.Image? _shownUIImage;
  // set shownUIImage(ui.Image? value) {
  //   shownUIImage = value;
  //   update();
  // }
  // ui.Image? get shownImage => _shownUIImage;

  imgLib.Image? _shownImage;

  set shownImage(imgLib.Image? value) {
    shownImage = value;
    update();
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

  initData() {
    getImage(originFile!).then((value) {
      getLibImage(value).then((value) {
        shownImage = value;
      });
    });
  }

  update() {
    parent.update();
  }

  dispose() {}

  onResetClick() {}

  Widget buildShownImage() {
    if (shownImage == null) {
      return CustomPaint(
          painter: BackgroundPainter(
            bgColor: Colors.transparent,
            w: 10,
            h: 10,
          ),
          child: Image.file(resultFile ?? originFile!));
    }
    return LibImageWidget(controller: parent.libImageWidgetController, shownImage: shownImage!);
  }
}
