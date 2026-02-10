import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/const/const.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/widget/benefit_item.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/utils/analytics.dart';

Future<void> showProVersionDialog(
  BuildContext context,
  Settings settings,
  AppLocalizations localizations,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Analytics: track paywall view
  Analytics.instance.logEvent('paywall_shown');

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _ProPaywallSheet(
      settings: settings,
      localizations: localizations,
      isDark: isDark,
    ),
  );
}

class _ProPaywallSheet extends StatefulWidget {
  final Settings settings;
  final AppLocalizations localizations;
  final bool isDark;

  const _ProPaywallSheet({
    required this.settings,
    required this.localizations,
    required this.isDark,
  });

  @override
  State<_ProPaywallSheet> createState() => _ProPaywallSheetState();
}

class _ProPaywallSheetState extends State<_ProPaywallSheet> {
  bool _isLoading = false;
  bool _isRestoring = false;
  String? _error;

  Settings get settings => widget.settings;
  AppLocalizations get t => widget.localizations;
  bool get isDark => widget.isDark;

  void _buy() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    Analytics.instance.logEvent('paywall_buy_tapped');

    try {
      if (IS_TESTING) {
        settings.activateProLocally();
        if (mounted) Navigator.pop(context);
        return;
      }

      await settings.buyPro();

      // Listen for purchase completion
      settings.purchaseService.isPurchasing.addListener(_onPurchaseStateChange);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = t.purchaseError;
        });
      }
    }
  }

  void _onPurchaseStateChange() {
    if (!settings.purchaseService.isPurchasing.value) {
      settings.purchaseService.isPurchasing
          .removeListener(_onPurchaseStateChange);

      if (settings.isProVersion && mounted) {
        Analytics.instance.logProConversion();
        Navigator.pop(context);
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          if (settings.purchaseService.lastError != null) {
            _error = t.purchaseError;
          }
        });
      }
    }
  }

  void _restore() async {
    setState(() {
      _isRestoring = true;
      _error = null;
    });

    Analytics.instance.logEvent('paywall_restore_tapped');

    try {
      await settings.purchaseService.restorePurchases();
      if (settings.isProVersion && mounted) {
        Navigator.pop(context);
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isRestoring = false;
        if (!settings.isProVersion) {
          _error = t.noPurchasesFound;
        }
      });
    }
  }

  @override
  void dispose() {
    settings.purchaseService.isPurchasing
        .removeListener(_onPurchaseStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = settings.proPrice;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative gradient
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8E2DE2).withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Premium icon
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A00E0).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.diamond_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    t.becomePro,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle with price
                  Text(
                    t.oneTimePurchase,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Benefits card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black12,
                      ),
                    ),
                    child: Column(
                      children: [
                        BenefitItem(
                          icon: Icons.block_rounded,
                          text: t.noAds,
                        ),
                        BenefitItem(
                          icon: Icons.all_inclusive_rounded,
                          text: t.unlimitedPremiumOps,
                        ),
                        BenefitItem(
                          icon: Icons.library_books_rounded,
                          text: t.fullLibraryAccess,
                        ),
                        BenefitItem(
                          icon: Icons.support_agent_rounded,
                          text: t.premiumSupport,
                        ),
                        BenefitItem(
                          icon: Icons.favorite_rounded,
                          text: t.supportDeveloper,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Social proof
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFFC107).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFC107),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.socialProof,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Error message
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.redAccent.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  // BUY button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A00E0).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _buy,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          disabledForegroundColor: Colors.white60,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                price != null
                                    ? '${t.upgradePro} · $price'
                                    : t.upgradePro,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Restore purchases
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: _isRestoring ? null : _restore,
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDark ? Colors.white60 : Colors.black54,
                      ),
                      child: _isRestoring
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    isDark ? Colors.white38 : Colors.black26,
                              ),
                            )
                          : Text(
                              t.restorePurchases,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),

                  // Later button
                  TextButton(
                    onPressed: () {
                      Analytics.instance.logEvent('paywall_dismissed');
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDark ? Colors.white38 : Colors.black26,
                    ),
                    child: Text(
                      t.later,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
