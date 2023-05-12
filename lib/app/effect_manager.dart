import 'dart:convert';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/home_card_entity.dart';

class EffectManager extends BaseManager {
  EffectMap? _data = null;
  late CacheManager cacheManager;
  late CartoonizerApi api;
  late Map<String, double> _scaleCachedMap = {};
  Map<String, bool> nsfwStateMap = {};
  bool loaded = false;

  @override
  Future<void> onCreate() async {
    super.onCreate();
    api = CartoonizerApi.quickResponse().bindManager(this);
  }

  @override
  Future<void> onAllManagerCreate() async {
    cacheManager = getManager();
    var scaleCacheJson = cacheManager.getJson(CacheManager.scaleCacheData);
    if (scaleCacheJson == null) {
      _scaleCachedMap = <String, double>{};
    } else {
      (scaleCacheJson as Map).forEach((key, value) {
        _scaleCachedMap[key] = double.parse(value.toString());
      });
    }
    var json = cacheManager.getJson(CacheManager.effectAllData);
    if (json != null) {
      _data = EffectMap.fromJson(json);
    }
  }

  @override
  Future<void> onDestroy() async {
    super.onDestroy();
    api.unbind();
  }

  Future<EffectMap?> loadData({bool ignoreCache = false}) async {
    if (ignoreCache || !loaded) {
      var data = await api.getHomeConfig();
      if (data != null) {
        _data = data;
        loaded = true;
        nsfwStateMap.clear();
        for (var value in data.allEffectList()) {
          value.effects.forEach((key, effect) {
            if (effect.nsfw) {
              nsfwStateMap[effect.key] = true;
            }
          });
        }
        EventBusHelper().eventBus.fire(OnEffectNsfwChangeEvent());
        cacheManager.setJson(CacheManager.effectAllData, data.toJson());
      }
    }
    return _data;
  }

  bool effectNsfw(String key) {
    return nsfwStateMap[key] ?? false;
  }

  double? scale(String url) {
    return _scaleCachedMap[url];
  }

  void setScale(String url, double scale) {
    _scaleCachedMap[url] = scale;
    saveScale();
  }

  void saveScale() {
    cacheManager.setJson(CacheManager.scaleCacheData, _scaleCachedMap);
  }
}
