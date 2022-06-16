import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
///
/// @Author: wangyu
/// @Date: 2022/6/16
///
/// banner ads holder
/// usage:
///
/// in your state to initialize Holder
///
///   late BannerAdsHolder bannerAdsHolder;
///   @override
///   initState() {
///    bannerAdsHolder = BannerAdsHolder(
///      this,
///      closeable: false,
///      onUpdated: () {
///        setState(() {});
///      },
///    );
///   }
///
/// and call onReady when you want to load ad
///
///   bannerAdsHolder.onReady(horizontalPadding: $(50));
/// call bannerAdsHolder.buildBannerAd(); to build widget and add to your widget-tree
///
/// don't forget to call dispose
///   bannerAdsHolder.onDispose();
class BannerAdsHolder {
  AdManagerBannerAd? _inlineAdaptiveAd;
  double scale = 0.75;
  bool _isLoaded = false;
  AdSize? _adSize;
  double _adWidth = 0;
  State? state;
  Function() onUpdated;
  AdWidget? adWidget;
  final bool closeable;
  bool closeAds = false;

  BannerAdsHolder(
    this.state, {
    required this.onUpdated, // call widget to call setState
    this.closeable = false, // set true to open close ads
    this.scale = 0.6, // widget's height / width
  });

  onReady({double horizontalPadding = 0}) {
    _adWidth = ScreenUtil.getCurrentWidgetSize(state!.context).width - horizontalPadding;
    loadAd();
  }

  loadAd() async {
    await _inlineAdaptiveAd?.dispose();
    _inlineAdaptiveAd = null;
    _isLoaded = false;
    closeAds = false;
    onUpdated.call();

    // AdSize size = AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(_adWidth.truncate());
    var height = _adWidth * scale;
    _inlineAdaptiveAd = AdManagerBannerAd(
      adUnitId: AdMobConfig.BANNER_AD_ID,
      sizes: [AdSize(width: _adWidth.toInt(), height: height.toInt())],
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
          delay(() {
            _isLoaded = true;
            _adSize = size;
            onUpdated.call();
          }, milliseconds: 16);
          // onUpdated.call();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Inline adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    await _inlineAdaptiveAd!.load();
  }

  onDispose() {
    _inlineAdaptiveAd?.dispose();
    state = null;
  }

  Widget buildBannerAd() {
    if (!_isLoaded || closeAds) {
      return Container();
    }
    if (adWidget == null) {
      adWidget = AdWidget(ad: _inlineAdaptiveAd!);
    }
    return Stack(
      children: [
        Container(
          width: _adWidth,
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
              onUpdated.call();
            }
          }),
          alignment: Alignment.topRight,
        ).offstage(offstage: !closeable),
      ],
    ).intoContainer(
      width: _adWidth,
      height: (_adSize?.height ?? $(80)).toDouble(),
      margin: EdgeInsets.only(bottom: $(12)),
    );
  }
}
