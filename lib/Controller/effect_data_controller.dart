import 'dart:math' as math;

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/user/rate_notice_operator.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/enums/effect_tag.dart';
import 'package:common_utils/common_utils.dart';

// dev
// const loopDuration = 30 * second;
// const refreshDuration = 1 * minute;

// prod
const loopDuration = 1 * minute;
const refreshDuration = 30 * minute;

class ChooseTabInfo {
  String title;
  String key;

  ChooseTabInfo({
    required this.title,
    required this.key,
  });
}

class ChooseTitleInfo {
  String title;
  String categoryKey;
  String tabKey;

  ChooseTitleInfo({
    required this.title,
    required this.categoryKey,
    required this.tabKey,
  });
}

class ChooseTabItemInfo {
  EffectItem data;
  String tabKey;
  String categoryKey;
  int categoryIndex;
  int childIndex;

  ChooseTabItemInfo({
    required this.data,
    required this.tabKey,
    required this.categoryKey,
    required this.categoryIndex,
    required this.childIndex,
  });
}

class EffectDataController extends GetxController {
  EffectMap? data = null;
  bool loading = true;
  EffectManager effectManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  int lastRandomTime = 0;
  List<EffectItemListData> randomList = <EffectItemListData>[];
  bool randomTabViewing = false;

  List<ChooseTabInfo> tabList = [];
  List<ChooseTitleInfo> tabTitleList = [];
  List<ChooseTabItemInfo> tabItemList = [];

  List<String> tagList = [];
  String? selectedTag;

  @override
  void onInit() {
    super.onInit();
    lastRandomTime = cacheManager.getInt(CacheManager.effectLastRandomTime);
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
        buildTagList();
        buildChooseDataList();
        buildRandomList();
      }
      EventBusHelper().eventBus.fire(OnHomeConfigGetEvent());
      update();
    });
  }

  buildTagList() {
    tagList.clear();
    var effectList = data!.effectList('template');
    effectList.forEach((effectModel) {
      effectModel.effects.forEach((key, effectItem) {
        for (var tag in effectItem.tagList) {
          var build = EffectTagUtils.build(tag);
          if (build == EffectTag.UNDEFINED && !tagList.contains(tag)) {
            tagList.add(tag);
          }
        }
      });
    });
  }

  buildChooseDataList() {
    tabList.clear();
    tabTitleList.clear();
    tabItemList.clear();
    var keyList = data!.data.keys.toList();
    for (int i = 0; i < keyList.length; i++) {
      var key = keyList[i];
      tabList.add(ChooseTabInfo(title: data!.localeName(key), key: key));
      List<EffectModel> effectList = data!.effectList(key);
      if (key == 'face') {
        // flat tow-level data
        for (int j = 0; j < effectList.length; j++) {
          EffectModel effectModel = effectList[j];
          List<EffectItem> effectItems = effectModel.effects.values.toList();
          for (int k = 0; k < effectItems.length; k++) {
            int categoryIndex = tabTitleList.length;
            tabTitleList.add(ChooseTitleInfo(
              title: effectItems[k].displayName,
              categoryKey: effectModel.key,
              tabKey: key,
            ));
            tabItemList.add(ChooseTabItemInfo(
              data: effectItems[k],
              tabKey: key,
              categoryKey: effectModel.key,
              categoryIndex: categoryIndex,
              childIndex: k,
            ));
          }
        }
      } else {
        //others
        for (int j = 0; j < effectList.length; j++) {
          EffectModel effectModel = effectList[j];
          int categoryIndex = tabTitleList.length;
          tabTitleList.add(ChooseTitleInfo(
            title: effectModel.displayName,
            categoryKey: effectModel.key,
            tabKey: key,
          ));
          List<EffectItem> effectItems = effectModel.effects.values.toList();
          for (int k = 0; k < effectItems.length; k++) {
            tabItemList.add(ChooseTabItemInfo(
              data: effectItems[k],
              tabKey: key,
              categoryKey: effectModel.key,
              categoryIndex: categoryIndex,
              childIndex: k,
            ));
          }
        }
      }
    }
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
    if (currentTime - lastRandomTime < refreshDuration && randomList.isNotEmpty) {
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
      if (value.item?.featured != 0) {
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
    topList.sort((a, b) => b.item!.featured.compareTo(a.item!.featured));
    randomList.addAll(topList);
    randomList.addAll(otherList);
    lastRandomTime = DateTime.now().millisecondsSinceEpoch;
    cacheManager.setInt(CacheManager.effectLastRandomTime, lastRandomTime);
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
