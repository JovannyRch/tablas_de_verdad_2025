import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablas_de_verdad_2025/const/calculator.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/utils/equivalence_checker.dart';
import 'package:tablas_de_verdad_2025/utils/expression_validator.dart';
import 'package:tablas_de_verdad_2025/utils/ghost_text_controller.dart';
import 'package:tablas_de_verdad_2025/widget/keypad.dart';

class EquivalenceScreen extends StatefulWidget {
  const EquivalenceScreen({super.key});

  @override
  State<EquivalenceScreen> createState() => _EquivalenceScreenState();
}

class _EquivalenceScreenState extends State<EquivalenceScreen> {
  final _controllerA = GhostTextEditingController();
  final _controllerB = GhostTextEditingController();
  final _focusNodeA = FocusNode();
  final _focusNodeB = FocusNode();

  /// Which field is currently active (true = A, false = B).
  bool _activeIsA = true;
  Case _case = Case.lower;

  ValidationResult _validationA = const ValidationResult(
    ValidationStatus.empty,
  );
  ValidationResult _validationB = const ValidationResult(
    ValidationStatus.empty,
  );

  EquivalenceResult? _result;
  bool _isComputing = false;

  @override
  void initState() {
    super.initState();
    _focusNodeA.addListener(_onFocusChanged);
    _focusNodeB.addListener(_onFocusChanged);
    _controllerA.addListener(_onExprAChanged);
    _controllerB.addListener(_onExprBChanged);
  }

  @override
  void dispose() {
    _focusNodeA.removeListener(_onFocusChanged);
    _focusNodeB.removeListener(_onFocusChanged);
    _controllerA.removeListener(_onExprAChanged);
    _controllerB.removeListener(_onExprBChanged);
    _controllerA.dispose();
    _controllerB.dispose();
    _focusNodeA.dispose();
    _focusNodeB.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNodeA.hasFocus) {
      setState(() => _activeIsA = true);
    } else if (_focusNodeB.hasFocus) {
      setState(() => _activeIsA = false);
    }
  }

  void _onExprAChanged() {
    final t = AppLocalizations.of(context)!;
    setState(() {
      _validationA = ExpressionValidator.validate(
        _controllerA.text,
        validationMsgUnmatched: t.validationUnmatched,
        validationMsgMissingOperand: t.validationMissingOperand,
        validationMsgMissingOperator: t.validationMissingOperator,
        validationMsgTrailingOp: t.validationTrailingOp,
        validationMsgValid: t.validationValid,
      );
      _result = null; // Clear previous result on edit
    });
  }

  void _onExprBChanged() {
    final t = AppLocalizations.of(context)!;
    setState(() {
      _validationB = ExpressionValidator.validate(
        _controllerB.text,
        validationMsgUnmatched: t.validationUnmatched,
        validationMsgMissingOperand: t.validationMissingOperand,
        validationMsgMissingOperator: t.validationMissingOperator,
        validationMsgTrailingOp: t.validationTrailingOp,
        validationMsgValid: t.validationValid,
      );
      _result = null;
    });
  }

  bool get _canCheck =>
      _validationA.isValid && _validationB.isValid && !_isComputing;

  void _runCheck() {
    final settings = context.read<Settings>();
    setState(() => _isComputing = true);

    final result = EquivalenceChecker.check(
      _controllerA.text,
      _controllerB.text,
      settings.locale.languageCode,
      settings.truthFormat,
    );

    setState(() {
      _result = result;
      _isComputing = false;
    });
  }

  void _swapExpressions() {
    final tempText = _controllerA.text;
    _controllerA.text = _controllerB.text;
    _controllerB.text = tempText;
  }

  /// Insert text into the active controller (called by keypad).
  void _insertText(String text) {
    final controller = _activeIsA ? _controllerA : _controllerB;
    final sel = controller.selection;
    final base = controller.text;

    if (sel.isValid && sel.start >= 0) {
      final newText = base.replaceRange(sel.start, sel.end, text);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: sel.start + text.length),
      );
    } else {
      controller.text = base + text;
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
  }

  void _backspace() {
    final controller = _activeIsA ? _controllerA : _controllerB;
    final sel = controller.selection;
    final base = controller.text;

    if (base.isEmpty) return;

    if (sel.isValid && sel.start > 0) {
      final newText = base.replaceRange(sel.start - 1, sel.end, '');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: sel.start - 1),
      );
    } else if (base.isNotEmpty) {
      controller.text = base.substring(0, base.length - 1);
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
  }

  void _clearActive() {
    final controller = _activeIsA ? _controllerA : _controllerB;
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(t.equivalenceChecker), centerTitle: true),
      body: Column(
        children: [
          // ─── Input & Result Area (scrollable) ───
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Expression A
                  _ExpressionField(
                    label: t.expressionA,
                    controller: _controllerA,
                    focusNode: _focusNodeA,
                    validation: _validationA,
                    isActive: _activeIsA,
                    onTap: () {
                      setState(() => _activeIsA = true);
                      _focusNodeA.requestFocus();
                    },
                  ),

                  const SizedBox(height: 8),

                  // Swap button
                  Center(
                    child: IconButton.filledTonal(
                      onPressed: _swapExpressions,
                      icon: const Icon(Icons.swap_vert_rounded, size: 22),
                      tooltip: t.swapExpressions,
                      style: IconButton.styleFrom(
                        backgroundColor: cs.secondaryContainer,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Expression B
                  _ExpressionField(
                    label: t.expressionB,
                    controller: _controllerB,
                    focusNode: _focusNodeB,
                    validation: _validationB,
                    isActive: !_activeIsA,
                    onTap: () {
                      setState(() => _activeIsA = false);
                      _focusNodeB.requestFocus();
                    },
                  ),

                  const SizedBox(height: 20),

                  // Check button
                  FilledButton.icon(
                    onPressed: _canCheck ? _runCheck : null,
                    icon:
                        _isComputing
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.compare_arrows_rounded),
                    label: Text(t.checkEquivalence),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // ─── Result Card ───
                  if (_result != null) ...[
                    const SizedBox(height: 24),
                    _buildResultCard(t, cs, isDark),
                  ],

                  // ─── Comparison Table ───
                  if (_result != null && !_result!.hasError) ...[
                    const SizedBox(height: 16),
                    _buildComparisonTable(t, cs, isDark),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ─── Keypad ───
          Expanded(
            child: TruthKeypad(
              onTap: (key) {
                final piece =
                    _case == Case.lower ? key.toLowerCase() : key.toUpperCase();
                _insertText(piece);
              },
              onBackspace: _backspace,
              onClear: _clearActive,
              onToggleAa:
                  () => setState(() {
                    _case = _case == Case.lower ? Case.upper : Case.lower;
                  }),
              onEvaluate: _canCheck ? _runCheck : () {},
              calculatorCase: _case,
              hideActionButtons: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(AppLocalizations t, ColorScheme cs, bool isDark) {
    final result = _result!;

    if (result.hasError) {
      return _ResultBanner(
        icon: Icons.error_outline_rounded,
        color: cs.error,
        title: t.equivalenceError,
        subtitle: result.error!,
      );
    }

    if (result.isEquivalent) {
      return _ResultBanner(
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF4CAF50),
        title: t.expressionsEquivalent,
        subtitle: t.equivalentDescription,
      );
    }

    final pct = (result.matchPercentage * 100).toStringAsFixed(0);
    return _ResultBanner(
      icon: Icons.cancel_rounded,
      color: cs.error,
      title: t.expressionsNotEquivalent,
      subtitle: t.notEquivalentDescription(
        result.differingRows.length.toString(),
        result.tableA.totalRows.toString(),
        pct,
      ),
    );
  }

  Widget _buildComparisonTable(
    AppLocalizations t,
    ColorScheme cs,
    bool isDark,
  ) {
    final result = _result!;
    final ttA = result.tableA;
    final ttB = result.tableB;

    // Unified variable list (already sorted in both)
    final variables = ttA.variables;
    final totalRows = ttA.totalRows;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.comparisonTable,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 36,
                columnSpacing: 16,
                horizontalMargin: 8,
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: cs.onSurface,
                ),
                columns: [
                  ...variables.map((v) => DataColumn(label: Text(v))),
                  DataColumn(
                    label: Text('A', style: TextStyle(color: kSeedColor)),
                  ),
                  DataColumn(
                    label: Text('B', style: TextStyle(color: cs.tertiary)),
                  ),
                ],
                rows: List.generate(totalRows, (i) {
                  final rowA = ttA.table[i];
                  final rowB = ttB.table[i];
                  final differs = result.differingRows.contains(i);

                  return DataRow(
                    color: WidgetStateProperty.resolveWith((_) {
                      if (differs) {
                        return cs.errorContainer.withValues(alpha: 0.3);
                      }
                      return null;
                    }),
                    cells: [
                      ...List.generate(variables.length, (vi) {
                        return DataCell(
                          Text(
                            rowA.combination[vi],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                          ),
                        );
                      }),
                      DataCell(
                        Text(
                          rowA.result,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: differs ? cs.error : kSeedColor,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          rowB.result,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: differs ? cs.error : cs.tertiary,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

/// A labelled text field for entering one expression, with inline validation.
class _ExpressionField extends StatelessWidget {
  final String label;
  final GhostTextEditingController controller;
  final FocusNode focusNode;
  final ValidationResult validation;
  final bool isActive;
  final VoidCallback onTap;

  const _ExpressionField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.validation,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color borderColor;
    if (isActive) {
      borderColor = kSeedColor;
    } else {
      borderColor = cs.outlineVariant;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isActive ? 2 : 1),
          color: cs.surfaceContainerLowest,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? kSeedColor : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: true,
              showCursor: true,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
            if (!validation.isEmpty) ...[
              const SizedBox(height: 4),
              _ValidationIndicator(validation: validation),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small inline validation status indicator.
class _ValidationIndicator extends StatelessWidget {
  final ValidationResult validation;
  const _ValidationIndicator({required this.validation});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String text;

    switch (validation.status) {
      case ValidationStatus.valid:
        icon = Icons.check_circle_outline;
        color = const Color(0xFF4CAF50);
        text = validation.hint ?? '';
        break;
      case ValidationStatus.incomplete:
        icon = Icons.info_outline;
        color = Colors.grey;
        text = validation.hint ?? '';
        break;
      case ValidationStatus.error:
        icon = Icons.error_outline;
        color = Theme.of(context).colorScheme.error;
        text = validation.hint ?? '';
        break;
      case ValidationStatus.empty:
        return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Banner showing the equivalence result.
class _ResultBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _ResultBanner({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: color.withValues(alpha: 0.85),
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
