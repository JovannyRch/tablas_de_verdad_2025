import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/model/operator_theory.dart';

/// A compact, expandable theory card that explains a logical operator.
///
/// Shows the operator definition, its mini truth-table, and an example.
class TheoryCard extends StatelessWidget {
  final OperatorTheory theory;
  final String operatorName;

  const TheoryCard({
    super.key,
    required this.theory,
    required this.operatorName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnary = theory.truthTable.first.length == 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            isDark
                ? kSeedColor.withValues(alpha: 0.06)
                : kSeedColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kSeedColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon + operator name
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: kSeedColor,
              ),
              const SizedBox(width: 6),
              Text(
                operatorName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kSeedColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Definition text
          Text(
            theory.definition,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          // Mini truth table + example side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mini truth table
              _MiniTruthTable(
                rows: theory.truthTable,
                isUnary: isUnary,
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              // Example
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white38 : Colors.black38,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        theory.example,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Courier',
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A compact mini truth table showing the operator definition.
class _MiniTruthTable extends StatelessWidget {
  final List<List<String>> rows;
  final bool isUnary;
  final bool isDark;

  const _MiniTruthTable({
    required this.rows,
    required this.isUnary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final headers = isUnary ? ['p', 'R'] : ['p', 'q', 'R'];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(7),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children:
                  headers
                      .map(
                        (h) => SizedBox(
                          width: 28,
                          child: Text(
                            h,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color:
                                  h == 'R'
                                      ? kSeedColor
                                      : (isDark
                                          ? Colors.white54
                                          : Colors.black54),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          // Data rows
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children:
                    row.asMap().entries.map((e) {
                      final isResult = e.key == row.length - 1;
                      final val = e.value;
                      return SizedBox(
                        width: 28,
                        child: Text(
                          val,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isResult ? FontWeight.w700 : FontWeight.w500,
                            color:
                                isResult
                                    ? (val == '1'
                                        ? Colors.green[400]
                                        : Colors.red[400])
                                    : (isDark
                                        ? Colors.white60
                                        : Colors.black54),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}
