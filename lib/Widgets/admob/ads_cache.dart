import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsCache {
  factory AdsCache() => _getInstance();

  static AdsCache get instance => _getInstance();
  static AdsCache? _instance;

  static AdsCache _getInstance() {
    if (_instance == null) {
      _instance = new AdsCache._internal();
    }
    return _instance!;
  }

  late Map<String, _AdsInfo> cacheMap;

  AdsCache._internal() {
    cacheMap = {};
  }

  Ad? getAdsCache(String key) {
    var cache = cacheMap[key];
    if (cache == null) {
      return null;
    } else if (cache.expired()) {
      cache.ad.dispose();
      cacheMap.remove(key);
      return null;
    }
    return cache.ad;
  }

  void putAds(String key, Ad ad) {
    return;
    cacheMap[key] = _AdsInfo(ad: ad, overdueDate: DateTime.now());
  }
}

class _AdsInfo {
  Ad ad;
  DateTime overdueDate;

  _AdsInfo({
    required this.ad,
    required this.overdueDate,
  });

  bool expired() {
    return DateTime.now().isAfter(overdueDate);
  }
}
