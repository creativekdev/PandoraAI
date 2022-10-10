import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/effect_map.dart';

class EffectManager extends BaseManager {
  EffectMap? _data = null;
  late CacheManager cacheManager;
  late CartoonizerApi api;

  @override
  Future<void> onCreate() async {
    super.onCreate();
    api = CartoonizerApi().bindManager(this);
  }

  @override
  Future<void> onAllManagerCreate() async {
    cacheManager = getManager();
    var json = cacheManager.getJson(CacheManager.effectAllData);
    if(json != null) {
      _data = EffectMap.fromJson(json);
    }
    loadData();
  }

  @override
  Future<void> onDestroy() async {
    super.onDestroy();
    api.unbind();
  }

  Future<EffectMap?> loadData() async {
    var data = await api.getHomeConfig();
    if (data != null) {
      _data = data;
      cacheManager.setJson(CacheManager.effectAllData, data.toJson());
    }
    return _data;
  }
}
