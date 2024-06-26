import 'package:cartoonizer/models/enums/ad_type.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/widgets/admob/ads_holder.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardInterstitialAdsHolder extends PageAdsHolder {
  RewardedInterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int _maxFailedLoadAttempts = 3;
  String adId;
  Function? onRewardCall;
  Function? onDismiss;
  Function? onAdReady;

  RewardInterstitialAdsHolder({
    required this.adId,
    this.onRewardCall,
    this.onDismiss,
    this.onAdReady,
  }) : super();

  @override
  initHolder() {
    if (!isShowAdsNew(type: AdType.processing)) {
      return;
    }
    _createRewardedInterstitialAd();
  }

  @override
  onReady() {
    super.onReady();
    onAdReady?.call();
  }

  _createRewardedInterstitialAd() {
    onReset();
    RewardedInterstitialAd.load(
        adUnitId: adId,
        request: AdManagerAdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            print('RewardedInterstitialAd loaded: ${ad.responseInfo?.responseId}');
            cache.putAds(key, ad);
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            onReady();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedInterstitialAd failed to load: $error');
            _interstitialAd = null;
            _numInterstitialLoadAttempts += 1;
            _interstitialAd?.dispose();
            onReset();
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
    if (cache.getAdsCache(key) != null) {
      return;
    }
    if (_interstitialAd == null) {
      print('Warning: attempt to show rewarded interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) => print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        // ad.dispose();
        // _createRewardedInterstitialAd();
        onDismiss?.call();
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
      onRewardCall?.call();
    });
  }
}
