import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Widgets/image/sync_download_image.dart';
import 'package:cartoonizer/Widgets/image/sync_download_video.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/ai_server_entity.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/utils/utils.dart';

class EffectManager extends BaseManager {
  ApiConfigEntity? _data = null;
  ApiConfigEntity? get data => _data;
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
      _data = ApiConfigEntity.fromJson(json);
    }
  }

  @override
  Future<void> onDestroy() async {
    super.onDestroy();
    api.unbind();
  }

  Future<ApiConfigEntity?> loadData({bool ignoreCache = false}) async {
    if (ignoreCache || !loaded) {
      var data = await api.getHomeConfig();
      if (data != null) {
        _data = data;
        loaded = true;
        nsfwStateMap.clear();
        data.datas.forEach((tabs) {
          tabs.children.forEach((category) {
            category.effects.forEach((effect) {
              if (effect.isNsfw) {
                nsfwStateMap[effect.key] = true;
              }
            });
          });
        });
        //download metagram resources
        _data!.promotionResources.forEach((element) {
          if (element.type == 'image') {
            SyncDownloadImage(type: getFileType(element.url ?? ''), url: element.url ?? '').getImage();
          } else if (element.type == 'video') {
            SyncDownloadVideo(type: getFileType(element.url ?? ''), url: element.url ?? '').getVideo();
          }
        });
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
