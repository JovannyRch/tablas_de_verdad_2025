import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/const/calculator.dart';
import 'package:tablas_de_verdad_2025/main.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:provider/provider.dart';

enum KeyKind { operand, operator, action }

class TruthKeypad extends StatelessWidget {
  final void Function(String) onTap;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onToggleAa;
  final VoidCallback onEvaluate;
  final Case calculatorCase;

  const TruthKeypad({
    super.key,
    required this.onTap,
    required this.onBackspace,
    required this.onClear,
    required this.onToggleAa,
    required this.onEvaluate,
    required this.calculatorCase,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    final letters =
        settings.keypadMode == KeypadMode.simple
            ? kLettersSimple
            : kLettersAdvanced;

    final operators =
        settings.keypadMode == KeypadMode.simple
            ? kOperatorsSimple
            : kOperatorsAdvanced;

    final buttons = [
      ...letters.map(
        (c) => _Key(
          label: calculatorCase == Case.lower ? c : c.toUpperCase(),
          kind: KeyKind.operand,
          onTap: () => onTap(c),
        ),
      ),
      ...operators.map(
        (o) => _Key(label: o, kind: KeyKind.operator, onTap: () => onTap(o)),
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GridView.count(
              crossAxisCount:
                  4, // 4 columns looks more professional for calculator
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: buttons,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _Key(
                  label: 'AC',
                  kind: KeyKind.action,
                  colorOverride: Colors.redAccent,
                  onTap: onClear,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Key(
                  label: '⌫',
                  kind: KeyKind.action,
                  onTap: onBackspace,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Key(
                  label: 'Aa',
                  kind: KeyKind.action,
                  onTap: onToggleAa,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Key(
                  label: '=',
                  kind: KeyKind.action,
                  colorOverride: kSeedColor,
                  onTap: onEvaluate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  final String label;
  final KeyKind kind;
  final VoidCallback onTap;
  final Color? colorOverride;

  const _Key({
    required this.label,
    required this.kind,
    required this.onTap,
    this.colorOverride,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    double fontSize = 22;

    if (colorOverride != null) {
      bg = colorOverride!;
      fg = Colors.white;
    } else {
      switch (kind) {
        case KeyKind.operand:
          bg = isDark ? Colors.grey[850]! : Colors.white;
          fg = isDark ? Colors.white : Colors.black87;
          break;
        case KeyKind.operator:
          bg =
              isDark
                  ? scheme.primaryContainer.withOpacity(0.3)
                  : scheme.primaryContainer.withOpacity(0.1);
          fg = isDark ? Colors.orange[300]! : kSeedColor;
          fontSize = 24;
          break;
        case KeyKind.action:
          bg = isDark ? Colors.grey[800]! : Colors.grey[200]!;
          fg = isDark ? Colors.white70 : Colors.black87;
          break;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                isDark
                    ? []
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
