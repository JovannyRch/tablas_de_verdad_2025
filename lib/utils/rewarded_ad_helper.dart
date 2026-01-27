import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';

/// Helper class para manejar Rewarded Ads (anuncios con recompensa)
/// Estos se muestran cuando un usuario no Pro usa operadores premium
class RewardedAdHelper {
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;
  bool _isAdReady = false;

  // ID del rewarded ad (debes configurarlo en AdMob)
  final String adUnitId = IS_TESTING
      ? Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917' // Test ID Android
          : 'ca-app-pub-3940256099942544/1712485313' // Test ID iOS
      : "ca-app-pub-4665787383933447/5765549025"; // Tu ID de producción

  RewardedAdHelper() {
    loadRewardedAd();
  }

  /// Carga el rewarded ad
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
          _isAdReady = true;
          _setFullScreenContentCallback();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
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
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        // Ad mostrado
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _isAdReady = false;
        // Precargar el siguiente ad
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _isAdReady = false;
        loadRewardedAd();
      },
    );
  }

  /// Muestra el rewarded ad y retorna true si el usuario completó el video
  Future<bool> showRewardedAd() async {
    if (!_isAdReady || _rewardedAd == null) {
      // Si el ad no está listo, retornar false o intentar cargarlo
      return false;
    }

    bool userEarnedReward = false;

    await _rewardedAd!.show(
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
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdReady = false;
  }
}
