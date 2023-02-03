import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent/record_holder.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/recent_entity.dart';

///
/// Recent effect data manager
/// @Author: wangyu
/// @Date: 2022/6/7
///
class RecentController extends GetxController {
  late EffectRecordHolder effectRecordHolder;
  late MetaverseHolder metaverseHolder;

  List<RecentEffectModel> effectList = [];
  List<RecentMetaverseEntity> metaverseList = [];

  List<dynamic> recordList = [];

  @override
  void onInit() async {
    super.onInit();
    effectRecordHolder = EffectRecordHolder();
    metaverseHolder = MetaverseHolder();
    loadingFromCache();
  }

  Future<void> loadingFromCache() async {
    effectList = await effectRecordHolder.loadFromCache();
    metaverseList = await metaverseHolder.loadFromCache();
    sortList();
    update();
  }

  sortList() {
    List<RecentEffectModel> effects = [];
    effectList.forEach((element) {
      effects.addAll(element.itemList
          .map((e) => RecentEffectModel()
            ..updateDt = element.updateDt
            ..originalPath = element.originalPath
            ..itemList = [e])
          .toList());
    });
    List<RecentMetaverseEntity> metaverses = [];
    metaverseList.forEach((element) {
      metaverses.addAll(element.filePath.map((e) => RecentMetaverseEntity()
        ..updateDt = element.updateDt
        ..originalPath = element.originalPath
        ..filePath = [e]));
    });
    recordList = [...effects, ...metaverses];
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
}
