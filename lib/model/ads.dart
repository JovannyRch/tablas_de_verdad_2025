import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';

class Ads {
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
  late String adId;
  InterstitialAd? interstitialAd;
  AdRequest request = const AdRequest();

  Ads(String id) {
    this.adId =
        IS_TESTING
            ? Platform.isAndroid
                ? 'ca-app-pub-7319269804560504/8512599311'
                : 'ca-app-pub-3940256099942544/4411468910'
            : id;
    createInterstitialAd();
  }

  Future createInterstitialAd() async {
    InterstitialAd.load(
      adUnitId: adId,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numInterstitialLoadAttempts += 1;
          interstitialAd = null;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            createInterstitialAd();
          }
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (interstitialAd == null) {
      print("ad is null");
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        createInterstitialAd();
      },
    );
    interstitialAd!.show();
    interstitialAd = null;
  }

  void dispose() {
    if (interstitialAd != null) {
      interstitialAd!.dispose();
    }
  }
}
