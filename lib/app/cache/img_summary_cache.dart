import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:common_utils/common_utils.dart';

class ImgSummaryCache {
  CacheManager cacheManager;
  Map<String, dynamic> map = {};

  ImgSummaryCache({required this.cacheManager});

  init() {
    map = cacheManager.getJson(CacheManager.cacheImageSummary) ?? {};
  }

  double? getScale({required String url}) {
    return map[EncryptUtil.encodeMd5(url)] as double?;
  }

  setScale({required String url, required double scale}) {
    map[EncryptUtil.encodeMd5(url)] = scale;
    cacheManager.setJson(CacheManager.cacheImageSummary, map);
  }
}
