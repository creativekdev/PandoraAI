import 'dart:convert';

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
  List<EffectModel> dataList = [];

  @override
  void onInit() async {
    super.onInit();
    loadingFromCache();
  }

  updateOriginData(Map<String, List<EffectModel>> originData) {
    originList.clear();
    originData.values.forEach((element) {
      originList.addAll(element);
    });
    refreshDataList();
  }

  refreshDataList() {
    dataList.clear();
    recentList.forEach((element) {
      var pick = originList.pick((t) => t.key == element.key);
      if (pick != null) {
        dataList.add(pick);
      }
    });
    update();
  }

  loadingFromCache() async {
    var string = await SharedPreferencesHelper.getString(
        SharedPreferencesHelper.keyRecentEffects);
    try {
      var json = jsonDecode(string);
      recentList = (json as List<dynamic>)
          .map((e) => RecentEffectModel.fromJson(e))
          .toList();
      refreshDataList();
    } catch (e) {}
  }

  _saveToCache(List<RecentEffectModel> recentList) {
    SharedPreferencesHelper.setString(SharedPreferencesHelper.keyRecentEffects,
        jsonEncode(recentList.map((e) => e.toJson()).toList()));
  }

  onEffectUsed(EffectModel effectModel) {
    var pick = recentList
        .pick((element) => effectModel.key == element.key);
    if (pick != null) {
      pick.lastTime = DateTime.now().millisecond;
      recentList.remove(pick);
    } else {
      pick = RecentEffectModel(
          lastTime: DateTime.now().millisecond, key: effectModel.key);
    }
    recentList.insert(0, pick);
    _saveToCache(recentList);
    refreshDataList();
  }
}
