import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/models/effect_map.dart';

class EffectManager extends BaseManager {
  EffectMap? _data = null;
  late CartoonizerApi api;

  @override
  Future<void> onCreate() async {
    super.onCreate();
    api = CartoonizerApi().bindManager(this);
  }

  @override
  Future<void> onAllManagerCreate() async {
    loadData();
  }

  @override
  Future<void> onDestroy() async {
    super.onDestroy();
    api.unbind();
  }

  Future<EffectMap?> loadData() async {
    if (_data != null) {
      return _data;
    }
    var data = await api.getHomeConfig();
    // var data = await API.getHomeConfig();
    if (data != null) {
      _data = data;
    }
    return data;
  }
}
