import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/views/ai/edition/controller/adjust_controller.dart';
import 'package:cartoonizer/views/ai/edition/controller/filter_controller.dart';
import 'package:cartoonizer/views/transfer/controller/both_transfer_controller.dart';

class ImageEditionController extends GetxController {
  late String _originPath;

  File get originFile => File(_originPath);

  ///----------------------------------------------------------------------------------------
  String? _resultFilePath;

  String? get resultFilePath => _resultFilePath;

  set resultFilePath(String? path) {
    _resultFilePath = path;
    update();
  }

  File? get resultFile => resultFilePath == null ? null : File(resultFilePath!);

  ///----------------------------------------------------------------------------------------

  String? _removedBgPath;

  String? get removedBgPath => _removedBgPath;

  set removedBgPath(String? path) {
    _removedBgPath = path;
    update();
  }

  File? get removedBgFile => _removedBgPath == null ? null : File(removedBgPath!);

  ///----------------------------------------------------------------------------------------

  String? _cropFilePath;

  String? get cropFilePath => _cropFilePath;

  set cropFilePath(String? path) {
    _cropFilePath = path;
    update();
  }

  File? get cropFile => _cropFilePath == null ? null : File(_cropFilePath!);

  ///----------------------------------------------------------------------------------------

  List<EditionStep> activeSteps = [];
  List<EditionStep> checkmateSteps = [];

  ///----------------------------------------------------------------------------------------
  late BothTransferController effectController;
  final EffectStyle effectStyle;
  late FilterController filterController;
  late AdjustController adjustController;

  ///----------------------------------------------------------------------------------------
  ImageEditionFunction _currentFunction = ImageEditionFunction.effect;

  ImageEditionFunction get currentFunction => _currentFunction;

  set currentFunction(ImageEditionFunction func) {
    _currentFunction = func;
    update();
  }

  List<ImageEditionFunction> functions = [
    ImageEditionFunction.effect,
    ImageEditionFunction.filter,
    ImageEditionFunction.adjust,
    ImageEditionFunction.crop,
    ImageEditionFunction.removeBg,
  ];

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
    effectController = BothTransferController(originalPath: _originPath, itemList: [], style: effectStyle);
    effectController.onInit();
    filterController = FilterController();
    filterController.onInit();
    adjustController = AdjustController();
    adjustController.onInit();
  }

  @override
  void dispose() {
    effectController.dispose();
    filterController.dispose();
    adjustController.dispose();
    super.dispose();
  }
}

class EditionStep {}
