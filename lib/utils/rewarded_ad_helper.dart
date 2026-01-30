import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';

/// Helper class para manejar Rewarded Interstitial Ads (anuncios intersticiales con recompensa)
/// Estos se muestran cuando un usuario no Pro usa operadores premium
/// Rewarded Interstitial = Mayor CPM que Rewarded normal + Más corto = Mejor UX
class RewardedAdHelper {
  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;
  bool _isAdReady = false;

  // ID del rewarded interstitial ad (más rentable que rewarded normal)
  final String adUnitId = IS_TESTING
      ? Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5354046379' // Test ID Android
          : 'ca-app-pub-3940256099942544/6978759866' // Test ID iOS
      : "ca-app-pub-4665787383933447/5065343899"; // Tu ID de producción (Rewarded Interstitial)

  RewardedAdHelper() {
    loadRewardedAd();
  }

  /// Carga el rewarded interstitial ad
  void loadRewardedAd() {
    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          _rewardedInterstitialAd = ad;
          _numRewardedLoadAttempts = 0;
          _isAdReady = true;
          _setFullScreenContentCallback();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedInterstitialAd = null;
          _isAdReady = false;
          _numRewardedLoadAttempts += 1;
          
          if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
            // Reintentar cargar el ad
            Future.delayed(const Duration(seconds: 2), loadRewardedAd);
          }
        },
      ),
    );
  }

  /// Configura los callbacks de pantalla completa
  void _setFullScreenContentCallback() {
    _rewardedInterstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (Ad ad) {
        // Ad mostrado
      },
      onAdDismissedFullScreenContent: (Ad ad) {
        ad.dispose();
        _isAdReady = false;
        // Precargar el siguiente ad
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (Ad ad, AdError error) {
        ad.dispose();
        _isAdReady = false;
        loadRewardedAd();
      },
    );
  }

  /// Muestra el rewarded interstitial ad y retorna true si el usuario completó el video
  Future<bool> showRewardedAd() async {
    if (!_isAdReady || _rewardedInterstitialAd == null) {
      // Si el ad no está listo, retornar false o intentar cargarlo
      return false;
    }

    bool userEarnedReward = false;

    await _rewardedInterstitialAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        // Usuario completó el video y obtuvo la recompensa
        userEarnedReward = true;
      },
    );

    return userEarnedReward;
  }

  /// Verifica si el ad está listo para mostrarse
  bool get isReady => _isAdReady;

  /// Libera recursos
  void dispose() {
    _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;
    _isAdReady = false;
  }
}
