import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/views/ai/edition/controller/image_edition_controller.dart';
import 'package:cartoonizer/views/mine/filter/im_effect_screen.dart';
import 'package:cartoonizer/views/transfer/controller/style_morph_controller.dart';
import 'package:cartoonizer/views/transfer/controller/transfer_base_controller.dart';

import 'cartoonizer_controller.dart';

enum EffectStyle { Cartoonizer, StyleMorph, All }

class BothTransferController extends TransferBaseController {
  late CartoonizerController cartoonizerController;
  late StyleMorphController styleMorphController;
  EffectStyle style;

  ImageEditionController? parent;

  @override
  update([List<Object>? ids, bool condition = true]) {
    super.update(ids, condition);
    parent?.update();
  }

  BothTransferController({
    required super.originalPath,
    required super.itemList,
    super.initKey,
    required this.style,
  });

  @override
  List<EffectCategory> buildCategories() {
    var controller = Get.find<EffectDataController>();
    switch (style) {
      case EffectStyle.Cartoonizer:
        return controller.data?.cartoonize?.children ?? [];
      case EffectStyle.StyleMorph:
        return controller.data?.stylemorph?.children ?? [];
      case EffectStyle.All:
        return [...controller.data?.cartoonize?.children ?? [], ...controller.data?.stylemorph?.children ?? []];
    }
  }

  @override
  void onInit() {
    super.onInit();
    cartoonizerController = CartoonizerController(originalPath: originalPath, itemList: [], initKey: initKey);
    cartoonizerController.onInit();
    styleMorphController = StyleMorphController(originalPath: originalPath, itemList: [], initKey: initKey);
    styleMorphController.onInit();
  }

  @override
  String getCategory() {
    return selectedTitle?.category ?? 'image_edition';
  }

  @override
  String getControllerStyle() {
    return selectedEffect!.key;
  }

  @override
  void onTitleSelected(int index) {
    super.onTitleSelected(index);
    if (selectedTitle?.category == 'cartoonize') {
      cartoonizerController.onTitleSelected(index);
    } else if (selectedTitle?.category == 'stylemorph') {
      styleMorphController.onTitleSelected(index - cartoonizerController.categories.length);
    }
  }

  @override
  void onItemSelected(int index) {
    super.onItemSelected(index);
    if (selectedTitle?.category == 'cartoonize') {
      cartoonizerController.onItemSelected(index);
    } else if (selectedTitle?.category == 'stylemorph') {
      styleMorphController.onItemSelected(index);
    }
  }

  @override
  onGenerateSuccess({required String source, required String photoType, required String style}) {
    if (selectedTitle?.category == 'cartoonize') {
      cartoonizerController.onGenerateSuccess(source: source, photoType: photoType, style: style);
    } else if (selectedTitle?.category == 'stylemorph') {
      styleMorphController.onGenerateSuccess(source: source, photoType: photoType, style: style);
    }
  }

  @override
  onResultShare({required String source, required String platform, required String photo}) {
    if (selectedTitle?.category == 'cartoonize') {
      cartoonizerController.onResultShare(source: source, platform: platform, photo: photo);
    } else if (selectedTitle?.category == 'stylemorph') {
      styleMorphController.onResultShare(source: source, platform: platform, photo: photo);
    }
  }

  @override
  onSavePhoto({required String photo}) {
    if (selectedTitle?.category == 'cartoonize') {
      cartoonizerController.onSavePhoto(photo: photo);
    } else if (selectedTitle?.category == 'stylemorph') {
      styleMorphController.onSavePhoto(photo: photo);
    }
  }

  @override
  Future<TransferResult?> startTransfer(String imageUrl, String? cachedId, {onFailed, bool needRecord = true}) async {
    TransferResult? result;
    if (selectedTitle?.category == 'cartoonize') {
      result = await cartoonizerController.startTransfer(imageUrl, cachedId, onFailed: onFailed, needRecord: false);
    } else if (selectedTitle?.category == 'stylemorph') {
      result = await styleMorphController.startTransfer(imageUrl, cachedId, onFailed: onFailed, needRecord: false);
    } else {
      return null;
    }
    if (result?.entity != null) {
      resultMap[selectedEffect!.key] = result!.entity!.filePath;
      update();
    }
    return result;
  }
}
