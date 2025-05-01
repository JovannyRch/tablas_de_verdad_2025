import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

Future<bool> restoreAndCheckProPurchase() async {
  final iap = InAppPurchase.instance;
  final bool available = await iap.isAvailable();
  if (!available) return false;

  final Completer<bool> hasPro = Completer<bool>();

  final Stream<List<PurchaseDetails>> subscription = iap.purchaseStream;

  late final StreamSubscription<List<PurchaseDetails>> sub;

  sub = subscription.listen(
    (purchases) {
      for (final purchase in purchases) {
        if (purchase.productID == 'pro_version' &&
            purchase.status == PurchaseStatus.purchased) {
          hasPro.complete(true);
          sub.cancel();
          return;
        }
      }
      if (!hasPro.isCompleted) {
        hasPro.complete(false);
      }
    },
    onError: (error) {
      if (!hasPro.isCompleted) {
        hasPro.complete(false);
      }
    },
  );

  await iap.restorePurchases();
  return await hasPro.future;
}
