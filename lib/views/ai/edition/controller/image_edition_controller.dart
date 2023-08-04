import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/views/ai/edition/controller/adjust_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/crop_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/filter_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/remove_bg_holder.dart';
import 'package:cartoonizer/views/transfer/controller/both_transfer_controller.dart';

class ImageEditionController extends GetxController {
  late String _originPath;

  File get originFile => File(_originPath);

  final EffectStyle effectStyle;

  ///----------------------------------------------------------------------------------------

  List<EditionStep> activeSteps = [];
  List<EditionStep> checkmateSteps = [];

  ///----------------------------------------------------------------------------------------
  late EditionItem _currentItem;

  EditionItem get currentItem => _currentItem;

  set currentItem(EditionItem func) {
    _currentItem = func;
    update();
  }

  List<EditionItem> items = [];

  bool _showOrigin = false;

  bool get showOrigin => _showOrigin;

  set showOrigin(bool value) {
    _showOrigin = value;
    update();
  }

  ImageEditionController({
    required String originPath,
    required this.effectStyle,
  }) {
    _originPath = originPath;
  }

  @override
  void onInit() {
    super.onInit();
    var effectHolder = BothTransferController(originalPath: _originPath, itemList: [], style: effectStyle)..onInit();
    effectHolder.parent = this;
    var filterHolder = FilterHolder(parent: this)..onInit();
    var adjustHolder = AdjustHolder(parent: this)..onInit();
    var cropHolder = CropHolder(parent: this)..onInit();
    var removeBgHolder = RemoveBgHolder(parent: this)..onInit();
    items = [
      EditionItem()
        ..function = ImageEditionFunction.effect
        ..holder = effectHolder,
      EditionItem()
        ..function = ImageEditionFunction.filter
        ..holder = filterHolder,
      EditionItem()
        ..function = ImageEditionFunction.adjust
        ..holder = adjustHolder,
      EditionItem()
        ..function = ImageEditionFunction.crop
        ..holder = cropHolder,
      EditionItem()
        ..function = ImageEditionFunction.removeBg
        ..holder = removeBgHolder,
    ];
    currentItem = items.first;
  }

  @override
  void dispose() {
    for (var item in items) {
      item.holder.dispose();
    }
    super.dispose();
  }
}

class EditionStep {}

class EditionItem {
  late ImageEditionFunction function;
  late dynamic holder;

  EditionItem();
}
