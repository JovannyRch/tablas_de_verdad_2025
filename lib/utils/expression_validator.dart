/// Lightweight real-time expression validator for the calculator input.
///
/// Validates syntax without computing a full truth table. Returns a
/// [ValidationResult] with the status and a user-facing hint.
class ValidationResult {
  final ValidationStatus status;
  final String? hint;

  const ValidationResult(this.status, [this.hint]);

  bool get isValid => status == ValidationStatus.valid;
  bool get isEmpty => status == ValidationStatus.empty;
  bool get hasError => status == ValidationStatus.error;
  bool get isIncomplete => status == ValidationStatus.incomplete;
}

enum ValidationStatus { empty, valid, incomplete, error }

class ExpressionValidator {
  ExpressionValidator._();

  // Characters accepted as proposition letters
  static const _alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01';

  // All valid operator symbols (same set as TruthTable.priorities keys)
  static const _operators = <String>{
    '~', '!', '¬', // NOT
    '∧', '&', // AND
    '∨', '|', // OR
    '⇒', '⇔', '￩', // conditionals
    '⊕', '⊻', // XOR
    '⊼', // NAND
    '↓', // NOR
    '⇍', '⇏', '⇎', // NOT-conditionals
    '┲', '┹', // tautology / contradiction ops
  };

  static const _openBrackets = {'(', '[', '{'};
  static const _closeBrackets = {')', ']', '}'};
  static const _notOperators = {'~', '!', '¬'};

  // Map close bracket to its matching open bracket
  static const _matchingOpen = {')': '(', ']': '[', '}': '{'};

  /// Validate [expression] and return a result.
  ///
  /// [validationMsgEmpty] – placeholder when empty
  /// [validationMsgUnmatched] – unmatched parentheses
  /// [validationMsgMissingOperand] – operator missing operand
  /// [validationMsgMissingOperator] – two variables without operator
  /// [validationMsgTrailingOp] – trailing binary operator
  /// [validationMsgValid] – expression looks good
  static ValidationResult validate(
    String expression, {
    required String validationMsgUnmatched,
    required String validationMsgMissingOperand,
    required String validationMsgMissingOperator,
    required String validationMsgTrailingOp,
    required String validationMsgValid,
  }) {
    if (expression.isEmpty) {
      return const ValidationResult(ValidationStatus.empty);
    }

    // Clean spaces
    expression = expression.replaceAll(' ', '');

    if (expression.isEmpty) {
      return const ValidationResult(ValidationStatus.empty);
    }

    // Normalize: replace [ ] { } with ( )
    final normalized = expression
        .replaceAll('[', '(')
        .replaceAll(']', ')')
        .replaceAll('{', '(')
        .replaceAll('}', ')');

    // ─── 1. Check for invalid characters ───
    for (int i = 0; i < normalized.length; i++) {
      final c = normalized[i];
      if (!_isVariable(c) && !_isOperator(c) && c != '(' && c != ')') {
        return ValidationResult(ValidationStatus.error, "'$c' ?");
      }
    }

    // ─── 2. Bracket matching ───
    final bracketStack = <String>[];
    for (int i = 0; i < expression.length; i++) {
      final c = expression[i];
      if (_openBrackets.contains(c)) {
        bracketStack.add(c);
      } else if (_closeBrackets.contains(c)) {
        if (bracketStack.isEmpty || bracketStack.last != _matchingOpen[c]) {
          return ValidationResult(
            ValidationStatus.error,
            validationMsgUnmatched,
          );
        }
        bracketStack.removeLast();
      }
    }

    // Unclosed brackets → incomplete (user may still be typing)
    if (bracketStack.isNotEmpty) {
      return ValidationResult(
        ValidationStatus.incomplete,
        '${bracketStack.length}× )',
      );
    }

    // ─── 3. Structural checks (token-level) ───
    // Walk through tokens and check adjacency rules.
    // States: expectOperand (after operator or start), expectOperator (after operand)
    var expectOperand = true;
    var hasVariable = false;

    for (int i = 0; i < normalized.length; i++) {
      final c = normalized[i];

      if (c == '(') {
        expectOperand = true;
        continue;
      }

      if (c == ')') {
        if (expectOperand) {
          // Empty parens or trailing operator inside
          return ValidationResult(
            ValidationStatus.error,
            validationMsgMissingOperand,
          );
        }
        // After ')' we expect an operator
        expectOperand = false;
        continue;
      }

      if (_isNotOperator(c)) {
        // NOT is a unary prefix operator – always allowed where we expect an operand
        if (!expectOperand) {
          // Two operands in a row: `p ¬q` → missing binary operator
          return ValidationResult(
            ValidationStatus.error,
            validationMsgMissingOperator,
          );
        }
        // Still expect an operand after NOT
        continue;
      }

      if (_isBinaryOperator(c)) {
        if (expectOperand) {
          // Operator at start or after another operator
          return ValidationResult(
            ValidationStatus.error,
            validationMsgMissingOperand,
          );
        }
        expectOperand = true;
        continue;
      }

      if (_isVariable(c)) {
        if (!expectOperand) {
          // Two operands with no operator between
          return ValidationResult(
            ValidationStatus.error,
            validationMsgMissingOperator,
          );
        }
        expectOperand = false;
        hasVariable = true;
        continue;
      }
    }

    // If we end expecting an operand, expression is incomplete
    if (expectOperand) {
      if (!hasVariable) {
        return const ValidationResult(ValidationStatus.empty);
      }
      return ValidationResult(
        ValidationStatus.incomplete,
        validationMsgTrailingOp,
      );
    }

    // ─── 4. All checks passed ───
    return ValidationResult(ValidationStatus.valid, validationMsgValid);
  }

  static bool _isVariable(String c) => _alphabet.contains(c);
  static bool _isOperator(String c) => _operators.contains(c);
  static bool _isNotOperator(String c) => _notOperators.contains(c);
  static bool _isBinaryOperator(String c) =>
      _operators.contains(c) && !_notOperators.contains(c);
}
