import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/enums/ad_type.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_holder.dart';

///
/// @Author: wangyu
/// @Date: 2022/7/7
class CardAdsHolder extends WidgetAdsHolder {
  AdManagerBannerAd? _bannerAd;
  double scale = 0.75;
  bool _isLoaded = false;
  AdSize? _adSize;
  Function? onUpdated;
  AdWidget? adWidget;
  late String adId;
  final double width;
  double? height;
  bool autoHeight;
  int maxRetryCount = 3;

  CardAdsHolder({
    String? key,
    required this.width,
    this.onUpdated, // call widget to call setState
    this.scale = 0.6, // widget's height / width
    required this.adId,
    this.height,
    this.autoHeight = false, // while height was provided, scale will be ignored.
  }) : super(key: key);

  @override
  initHolder() {
    if (!isShowAdsNew(type: AdType.card)) {
      return;
    }
    loadAd();
  }

  @override
  onReady() {
    super.onReady();
    onUpdated?.call();
  }

  @override
  onReset() {
    super.onReset();
    onUpdated?.call();
  }

  Future<void> loadAd() async {
    if (cache.getAdsCache(key) != null) {
      _bannerAd = cache.getAdsCache(key) as AdManagerBannerAd;
      _adSize = await _bannerAd!.getPlatformAdSize();
      _isLoaded = true;
      onReady();
      return;
    }
    await _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;

    AdSize adSize;
    // AdSize size = AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(_adWidth.truncate());
    if (height == null) {
      if (autoHeight) {
        adSize = AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(width.truncate());
      } else {
        height = width * scale;
        adSize = AdSize(width: width.toInt(), height: height!.toInt());
      }
    } else {
      adSize = AdSize(width: width.toInt(), height: height!.toInt());
    }
    await AdManagerBannerAd(
            adUnitId: adId,
            sizes: [adSize],
            listener: AdManagerBannerAdListener(onAdLoaded: (Ad ad) async {
              print('Inline adaptive banner loaded: ${ad.responseInfo?.responseId}');
              AdManagerBannerAd bannerAd = (ad as AdManagerBannerAd);
              final AdSize? size = await bannerAd.getPlatformAdSize();
              if (size == null) {
                print('Error: getPlatformAdSize() returned null for $bannerAd');
                return;
              }
              cache.putAds(key, bannerAd);
              _bannerAd = bannerAd;
              _isLoaded = true;
              _adSize = size;
              var mediationAdapterClassName = _bannerAd?.responseInfo?.mediationAdapterClassName;
              if (!TextUtil.isEmpty(mediationAdapterClassName)) {
                logEvent(Events.admob_source_data, eventValues: {
                  'id': _bannerAd?.responseInfo?.responseId,
                  'mediationClassName': mediationAdapterClassName,
                });
              }
              onReady();
            }, onAdFailedToLoad: (Ad ad, LoadAdError error) {
              print('Inline adaptive banner failedToLoad: $error');
              _isLoaded = false;
              ad.dispose();
              onReset();
              if (maxRetryCount == 0) {
                return;
              }
              maxRetryCount--;
              loadAd();
            }),
            request: AdManagerAdRequest())
        .load();
  }

  @override
  onDispose() {
    _isLoaded = false;
  }

  @override
  Widget? buildAdWidget() {
    if (_adSize == null) {
      return null;
    }
    if (!_isLoaded) {
      return null;
    }
    // if (adWidget == null) {
    //   adWidget = AdWidget(ad: _bannerAd!);
    // }
    return Container(
      width: width,
      height: (_adSize?.height ?? $(80)).toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

class CardAdsMap {
  Map<int, CardAdsHolder> _holderMap = {};
  final double width;
  final Function() onUpdated;
  final double scale;
  bool autoHeight;

  CardAdsMap({
    required this.width,
    required this.onUpdated,
    this.scale = 0.6,
    this.autoHeight = false,
  });

  ///先初始化两个广告
  init() {
    _holderMap.clear();
    addAdsCard(0);
    addAdsCard(1);
  }

  bool hasAdHolder(int page) {
    return _holderMap.containsKey(page);
  }

  addAdsCard(int page) {
    if (_holderMap[page] == null) {
      _holderMap[page] = CardAdsHolder(
        width: width,
        onUpdated: onUpdated,
        autoHeight: autoHeight,
        adId: AdMobConfig.DISCOVERY_AD_ID,
        scale: scale,
      );
      _holderMap[page]?.initHolder();
    }
  }

  Widget? buildBannerAd(int page) {
    if (_holderMap.containsKey(page)) {
      var holderMap = _holderMap[page];
      if (holderMap!._isLoaded) {
        return holderMap.buildAdWidget();
      }
      holderMap.loadAd();
    }
    return null;
  }

  disposeOne(int page) {
    _holderMap[page]?.onDispose();
  }

  dispose() {
    for (var value in _holderMap.values) {
      value.onDispose();
    }
    _holderMap.clear();
  }
}
