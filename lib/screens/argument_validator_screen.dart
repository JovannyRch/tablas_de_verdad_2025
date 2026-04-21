import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/utils/expression_validator.dart';
import 'package:tablas_de_verdad_2025/utils/ghost_text_controller.dart';
import 'package:tablas_de_verdad_2025/const/calculator.dart';
import 'package:tablas_de_verdad_2025/widget/keypad.dart';

// ─── Data model ──────────────────────────────────────────────────────────────

class ArgumentResult {
  final bool isValid;
  final List<String> variables;
  final List<List<String>> counterexamples;

  const ArgumentResult({
    required this.isValid,
    required this.variables,
    required this.counterexamples,
  });
}

// ─── Logic ───────────────────────────────────────────────────────────────────

ArgumentResult _validateArgument(
  List<String> premises,
  String conclusion,
  String language,
  TruthFormat format,
) {
  // Build: (P1)∧(P2)∧...∧(Pn)⇒(C)
  final premisesJoined = premises.map((p) => '($p)').join('∧');
  final combined = '($premisesJoined)⇒($conclusion)';

  final tt = TruthTable(combined, language, format);
  tt.makeAll();

  if (tt.tipo == TruthTableType.tautology) {
    return ArgumentResult(isValid: true, variables: tt.variables, counterexamples: []);
  }

  // Find counterexamples: rows where combined result = "0"
  // finalTable[0] = headers, finalTable[i>0] = data rows, last column = result
  final counterexamples = <List<String>>[];
  for (int i = 1; i < tt.finalTable.length; i++) {
    final row = tt.finalTable[i];
    if (row.last == '0') {
      counterexamples.add(row.sublist(0, tt.variables.length));
    }
  }

  return ArgumentResult(
    isValid: false,
    variables: tt.variables,
    counterexamples: counterexamples,
  );
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class ArgumentValidatorScreen extends StatefulWidget {
  const ArgumentValidatorScreen({super.key});

  @override
  State<ArgumentValidatorScreen> createState() => _ArgumentValidatorScreenState();
}

class _ArgumentValidatorScreenState extends State<ArgumentValidatorScreen> {
  final List<GhostTextEditingController> _premiseControllers = [
    GhostTextEditingController(),
    GhostTextEditingController(),
  ];
  final List<FocusNode> _premiseFocusNodes = [FocusNode(), FocusNode()];
  final _conclusionController = GhostTextEditingController();
  final _conclusionFocusNode = FocusNode();

  // -1 = conclusion active, 0..n-1 = premise index active
  int _activeIndex = 0;
  Case _case = Case.lower;

  List<ValidationResult> _premiseValidations = [
    const ValidationResult(ValidationStatus.empty),
    const ValidationResult(ValidationStatus.empty),
  ];
  ValidationResult _conclusionValidation = const ValidationResult(ValidationStatus.empty);

  ArgumentResult? _result;
  bool _isComputing = false;
  bool _keypadVisible = true;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _premiseFocusNodes.length; i++) {
      final idx = i;
      _premiseFocusNodes[idx].addListener(() {
        if (_premiseFocusNodes[idx].hasFocus) setState(() => _activeIndex = idx);
      });
      _premiseControllers[idx].addListener(() => _validatePremise(idx));
    }
    _conclusionFocusNode.addListener(() {
      if (_conclusionFocusNode.hasFocus) setState(() => _activeIndex = -1);
    });
    _conclusionController.addListener(_validateConclusion);
  }

  @override
  void dispose() {
    for (final c in _premiseControllers) c.dispose();
    for (final f in _premiseFocusNodes) f.dispose();
    _conclusionController.dispose();
    _conclusionFocusNode.dispose();
    super.dispose();
  }

  void _validatePremise(int index) {
    if (!mounted) return;
    final t = AppLocalizations.of(context)!;
    final result = ExpressionValidator.validate(
      _premiseControllers[index].text,
      validationMsgUnmatched: t.validationUnmatched,
      validationMsgMissingOperand: t.validationMissingOperand,
      validationMsgMissingOperator: t.validationMissingOperator,
      validationMsgTrailingOp: t.validationTrailingOp,
      validationMsgValid: t.validationValid,
    );
    setState(() {
      _premiseValidations[index] = result;
      _result = null;
    });
  }

  void _validateConclusion() {
    if (!mounted) return;
    final t = AppLocalizations.of(context)!;
    setState(() {
      _conclusionValidation = ExpressionValidator.validate(
        _conclusionController.text,
        validationMsgUnmatched: t.validationUnmatched,
        validationMsgMissingOperand: t.validationMissingOperand,
        validationMsgMissingOperator: t.validationMissingOperator,
        validationMsgTrailingOp: t.validationTrailingOp,
        validationMsgValid: t.validationValid,
      );
      _result = null;
    });
  }

  bool get _canValidate {
    if (_isComputing) return false;
    if (!_conclusionValidation.isValid) return false;
    return _premiseValidations.every((v) => v.isValid);
  }

  void _addPremise() {
    final newController = GhostTextEditingController();
    final newFocus = FocusNode();
    final newIndex = _premiseControllers.length;

    newFocus.addListener(() {
      if (newFocus.hasFocus) setState(() => _activeIndex = newIndex);
    });
    newController.addListener(() => _validatePremise(newIndex));

    setState(() {
      _premiseControllers.add(newController);
      _premiseFocusNodes.add(newFocus);
      _premiseValidations.add(const ValidationResult(ValidationStatus.empty));
      _activeIndex = newIndex;
      _result = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      newFocus.requestFocus();
    });
  }

  void _removePremise(int index) {
    if (_premiseControllers.length <= 1) return;
    _premiseControllers[index].dispose();
    _premiseFocusNodes[index].dispose();
    setState(() {
      _premiseControllers.removeAt(index);
      _premiseFocusNodes.removeAt(index);
      _premiseValidations.removeAt(index);
      _activeIndex = 0;
      _result = null;
    });
  }

  void _runValidation() {
    final settings = context.read<Settings>();
    setState(() => _isComputing = true);

    final premises = _premiseControllers.map((c) => c.text).toList();
    final conclusion = _conclusionController.text;

    final result = _validateArgument(
      premises,
      conclusion,
      settings.locale.languageCode,
      settings.truthFormat,
    );

    setState(() {
      _result = result;
      _isComputing = false;
      _keypadVisible = false;
    });
  }

  GhostTextEditingController get _activeController {
    if (_activeIndex == -1) return _conclusionController;
    if (_activeIndex < _premiseControllers.length) return _premiseControllers[_activeIndex];
    return _conclusionController;
  }

  void _insertText(String text) {
    final controller = _activeController;
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
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
    }
  }

  void _backspace() {
    final controller = _activeController;
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
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
    }
  }

  void _clearActive() => _activeController.clear();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(t.argumentValidator), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Premises ──────────────────────────────
                  ...List.generate(_premiseControllers.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ExpressionField(
                        label: '${t.premise} ${i + 1}',
                        controller: _premiseControllers[i],
                        focusNode: _premiseFocusNodes[i],
                        validation: _premiseValidations[i],
                        isActive: _activeIndex == i,
                        isDark: isDark,
                        onTap: () {
                          setState(() { _activeIndex = i; _keypadVisible = true; });
                          _premiseFocusNodes[i].requestFocus();
                        },
                        onRemove: _premiseControllers.length > 1
                            ? () => _removePremise(i)
                            : null,
                        removeLabel: t.removePremise,
                      ),
                    );
                  }),

                  // ── Add premise button ─────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _addPremise,
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                      label: Text(t.addPremise),
                      style: TextButton.styleFrom(foregroundColor: kSeedColor),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.arrow_downward_rounded, size: 18, color: Colors.grey),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ),

                  // ── Conclusion ────────────────────────────
                  _ExpressionField(
                    label: t.conclusionLabel,
                    controller: _conclusionController,
                    focusNode: _conclusionFocusNode,
                    validation: _conclusionValidation,
                    isActive: _activeIndex == -1,
                    isDark: isDark,
                    isConclusion: true,
                    onTap: () {
                      setState(() { _activeIndex = -1; _keypadVisible = true; });
                      _conclusionFocusNode.requestFocus();
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Validate button ────────────────────────
                  FilledButton.icon(
                    onPressed: _canValidate ? _runValidation : null,
                    icon: _isComputing
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.rule_rounded),
                    label: Text(t.validateArgument),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),

                  // ── Result ────────────────────────────────
                  if (_result != null) ...[
                    const SizedBox(height: 20),
                    _ResultCard(result: _result!, isDark: isDark),
                  ],

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Keypad ────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            height: _keypadVisible
                ? MediaQuery.of(context).size.height * 0.42
                : 0,
            child: ClipRect(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.42,
                child: TruthKeypad(
                  onTap: (key) {
                    final piece = _case == Case.lower
                        ? key.toLowerCase()
                        : key.toUpperCase();
                    _insertText(piece);
                  },
                  onBackspace: _backspace,
                  onClear: _clearActive,
                  onEvaluate: _canValidate ? _runValidation : () {},
                  onToggleAa: () => setState(() {
                    _case = _case == Case.lower ? Case.upper : Case.lower;
                  }),
                  calculatorCase: _case,
                  hideActionButtons: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Expression field widget ─────────────────────────────────────────────────

class _ExpressionField extends StatelessWidget {
  final String label;
  final GhostTextEditingController controller;
  final FocusNode focusNode;
  final ValidationResult validation;
  final bool isActive;
  final bool isDark;
  final bool isConclusion;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final String? removeLabel;

  const _ExpressionField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.validation,
    required this.isActive,
    required this.isDark,
    required this.onTap,
    this.isConclusion = false,
    this.onRemove,
    this.removeLabel,
  });

  Color get _borderColor {
    if (!isActive) return Colors.transparent;
    return switch (validation.status) {
      ValidationStatus.valid => Colors.green,
      ValidationStatus.error => Colors.red,
      _ => kSeedColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 0),
              child: Row(
                children: [
                  if (isConclusion)
                    Icon(Icons.arrow_downward_rounded, size: 14,
                        color: isDark ? Colors.white54 : Colors.black45),
                  if (isConclusion) const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isConclusion
                          ? kSeedColor
                          : (isDark ? Colors.white54 : Colors.black45),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  if (onRemove != null)
                    TextButton(
                      onPressed: onRemove,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(removeLabel ?? '', style: const TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),
            TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.none,
              showCursor: true,
              readOnly: false,
              autocorrect: false,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
                fontFamily: 'Courier',
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                border: InputBorder.none,
                hintText: '...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white24 : Colors.black26,
                  fontSize: 22,
                ),
              ),
              onTap: onTap,
            ),
            if (isActive && validation.hint != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Text(
                  validation.hint!,
                  style: TextStyle(
                    fontSize: 11,
                    color: switch (validation.status) {
                      ValidationStatus.valid => Colors.green,
                      ValidationStatus.error => Colors.redAccent,
                      _ => isDark ? Colors.white38 : Colors.black38,
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Result card widget ──────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final ArgumentResult result;
  final bool isDark;

  const _ResultCard({required this.result, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isValid = result.isValid;
    final color = isValid ? Colors.green : Colors.redAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Banner ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: color,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                isValid ? t.validArgument : t.invalidArgument,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isValid ? t.validArgumentDesc : t.invalidArgumentDesc,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // ── Counterexamples table ──────────────────────────
        if (!isValid && result.counterexamples.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            t.counterexamples,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 32,
                columnSpacing: 24,
                headingTextStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                dataTextStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
                columns: result.variables
                    .map((v) => DataColumn(label: Text(v)))
                    .toList(),
                rows: result.counterexamples
                    .map(
                      (row) => DataRow(
                        cells: row
                            .map((cell) => DataCell(Text(cell)))
                            .toList(),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
