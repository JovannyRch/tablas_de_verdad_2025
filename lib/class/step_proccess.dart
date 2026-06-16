import 'package:tablas_de_verdad_2025/class/operator.dart';

class StepProcess {
  String variable1;
  String variable2 = "";
  Operator operator;
  bool isSingleVariable;

  StepProcess({
    required this.variable1,
    required this.variable2,
    required this.operator,
    this.isSingleVariable = false,
  });

  /// Binary operator characters. An operand containing one of these at
  /// parenthesis depth 0 is compound and must be wrapped in parentheses
  /// when composed into a larger expression, otherwise headers like
  /// `p ⇒ q ∧ q ⇒ p` misrepresent `(p ⇒ q) ∧ (q ⇒ p)`.
  static const String _binaryOperators = "∧&∨|⇒⇔⊻⊕⊼↓⇍￩⇏⇎┹┲";

  /// Wraps [operand] in parentheses when it is a compound expression
  /// (contains a top-level binary operator). Atomic operands (`p`, `¬p`,
  /// `¬(p∧q)`) are returned unchanged.
  static String wrapOperand(String operand) {
    int depth = 0;
    for (final char in operand.split('')) {
      if (char == '(') {
        depth++;
      } else if (char == ')') {
        depth--;
      } else if (depth == 0 && _binaryOperators.contains(char)) {
        return "($operand)";
      }
    }
    return operand;
  }

  /// Display version of [wrapOperand]: also surrounds inner binary
  /// operators with spaces, so composed headers read uniformly,
  /// e.g. `(p ⇒ q) ∧ (q ⇒ p)`.
  static String displayOperand(String operand) {
    final wrapped = wrapOperand(operand);
    final buffer = StringBuffer();
    for (final char in wrapped.split('')) {
      buffer.write(_binaryOperators.contains(char) ? ' $char ' : char);
    }
    return buffer.toString();
  }

  @override
  String toString() {
    if (isSingleVariable) {
      return "${operator.value}${wrapOperand(variable1)}";
    }
    return "${wrapOperand(variable1)}${operator.value}${wrapOperand(variable2)}";
  }
}
