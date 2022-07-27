import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_holder.dart';

///
/// @Author: wangyu
/// @Date: 2022/7/7
class CardAdsHolder extends WidgetAdsHolder {
  AdManagerBannerAd? _inlineAdaptiveAd;
  double scale = 0.75;
  bool _isLoaded = false;
  AdSize? _adSize;
  Function? onUpdated;
  AdWidget? adWidget;
  final bool closeable;
  bool closeAds = false;
  late String adId;
  final double width;
  double? height;
  bool autoHeight;

  CardAdsHolder({
    required this.width,
    this.onUpdated, // call widget to call setState
    this.closeable = false, // set true to open close ads
    this.scale = 0.6, // widget's height / width
    required this.adId,
    this.height,
    this.autoHeight = false, // while height was provided, scale will be ignored.
  });

  @override
  initHolder() {
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

  loadAd() async {
    await _inlineAdaptiveAd?.dispose();
    _inlineAdaptiveAd = null;
    _isLoaded = false;
    closeAds = false;
    onReset();

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
    _inlineAdaptiveAd = AdManagerBannerAd(
      adUnitId: adId,
      sizes: [adSize],
      request: AdManagerAdRequest(),
      listener: AdManagerBannerAdListener(
        onAdLoaded: (Ad ad) async {
          print('Inline adaptive banner loaded: ${ad.responseInfo}');

          AdManagerBannerAd bannerAd = (ad as AdManagerBannerAd);
          final AdSize? size = await bannerAd.getPlatformAdSize();
          if (size == null) {
            print('Error: getPlatformAdSize() returned null for $bannerAd');
            return;
          }

          _inlineAdaptiveAd = bannerAd;
          _isLoaded = true;
          _adSize = size;
          onReady();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Inline adaptive banner failedToLoad: $error');
          ad.dispose();
          onReset();
        },
      ),
    );
    await _inlineAdaptiveAd!.load();
  }

  @override
  onDispose() {
    _inlineAdaptiveAd?.dispose();
  }

  @override
  Widget? buildAdWidget() {
    if (!_isLoaded || closeAds) {
      return null;
    }
    if (adWidget == null) {
      adWidget = AdWidget(ad: _inlineAdaptiveAd!);
    }
    return Stack(
      children: [
        Container(
          width: width,
          height: (_adSize?.height ?? $(80)).toDouble(),
          child: adWidget,
        ),
        Align(
          child: Icon(
            Icons.close,
            size: $(18),
            color: Colors.white,
          )
              .intoContainer(
            padding: EdgeInsets.all($(4)),
            margin: EdgeInsets.all($(4)),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(32), color: Color(0x33ffffff)),
          )
              .intoGestureDetector(onTap: () {
            if (closeable) {
              closeAds = true;
              onReady();
            }
          }),
          alignment: Alignment.topRight,
        ).offstage(offstage: !closeable),
      ],
    ).intoContainer(
      width: width,
      height: (_adSize?.height ?? $(80)).toDouble(),
    );
  }
}

class CardAdsMap {
  Map<int, CardAdsHolder> _holderMap = {};
  final double width;
  final Function() onUpdated;
  final double scale;

  CardAdsMap({required this.width, required this.onUpdated, this.scale = 0.6});

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
        adId: AdMobConfig.DISCOVERY_AD_ID,
        scale: scale,
      );
      _holderMap[page]?.initHolder();
    }
  }

  Widget? buildBannerAd(int page) {
    if (_holderMap.containsKey(page)) {
      return _holderMap[page]!.buildAdWidget();
    } else {
      return null;
    }
  }

  dispose() {
    for (var value in _holderMap.values) {
      value.onDispose();
    }
    _holderMap.clear();
  }
}
