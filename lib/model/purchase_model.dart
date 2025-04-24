import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseModel extends ChangeNotifier {
  bool isPro = false;
  late final InAppPurchase _iap;
  late ProductDetails _proSku;

  Future<void> init() async {
    _iap = InAppPurchase.instance;

    // 1. ¿La tienda está disponible?
    if (!await _iap.isAvailable()) return;

    // 2. Consulta tu producto
    final resp = await _iap.queryProductDetails({'pro_unlock'});
    _proSku = resp.productDetails.first;

    // 3. Escucha compras nuevas/restauradas
    _iap.purchaseStream.listen(_handlePurchases);

    // 4. Restaura compras PREVIAS  ⬅️  (reemplaza a queryPastPurchases)
    await _iap.restorePurchases();
  }

  /* ———————— helpers ———————— */
  void buyPro() => _iap.buyNonConsumable(
    purchaseParam: PurchaseParam(productDetails: _proSku),
  );

  Future<void> _handlePurchases(List<PurchaseDetails> list) async {
    for (final p in list) {
      if (p.productID == 'pro_unlock' &&
          (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored)) {
        isPro = true;
        if (p.pendingCompletePurchase) await _iap.completePurchase(p);
        notifyListeners();
      }
    }
  }
}
