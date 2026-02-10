import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tablas_de_verdad_2025/class/operator.dart';
import 'package:tablas_de_verdad_2025/const/calculator.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:provider/provider.dart';

enum KeyKind { operand, operator, action }

/// Segment for the keypad in advanced mode
enum _KeypadSegment { variables, operators }

/// Maps operator symbols → Operator instances for tooltip lookups
final Map<String, Operator> _operatorBySymbol = {
  '~': Operators.NOT,
  '¬': Operators.NOT2,
  '!': Operators.NOT3,
  '∧': Operators.AND,
  '&': Operators.AND2,
  '∨': Operators.OR,
  '|': Operators.OR2,
  '⇒': Operators.CODICIONAL,
  '⇔': Operators.BICODICIONAL,
  '￩': Operators.ANTICODICIONAL,
  '⊕': Operators.XOR,
  '⊻': Operators.XOR2,
  '↓': Operators.NOR,
  '⊼': Operators.NAND,
  '⇍': Operators.NOT_CONDITIONAL_INVERSE,
  '⇏': Operators.NOT_CONDITIONAL,
  '⇎': Operators.NOT_BICONDITIONAL,
  '┹': Operators.CONTRADICTION,
  '┲': Operators.TAUTOLOGY,
};

class TruthKeypad extends StatefulWidget {
  final void Function(String) onTap;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onToggleAa;
  final VoidCallback onEvaluate;
  final Case calculatorCase;
  final bool hideActionButtons;

  const TruthKeypad({
    super.key,
    required this.onTap,
    required this.onBackspace,
    required this.onClear,
    required this.onToggleAa,
    required this.onEvaluate,
    required this.calculatorCase,
    this.hideActionButtons = false,
  });

  @override
  State<TruthKeypad> createState() => _TruthKeypadState();
}

class _TruthKeypadState extends State<TruthKeypad> {
  _KeypadSegment _segment = _KeypadSegment.variables;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    final locale = AppLocalizations.of(context)?.localeName ?? 'en';
    final isAdvanced = settings.keypadMode != KeypadMode.simple;

    final letters = isAdvanced ? kLettersAdvanced : kLettersSimple;
    final operators = kOperatorsAdvanced;

    // Build buttons for the current view
    List<_Key> currentButtons;

    if (!isAdvanced) {
      // Simple mode: show all letters + operators in one grid
      currentButtons = [
        ...letters.map(
          (c) => _Key(
            label: widget.calculatorCase == Case.lower ? c : c.toUpperCase(),
            kind: KeyKind.operand,
            onTap: () => widget.onTap(c),
          ),
        ),
        ...operators.map(
          (o) => _Key(
            label: o,
            kind: KeyKind.operator,
            onTap: () => widget.onTap(o),
            isPremium: !settings.isProVersion && kPremiumOperators.contains(o),
            tooltip: _operatorBySymbol[o]?.getLocalizedName(locale),
          ),
        ),
      ];
    } else {
      // Advanced mode: show variables OR operators based on segment
      if (_segment == _KeypadSegment.variables) {
        currentButtons =
            letters
                .map(
                  (c) => _Key(
                    label:
                        widget.calculatorCase == Case.lower
                            ? c
                            : c.toUpperCase(),
                    kind: KeyKind.operand,
                    onTap: () => widget.onTap(c),
                  ),
                )
                .toList();
      } else {
        currentButtons =
            operators
                .map(
                  (o) => _Key(
                    label: o,
                    kind: KeyKind.operator,
                    onTap: () => widget.onTap(o),
                    isPremium:
                        !settings.isProVersion && kPremiumOperators.contains(o),
                    tooltip: _operatorBySymbol[o]?.getLocalizedName(locale),
                  ),
                )
                .toList();
      }
    }

    return Column(
      children: [
        // Segment toggle – only in advanced mode
        if (isAdvanced)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: _buildSegmentSelector(context),
          ),
        // Button grid
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const crossAxisCount = 4;
                const spacing = 10.0;
                final totalHSpacing = spacing * (crossAxisCount - 1);
                final buttonWidth =
                    (constraints.maxWidth - totalHSpacing) / crossAxisCount;
                final rows = (currentButtons.length / crossAxisCount).ceil();
                final totalVSpacing = spacing * (rows - 1);
                final availableHeight = constraints.maxHeight - totalVSpacing;
                final maxButtonHeight =
                    rows > 0 ? availableHeight / rows : buttonWidth;
                // Buttons should not be taller than wide
                final buttonHeight =
                    maxButtonHeight.clamp(0, buttonWidth).toDouble();
                final aspectRatio =
                    buttonWidth / (buttonHeight > 0 ? buttonHeight : 1);

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: aspectRatio,
                  physics: const NeverScrollableScrollPhysics(),
                  children: currentButtons,
                );
              },
            ),
          ),
        ),
        // Action row
        if (!widget.hideActionButtons)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _Key(
                      label: 'AC',
                      kind: KeyKind.action,
                      colorOverride: Colors.redAccent,
                      onTap: widget.onClear,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Key(
                      label: '⌫',
                      kind: KeyKind.action,
                      onTap: widget.onBackspace,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Key(
                      label: 'Aa',
                      kind: KeyKind.action,
                      onTap: widget.onToggleAa,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _Key(
                      label: '=',
                      kind: KeyKind.action,
                      colorOverride: kSeedColor,
                      onTap: widget.onEvaluate,
                      isEvaluate: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSegmentSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _segmentTab(
            label: 'abc',
            selected: _segment == _KeypadSegment.variables,
            onTap: () => setState(() => _segment = _KeypadSegment.variables),
            isDark: isDark,
          ),
          _segmentTab(
            label: '∧ ∨ ⇒',
            selected: _segment == _KeypadSegment.operators,
            onTap: () => setState(() => _segment = _KeypadSegment.operators),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _segmentTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color:
                selected
                    ? (isDark ? Colors.grey[700] : Colors.white)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color:
                    selected
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white38 : Colors.black38),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  final String label;
  final KeyKind kind;
  final VoidCallback onTap;
  final Color? colorOverride;
  final bool isPremium;
  final bool isEvaluate;
  final String? tooltip;

  const _Key({
    required this.label,
    required this.kind,
    required this.onTap,
    this.colorOverride,
    this.isPremium = false,
    this.isEvaluate = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    double fontSize = 20;

    if (colorOverride != null) {
      bg = colorOverride!;
      fg = Colors.white;
      if (isEvaluate) fontSize = 26;
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
          fontSize = 22;
          break;
        case KeyKind.action:
          bg = isDark ? Colors.grey[800]! : Colors.grey[200]!;
          fg = isDark ? Colors.white70 : Colors.black87;
          break;
      }
    }

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isDark
                    ? []
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          isEvaluate ? 0.12 : 0.05,
                        ),
                        blurRadius: isEvaluate ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Stack(
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight:
                            isEvaluate ? FontWeight.w800 : FontWeight.w600,
                        color: fg,
                      ),
                    ),
                  ),
                ),
              ),
              // Premium badge
              if (isPremium)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(
                    Icons.diamond,
                    size: 8,
                    color:
                        isDark
                            ? Colors.purple[300]!.withOpacity(0.7)
                            : Colors.purple.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    // Wrap with Tooltip for operators that have a name
    if (tooltip != null && tooltip!.isNotEmpty) {
      button = Tooltip(message: tooltip!, preferBelow: false, child: button);
    }

    return button;
  }
}
