import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';

class PurchaseService {
  static const String _proProductId = 'pro_version';
  final InAppPurchase _iap = InAppPurchase.instance;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  ValueNotifier<bool> isProVersion = ValueNotifier<bool>(false);

  void initPurchaseListener() {
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (error) {
        if (kDebugMode) print('Purchase error: $error');
      },
    );
  }

  void dispose() {
    _subscription.cancel();
  }

  Future<void> restorePurchases() async {
    final bool available = await _iap.isAvailable();
    if (!available) return;

    final Completer<void> restoration = Completer();

    final sub = _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        if (purchase.productID == _proProductId &&
            purchase.status == PurchaseStatus.purchased) {
          isProVersion.value = true;
          break;
        }
      }
      restoration.complete();
    }, onError: (_) => restoration.complete());

    await _iap.restorePurchases();
    await restoration.future;
    await sub.cancel();
  }

  Future<void> buyProVersion() async {
    final response = await _iap.queryProductDetails({_proProductId});
    if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
      throw Exception('Producto no disponible');
    }

    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID == _proProductId &&
          purchase.status == PurchaseStatus.purchased) {
        isProVersion.value = true;
      }
    }
  }
}
