import 'package:cartoonizer/config.dart';
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
///   adsHolder.onReady();
///
/// call showInterstitialAd() to open fullscreen ads
///
/// don't forget to call dispose
///   adsHolder.onDispose();
@deprecated
class InterstitialAdsHolder {
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int _maxFailedLoadAttempts = 3;

  InterstitialAdsHolder({required int maxFailedLoadAttempts}) {
    _maxFailedLoadAttempts = maxFailedLoadAttempts;
  }

  onReady() {
    _createInterstitialAd();
  }

  _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdMobConfig.INTERSTITIAL_AD_ID,
        request: AdManagerAdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < _maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void showInterstitialAd() {
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

  onDisposed() {
    _interstitialAd?.dispose();
  }
}
