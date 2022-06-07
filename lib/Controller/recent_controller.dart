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

  @override
  void onInit() async {
    super.onInit();
    loadingFromCache();
  }

  loadingFromCache() async {
    var string = await SharedPreferencesHelper.getString(
        SharedPreferencesHelper.keyRecentEffects);
    try {
      var json = jsonDecode(string);
      recentList = (json as List<dynamic>)
          .map((e) => RecentEffectModel.fromJson(e))
          .toList();
      update();
    } catch (e) {}
  }

  _saveToCache(List<RecentEffectModel> recentList) {
    SharedPreferencesHelper.setString(SharedPreferencesHelper.keyRecentEffects,
        jsonEncode(recentList.map((e) => e.toJson()).toList()));
  }

  onEffectUsed(EffectModel effectModel) {
    var first = recentList.firstWhereOrNull((element) =>
        effectModel.key == element.effectModel.key &&
        effectModel.display_name == element.effectModel.display_name);
    if (first != null) {
      first.lastTime = DateTime.now().millisecond;
      recentList.remove(first);
    } else {
      first = RecentEffectModel(
          lastTime: DateTime.now().millisecond, effectModel: effectModel);
    }
    recentList.insert(0, first);
    _saveToCache(recentList);
    update();
  }
}
