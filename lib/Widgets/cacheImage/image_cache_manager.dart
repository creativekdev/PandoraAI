import 'package:flutter_cache_manager/flutter_cache_manager.dart';

///
/// @Author: wangyu
/// @Date: 2022/6/6
///
class CachedImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'CachedImageCacheData';

  static final CachedImageCacheManager _instance = CachedImageCacheManager._();

  factory CachedImageCacheManager() {
    return _instance;
  }

  CachedImageCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 180),
          maxNrOfCacheObjects: 100,
        ));
}
