import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_ids.dart';

/// Wraps AdMob banner / interstitial / rewarded ads with sensible frequency
/// caps. Call [initialize] once on app start, then fire [maybeShowInterstitial]
/// after key flows (e.g. after a face scan result) and [showRewarded] from
/// the "+1 free scan" button.
class AdService {
  bool _initialized = false;
  bool _adsRemoved = false;

  BannerAd? _banner;
  bool _bannerReady = false;

  InterstitialAd? _interstitial;
  bool _interstitialReady = false;
  DateTime _lastInterstitial = DateTime.fromMillisecondsSinceEpoch(0);
  int _interstitialCounter = 0;
  static const _minInterstitialGapSec = 60;

  RewardedAd? _rewarded;
  bool _rewardedReady = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await MobileAds.instance.initialize();
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(maxAdContentRating: MaxAdContentRating.pg),
      );
      _loadBanner();
      _loadInterstitial();
      _loadRewarded();
    } catch (e) {
      if (kDebugMode) print('AdService init failed: $e');
    }
  }

  void setAdsRemoved(bool v) {
    _adsRemoved = v;
    if (v) {
      _banner?.dispose();
      _banner = null;
      _bannerReady = false;
    }
  }

  bool get adsRemoved => _adsRemoved;

  // ---------- Banner ----------

  BannerAd? get banner => _bannerReady && !_adsRemoved ? _banner : null;
  bool get bannerReady => _bannerReady && !_adsRemoved;

  void _loadBanner() {
    if (_adsRemoved) return;
    _banner = BannerAd(
      adUnitId: AdIds.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _bannerReady = true,
        onAdFailedToLoad: (ad, err) {
          _bannerReady = false;
          ad.dispose();
          // Retry after a beat — don't hammer.
          Future.delayed(const Duration(seconds: 30), _loadBanner);
        },
      ),
    )..load();
  }

  // ---------- Interstitial ----------

  void _loadInterstitial() {
    if (_adsRemoved) return;
    InterstitialAd.load(
      adUnitId: AdIds.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _interstitialReady = true;
        },
        onAdFailedToLoad: (_) {
          _interstitialReady = false;
          Future.delayed(const Duration(seconds: 45), _loadInterstitial);
        },
      ),
    );
  }

  Future<void> maybeShowInterstitial({bool force = false}) async {
    if (_adsRemoved) return;
    _interstitialCounter++;
    final gap = DateTime.now().difference(_lastInterstitial).inSeconds;
    final eligible = force || (_interstitialCounter % 2 == 0 && gap >= _minInterstitialGapSec);
    if (!eligible || !_interstitialReady || _interstitial == null) return;

    _interstitial!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialReady = false;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialReady = false;
        _loadInterstitial();
      },
    );
    await _interstitial!.show();
    _lastInterstitial = DateTime.now();
  }

  // ---------- Rewarded ----------

  bool get rewardedReady => _rewardedReady;

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: AdIds.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _rewardedReady = true;
        },
        onAdFailedToLoad: (_) {
          _rewardedReady = false;
          Future.delayed(const Duration(seconds: 45), _loadRewarded);
        },
      ),
    );
  }

  /// Returns true if the user earned the reward.
  Future<bool> showRewarded() async {
    if (!_rewardedReady || _rewarded == null) {
      _loadRewarded();
      return false;
    }
    bool earned = false;
    _rewarded!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedReady = false;
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewardedReady = false;
        _loadRewarded();
      },
    );
    await _rewarded!.show(
      onUserEarnedReward: (_, __) => earned = true,
    );
    return earned;
  }

  bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}
