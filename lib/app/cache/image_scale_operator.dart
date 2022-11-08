import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:common_utils/common_utils.dart';

class ImageScaleOperator {
  CacheManager cacheManager;

  Map<String, double> _scaleMap = {};

  ImageScaleOperator({required this.cacheManager});

  loadCache() {
    _scaleMap.clear();
    Map map = cacheManager.getJson(CacheManager.imageScaled) ?? {};
    map.forEach((key, value) {
      if (value is String) {
        _scaleMap[key] = double.parse(value);
      } else if (value is double) {
        _scaleMap[key] = value;
      } else {
        _scaleMap[key] = double.parse(value.toString());
      }
    });
  }

  saveCache() {
    cacheManager.setJson(CacheManager.imageScaled, _scaleMap);
  }

  double? getScale(String url) {
    var key = EncryptUtil.encodeMd5(url);
    return _scaleMap[key];
  }

  void setScale(String url, double scale) {
    _scaleMap[EncryptUtil.encodeMd5(url)] = scale;
  }
}
