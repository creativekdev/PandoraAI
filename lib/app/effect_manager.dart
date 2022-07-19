import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/models/effect_map.dart';

class EffectManager extends BaseManager {
  EffectMap? _data = null;

  @override
  Future<void> onAllManagerCreate() async {
    loadData();
  }

  Future<EffectMap?> loadData() async {
    if (_data != null) {
      return _data;
    }
    var data = await API.getHomeConfig();
    if (data != null) {
      _data = data;
    }
    return data;
  }


}
