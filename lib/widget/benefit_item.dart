import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';

class BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  /// Emphasizes a headline benefit (brand-orange chip + bolder text). Used for
  /// the Pro-only advanced tools (Karnaugh, simplification, normal forms).
  final bool highlight;

  const BenefitItem({
    super.key,
    required this.icon,
    required this.text,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = highlight ? kSeedColor : const Color(0xFFD4AF37);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
