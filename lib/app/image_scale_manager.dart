import 'package:cartoonizer/app/app.dart';

class ImageScaleManager extends BaseManager {
  late Map<String, double> scaleCachedMap = {};

  clear() {
    scaleCachedMap.clear();
  }

  double? getScale(String url) {
    return scaleCachedMap[url];
  }

  setScale(String url, double scale) {
    scaleCachedMap[url] = scale;
  }
}
