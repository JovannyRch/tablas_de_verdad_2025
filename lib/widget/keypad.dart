import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/const/calculator.dart';
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

  void _openHistory() {
    // Implementar la lógica para abrir el historial
  }

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
          child: GridView.count(
            crossAxisCount: 5,
            padding: const EdgeInsets.all(8),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: buttons,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _Key(
                  label: 'AC',
                  kind: KeyKind.action,
                  colorOverride: Colors.red,
                  onTap: onClear,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _Key(
                  label: '⌫',
                  kind: KeyKind.action,
                  onTap: onBackspace,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _Key(
                  label: 'Aa',
                  kind: KeyKind.action,
                  onTap: onToggleAa,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _Key(
                  label: '=',
                  kind: KeyKind.action,
                  colorOverride: Colors.green,
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

/* ───── Botón individual con estilos según tipo ─────────────────── */

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

    Color bg;
    Color fg;

    if (colorOverride != null) {
      bg = colorOverride!;
      fg = scheme.onError;
    } else {
      switch (kind) {
        case KeyKind.operand:
          bg = scheme.secondaryContainer;
          fg = scheme.onSecondaryContainer;
          break;
        case KeyKind.operator:
          bg = scheme.primaryContainer;
          fg = scheme.onPrimaryContainer;
          break;
        case KeyKind.action:
          bg = scheme.surfaceVariant;
          fg = scheme.onSurfaceVariant;
          break;
      }
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: EdgeInsets.zero,
      ),
      onPressed: onTap,
      child: Center(child: Text(label, style: const TextStyle(fontSize: 18))),
    );
  }
}
