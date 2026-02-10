import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';

class PurchaseService {
  static const String _proProductId = 'pro_version';
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  ValueNotifier<bool> isProVersion = ValueNotifier<bool>(false);

  /// Cached product details (price string, etc.)
  ProductDetails? productDetails;

  /// Loading / error state for UI
  ValueNotifier<bool> isPurchasing = ValueNotifier<bool>(false);
  String? lastError;

  void initPurchaseListener() {
    if (_subscription != null) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (error) {
        if (kDebugMode) print('Purchase error: $error');
        isPurchasing.value = false;
        lastError = error.toString();
      },
    );
  }

  void dispose() {
    _subscription?.cancel();
  }

  /// Pre-fetch product details so price is available before showing paywall.
  Future<void> loadProductDetails() async {
    final bool available = await _iap.isAvailable();
    if (!available) return;

    final response = await _iap.queryProductDetails({_proProductId});
    if (response.productDetails.isNotEmpty) {
      productDetails = response.productDetails.first;
    }
  }

  /// Returns the localized price string (e.g. "$4.99") or null.
  String? get priceString => productDetails?.price;

  Future<void> restorePurchases() async {
    final bool available = await _iap.isAvailable();
    if (!available) return;

    final Completer<void> restoration = Completer();

    final sub = _iap.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        if (purchase.productID == _proProductId &&
            (purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored)) {
          isProVersion.value = true;
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        }
      }
      if (!restoration.isCompleted) restoration.complete();
    }, onError: (_) {
      if (!restoration.isCompleted) restoration.complete();
    });

    await _iap.restorePurchases();
    await restoration.future;
    await sub.cancel();
  }

  Future<void> buyProVersion() async {
    isPurchasing.value = true;
    lastError = null;

    try {
      // Use cached product details if available, otherwise fetch
      ProductDetails? product = productDetails;
      if (product == null) {
        final response = await _iap.queryProductDetails({_proProductId});
        if (response.notFoundIDs.isNotEmpty ||
            response.productDetails.isEmpty) {
          throw Exception('Product not available');
        }
        product = response.productDetails.first;
        productDetails = product;
      }

      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      isPurchasing.value = false;
      lastError = e.toString();
      rethrow;
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != _proProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          isProVersion.value = true;
          // CRITICAL: Acknowledge purchase to prevent auto-refund
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          isPurchasing.value = false;
          break;
        case PurchaseStatus.error:
          isPurchasing.value = false;
          lastError = purchase.error?.message ?? 'Purchase failed';
          if (kDebugMode) print('Purchase error: ${purchase.error}');
          break;
        case PurchaseStatus.canceled:
          isPurchasing.value = false;
          break;
        case PurchaseStatus.pending:
          isPurchasing.value = true;
          break;
      }
    }
  }
}
