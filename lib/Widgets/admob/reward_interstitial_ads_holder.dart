import 'package:cartoonizer/Widgets/admob/ads_holder.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardInterstitialAdsHolder extends PageAdsHolder {
  RewardedInterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int _maxFailedLoadAttempts = 3;
  String adId;

  RewardInterstitialAdsHolder({required this.adId});

  @override
  initHolder() {
    _createRewardedInterstitialAd();
  }

  _createRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
        adUnitId: adId,
        request: AdManagerAdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            print('$ad loaded.');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedInterstitialAd failed to load: $error');
            _interstitialAd = null;
            _numInterstitialLoadAttempts += 1;
            if (_numInterstitialLoadAttempts < _maxFailedLoadAttempts) {
              _createRewardedInterstitialAd();
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
      print('Warning: attempt to show rewarded interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) => print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedInterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
    );

    _interstitialAd!.setImmersiveMode(true);
    _interstitialAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _interstitialAd = null;
  }
}
