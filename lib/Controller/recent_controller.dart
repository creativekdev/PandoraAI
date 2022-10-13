import 'dart:convert';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/EffectModel.dart';

///
/// Recent effect data manager
/// @Author: wangyu
/// @Date: 2022/6/7
///
class RecentController extends GetxController {
  List<RecentEffectModel> recentList = [];
  List<EffectModel> originList = [];
  List<EffectModel> recentModelList = [];
  List<EffectItemListData> dataList = [];
  CacheManager cacheManager = AppDelegate.instance.getManager();

  List<EffectModel> getBuildList() {
    List<EffectModel> result = [];
    for (var value in recentModelList) {
      var pick = result.pick((t) => t.key == value.key);
      if(pick != null) {
        pick.effects.addAll(value.effects);
      } else {
        result.add(value);
      }
    }
    return result;
  }

  @override
  void onInit() async {
    super.onInit();
    loadingFromCache();
  }

  updateOriginData(List<EffectModel> originData) {
    originList.clear();
    originList.addAll(originData);
    refreshDataList();
  }

  refreshDataList() {
    recentModelList.clear();
    List<EffectItemListData> allItemList = [];
    recentList.forEach((element) {
      originList.forEach((effectModel) {
        var items = effectModel.effects.values.toList();
        for (int i = 0; i < items.length; i++) {
          var item = items[i];
          if (item.key == element.key) {
            var copy = EffectModel.fromJson(effectModel.toJson());
            copy.effects = {item.key: item};
            copy.defaultEffect = item.key;
            recentModelList.add(copy);
            allItemList.add(EffectItemListData(key: effectModel.key, pos: i, item: item, uniqueKey: '${effectModel.key}${item.key}'));
          }
        }
      });
    });
    dataList.clear();
    dataList.addAll(allItemList);
    update();
  }

  Future<void> loadingFromCache() async {
    recentList = await _loadingFromCache();
  }

  List<RecentEffectModel> _loadingFromCache() {
    List<RecentEffectModel> result = [];
    var string = cacheManager.getString(CacheManager.keyRecentEffects);
    try {
      var json = jsonDecode(string);
      result = (json as List<dynamic>).map((e) => RecentEffectModel.fromJson(e)).toList();
      refreshDataList();
    } catch (e) {}
    return result;
  }

  _saveToCache(List<RecentEffectModel> recentList) {
    cacheManager.setString(CacheManager.keyRecentEffects, jsonEncode(recentList.map((e) => e.toJson()).toList()));
  }

  onEffectUsed(EffectItem effectItem) {
    var pick = recentList.pick((element) => effectItem.key == element.key);
    if (pick != null) {
      pick.lastTime = DateTime.now().microsecondsSinceEpoch;
      recentList.remove(pick);
    } else {
      pick = RecentEffectModel(lastTime: DateTime.now().millisecond, key: effectItem.key);
    }
    recentList.insert(0, pick);
    _saveToCache(recentList);
    refreshDataList();
  }

  onEffectUsedToCache(EffectItem effectItem) async {
    var newList = await _loadingFromCache();
    var pick = newList.pick((element) => effectItem.key == element.key);
    if (pick != null) {
      pick.lastTime = DateTime.now().millisecond;
      newList.remove(pick);
    } else {
      pick = RecentEffectModel(lastTime: DateTime.now().millisecond, key: effectItem.key);
    }
    newList.insert(0, pick);
    _saveToCache(newList);
  }
}
