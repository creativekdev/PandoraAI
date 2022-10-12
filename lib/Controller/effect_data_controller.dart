import 'dart:math' as math;

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/user/rate_notice_operator.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/effect_map.dart';

// dev
// const loopDuration = 30 * second;
// const refreshDuration = 1 * minute;

// prod
const loopDuration = 1 * minute;
const refreshDuration = 30 * minute;

typedef ItemRender = Widget Function();

class EffectDataController extends GetxController {
  EffectMap? data = null;
  bool loading = true;
  EffectManager effectManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  int lastRandomTime = 0;
  RxList<EffectItemListData> randomList = <EffectItemListData>[].obs;
  bool randomTabViewing = false;

  @override
  void onInit() {
    super.onInit();
    lastRandomTime = cacheManager.getInt(CacheManager.effectLastRandomTime);
    List<dynamic>? json = cacheManager.getJson(CacheManager.effectLastRandomList);
    if (json != null) {
      randomList.value = json.map((e) => EffectItemListData.fromJson(e)).toList();
    }
    loopRefreshData();
  }

  loopRefreshData() {
    buildRandomList();
    delay(() => loopRefreshData(), milliseconds: loopDuration);
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  loadData() {
    effectManager.loadData().then((value) {
      loading = false;
      if (value != null) {
        this.data = value;
        buildRandomList();
      }
      update();
    });
  }

  /// if old list not equals new list -> rebuild
  /// if time duration great than a half hour -> rebuild
  /// delay reload page when user is checking random list
  buildRandomList() {
    if (data == null) {
      return;
    }
    var forward = () {
      data!.data.forEach((key, value) {
        if (key == 'template') {
          refreshRandomList(flatApiRandomList(key));
        }
      });
    };
    if (randomList.isEmpty) {
      forward.call();
      return;
    }
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - lastRandomTime < refreshDuration) {
      return;
    }
    if (randomTabViewing) {
      return;
    }
    delay(() => forward.call(), milliseconds: 1000);
  }

  /// get flat random effect list
  List<EffectItemListData> flatApiRandomList(String key) {
    List<EffectModel> effectList = data!.effectList(key);
    List<EffectItemListData> allItemList = [];
    for (var value in effectList) {
      var items = value.effects.values.toList();
      for (int i = 0; i < items.length; i++) {
        allItemList.add(EffectItemListData(
          key: value.key,
          uniqueKey: '${value.key}${items[i].key}',
          pos: i,
          item: items[i],
        ));
      }
    }
    return allItemList;
  }

  changeRandomTabViewing(bool state) {
    this.randomTabViewing = state;
  }

  refreshRandomList(List<EffectItemListData> allItemList) {
    List<EffectItemListData> topList = [];
    List<EffectItemListData> otherList = [];
    for (int i = 0; i < allItemList.length; i++) {
      var value = allItemList[i];
      if (value.item?.top ?? false) {
        topList.add(value);
      } else {
        if (i == 0) {
          otherList.add(value);
        } else {
          otherList.insert(math.Random().nextInt(otherList.length), value);
        }
      }
    }
    randomList.clear();
    randomList.addAll(topList);
    randomList.addAll(otherList);
    lastRandomTime = DateTime.now().millisecondsSinceEpoch;
    cacheManager.setInt(CacheManager.effectLastRandomTime, lastRandomTime);
    cacheManager.setJson(CacheManager.effectLastRandomList, randomList.map((e) => e.toJson()).toList());
  }
}

class HomeTabConfig {
  String title;
  Widget item;
  GlobalKey<AppTabState> key;
  String tabString;

  HomeTabConfig({
    required this.key,
    required this.item,
    required this.title,
    required this.tabString,
  });
}
