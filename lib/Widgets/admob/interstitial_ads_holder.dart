import 'package:cartoonizer/Widgets/admob/ads_holder.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

///
/// @Author: wangyu
/// @Date: 2022/6/16
/// interstitial ads holder
/// usage:
///
/// in your state to initialize Holder
///   late InterstitialAdsHolder adsHolder;
///
///   @override
///   void initState() {
///     super.initState();
///     adsHolder = InterstitialAdsHolder(maxFailedLoadAttempts: 3);
///   }
///
/// and call onReady when you want to load ad
///   adsHolder.initHolder();
///
/// call show() to open fullscreen ads
///
/// don't forget to call dispose
///   adsHolder.onDispose();
class InterstitialAdsHolder extends PageAdsHolder {
  String adId;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int _maxFailedLoadAttempts = 3;

  InterstitialAdsHolder({
    required int maxFailedLoadAttempts,
    required this.adId,
  }) {
    _maxFailedLoadAttempts = maxFailedLoadAttempts;
  }

  @override
  initHolder() {
    _createInterstitialAd();
  }

  _createInterstitialAd() {
    onReset();
    InterstitialAd.load(
        adUnitId: adId,
        request: AdManagerAdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
            onReady();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            onReset();
            if (_numInterstitialLoadAttempts < _maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  @override
  onDispose() {
    _interstitialAd?.dispose();
  }

  @override
  show() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show().whenComplete(() {
      //reload next ad when current ad has been shown,
      print('adLoadFinished');
      _interstitialAd = null;
    });
  }
}
