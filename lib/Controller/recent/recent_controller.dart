import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent/record_holder.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/views/ai/drawable/widget/drawable.dart';
import 'package:common_utils/common_utils.dart';

///
/// Recent effect data manager
/// @Author: wangyu
/// @Date: 2022/6/7
///
class RecentController extends GetxController {
  late EffectRecordHolder effectRecordHolder;
  late MetaverseHolder metaverseHolder;
  late Txt2imgRecordHolder txt2imgHolder;
  late AIDrawRecordHolder aiDrawHolder;

  List<RecentEffectModel> effectList = [];
  List<RecentMetaverseEntity> metaverseList = [];
  List<RecentGroundEntity> groundList = [];
  List<DrawableRecord> aiDrawList = [];

  List<dynamic> recordList = [];

  @override
  void onInit() async {
    super.onInit();
    effectRecordHolder = EffectRecordHolder();
    metaverseHolder = MetaverseHolder();
    txt2imgHolder = Txt2imgRecordHolder();
    aiDrawHolder = AIDrawRecordHolder();
    loadingFromCache();
  }

  Future<void> loadingFromCache() async {
    effectList = await effectRecordHolder.loadFromCache();
    metaverseList = await metaverseHolder.loadFromCache();
    groundList = await txt2imgHolder.loadFromCache();
    aiDrawList = await aiDrawHolder.loadFromCache();
    sortList();
    update();
  }

  sortList() {
    List<RecentEffectModel> effects = [];
    effectList.forEach((element) {
      effects.addAll(element.itemList
          .filter((t) => !TextUtil.isEmpty(t.imageData) && File(t.imageData ?? '').existsSync())
          .map((e) => RecentEffectModel()
            ..updateDt = element.updateDt
            ..originalPath = element.originalPath
            ..itemList = [e])
          .toList());
    });
    List<RecentMetaverseEntity> metaverses = [];
    metaverseList.forEach((element) {
      metaverses.addAll(element.filePath.filter((t) => !TextUtil.isEmpty(t) && File(t ?? '').existsSync()).map((e) => RecentMetaverseEntity()
        ..updateDt = element.updateDt
        ..originalPath = element.originalPath
        ..filePath = [e]));
    });
    recordList = [...effects, ...metaverses, ...groundList, ...aiDrawList];
    recordList.sort((a1, a2) => a1.updateDt < a2.updateDt ? 1 : -1);
  }

  onEffectUsed(
    EffectItem effectItem, {
    required File original,
    required String imageData,
    required bool isVideo,
    required bool hasWatermark,
  }) async {
    effectRecordHolder.record(
      effectList,
      RecentEffectModel()
        ..itemList = [
          RecentEffectItem()
            ..isVideo = isVideo
            ..imageData = imageData
            ..key = effectItem.key
            ..hasWatermark = hasWatermark
        ]
        ..originalPath = original.path
        ..updateDt = DateTime.now().millisecondsSinceEpoch,
    );
    sortList();
    update();
  }

  onMetaverseUsed(File original, File image) {
    metaverseHolder.record(
      metaverseList,
      RecentMetaverseEntity()
        ..filePath = [image.path]
        ..updateDt = DateTime.now().millisecondsSinceEpoch
        ..originalPath = original.path,
    );
    sortList();
    update();
  }

  onTxt2imgUsed(String filePath, String prompt, String? initPath, String? styleKey, Map<String, dynamic> parameters) {
    txt2imgHolder.record(
      groundList,
      RecentGroundEntity()
        ..filePath = filePath
        ..updateDt = DateTime.now().millisecondsSinceEpoch
        ..styleKey = styleKey
        ..prompt = prompt
        ..parameters = parameters
        ..initImageFilePath = initPath,
    );
    sortList();
    update();
  }

  onAiDrawUsed(DrawableRecord record) {
    record.updateDt = DateTime.now().millisecondsSinceEpoch;
    aiDrawHolder.record(aiDrawList, record);
    sortList();
    update();
  }
}
