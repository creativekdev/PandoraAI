import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/cartoonizer_result_entity.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/transfer/controller/transfer_base_controller.dart';

class CartoonizerController extends TransferBaseController<CartoonizerResultEntity> {
  late CartoonizerApi cartoonizerApi;

  CartoonizerController({
    required super.originalPath,
    required super.itemList,
    super.initKey,
  });

  @override
  String getCategory() {
    return 'cartoonize';
  }

  @override
  void onInit() {
    super.onInit();
    cartoonizerApi = CartoonizerApi().bindController(this);
  }

  @override
  void dispose() {
    cartoonizerApi.unbind();
    super.dispose();
  }

  @override
  List<EffectCategory> buildCategories() {
    var controller = Get.find<EffectDataController>();
    return controller.data?.cartoonize?.children ?? [];
  }

  @override
  Future<TransferResult<CartoonizerResultEntity>?> startTransfer(String imageUrl, String? cachedId, {onFailed, bool needRecord = true}) async {
    if (selectedEffect == null) {
      CommonExtension().showToast('Please select template');
      return null;
    }
    var limitEntity = await api.getCartoonizeLimit();
    if (limitEntity != null) {
      if (limitEntity.usedCount >= limitEntity.dailyLimit) {
        if (AppDelegate.instance.getManager<UserManager>().isNeedLogin) {
          return TransferResult()..type = AccountLimitType.guest;
        } else if (isVip()) {
          return TransferResult()..type = AccountLimitType.vip;
        } else {
          return TransferResult()..type = AccountLimitType.normal;
        }
      }
    }
    var rootPath = cacheManager.storageOperator.recordCartoonizeDir.path;
    var baseEntity = await cartoonizerApi.startTransfer(
      initImage: imageUrl,
      directoryPath: rootPath,
      selectEffect: selectedEffect!,
      onFailed: onFailed,
    );
    if (baseEntity != null) {
      resultMap[selectedEffect!.key] = baseEntity.filePath;
      update();
      if (needRecord) {
        recentController.onEffectUsed(selectedEffect!, original: originFile, imageData: baseEntity.filePath, isVideo: false, hasWatermark: false);
      }
      return TransferResult()..entity = baseEntity;
    } else {
      return null;
    }
  }

  @override
  onGenerateSuccess({required String source,     required String photoType,
    required String style}) {
    Events.facetoonGenerated(style: style, source: source);
  }

  @override
  onSavePhoto({required String photo}) {
    Events.facetoonResultSave(photo: photo);
  }

  @override
  onResultShare({required String source, required String platform, required String photo}) {
    Events.facetoonResultShare(source: source, platform: platform, photo: 'image');
  }

  @override
  String getControllerStyle() {
    return selectedEffect!.key;
  }
}
