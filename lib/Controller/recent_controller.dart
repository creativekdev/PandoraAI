import 'dart:convert';
import 'dart:math';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/helper/shared_pref.dart';
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
  List<List<EffectItemListData>> dataList = [];

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
    allItemList.forEach((element) {
      if (dataList.isNotEmpty && dataList.last.length < 2) {
        dataList.last.add(element);
      } else {
        dataList.add([element]);
      }
    });
    update();
  }

  loadingFromCache() async {
    var string = await SharedPreferencesHelper.getString(SharedPreferencesHelper.keyRecentEffects);
    try {
      var json = jsonDecode(string);
      recentList = (json as List<dynamic>).map((e) => RecentEffectModel.fromJson(e)).toList();
      refreshDataList();
    } catch (e) {}
  }

  _saveToCache(List<RecentEffectModel> recentList) {
    SharedPreferencesHelper.setString(SharedPreferencesHelper.keyRecentEffects, jsonEncode(recentList.map((e) => e.toJson()).toList()));
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
}
