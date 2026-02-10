/// Post-processes raw OCR text to produce a valid logical expression.
///
/// OCR engines (Google ML Kit) misread mathematical/logical symbols because
/// they're optimized for natural language. This mapper applies context-aware
/// heuristics to fix common misreadings.
class OcrExpressionMapper {
  OcrExpressionMapper._();

  // Characters accepted as proposition letters (same as TruthTable.alphabet)
  static const _variables =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01';

  /// Map raw OCR text to a logical expression.
  ///
  /// 1. Normalize whitespace
  /// 2. Replace common OCR mis-reads and text representations
  /// 3. Replace ASCII operator shorthands
  /// 4. Strip remaining invalid characters
  /// 5. Return cleaned expression
  static String map(String raw) {
    String s = raw.trim();

    // ── Step 1: Normalize whitespace ──
    s = s.replaceAll(RegExp(r'\s+'), ' ');

    // ── Step 2: Multi-char ASCII sequences → Unicode operators ──
    // Order matters: longer sequences first to avoid partial matches.
    s = s.replaceAll('<->', '⇔');
    s = s.replaceAll('<=>', '⇔');
    s = s.replaceAll('<>', '⇔');
    s = s.replaceAll('->', '⇒');
    s = s.replaceAll('=>', '⇒');
    s = s.replaceAll('→', '⇒');
    s = s.replaceAll('↔', '⇔');
    s = s.replaceAll('NOT', '¬');
    s = s.replaceAll('not', '¬');
    s = s.replaceAll('AND', '∧');
    s = s.replaceAll('and', '∧');
    s = s.replaceAll('OR', '∨');
    s = s.replaceAll('or', '∨');
    s = s.replaceAll('XOR', '⊕');
    s = s.replaceAll('xor', '⊕');
    s = s.replaceAll('NOR', '↓');
    s = s.replaceAll('nor', '↓');
    s = s.replaceAll('NAND', '⊼');
    s = s.replaceAll('nand', '⊼');

    // ── Step 3: Single-char ASCII shorthands ──
    s = s.replaceAll('^', '∧');
    s = s.replaceAll('+', '∨');
    s = s.replaceAll('*', '∧');
    s = s.replaceAll('~', '¬');
    s = s.replaceAll('!', '¬');

    // ── Step 4: Context-aware fixes ──
    // 'v' or 'V' between two single-letter variables → OR  (p v q → p ∨ q)
    s = _fixContextualOR(s);

    // 'A' between two single-letter variables when not itself a variable
    // context → AND (p A q → p ∧ q). Only if surrounded by spaces.
    s = _fixContextualAND(s);

    // Common OCR confusions for negation prefix
    // '-' when it appears before a letter → ¬
    s = s.replaceAllMapped(
      RegExp(r'(?<![a-zA-Z0-9])-(?=[a-zA-Z])'),
      (m) => '¬',
    );

    // ── Step 5: Normalize brackets ──
    s = s.replaceAll('[', '(');
    s = s.replaceAll(']', ')');
    s = s.replaceAll('{', '(');
    s = s.replaceAll('}', ')');

    // ── Step 6: Remove spaces ──
    s = s.replaceAll(' ', '');

    // ── Step 7: Strip remaining invalid characters ──
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final c = s[i];
      if (_isValid(c)) {
        buffer.write(c);
      }
    }

    return buffer.toString();
  }

  /// Fix contextual OR: ` v ` or ` V ` between variables.
  /// "p v q"  → "p ∨ q"
  /// "p V q"  → "p ∨ q"
  static String _fixContextualOR(String s) {
    // Match: (variable or ')') SPACE v/V SPACE (variable or '(' or '¬')
    return s.replaceAllMapped(
      RegExp(r'([a-zA-Z0-9\)]) [vV] ([a-zA-Z0-9\(¬~!])'),
      (m) => '${m[1]} ∨ ${m[2]}',
    );
  }

  /// Fix contextual AND: ` A ` between what looks like variables.
  /// "p A q"  → "p ∧ q"  (only the isolated uppercase A preceded/followed by space)
  static String _fixContextualAND(String s) {
    return s.replaceAllMapped(
      RegExp(r'([a-z0-9\)]) A ([a-z0-9\(¬~!])'),
      (m) => '${m[1]} ∧ ${m[2]}',
    );
  }

  /// Returns true if the character is valid in a logical expression.
  static bool _isValid(String c) {
    if (_variables.contains(c)) return true;
    if (c == '(' || c == ')') return true;
    if (_isOperator(c)) return true;
    return false;
  }

  /// Known operator symbols (matches ExpressionValidator._operators).
  static bool _isOperator(String c) {
    const ops = <String>{
      '¬', '~', '!', // NOT
      '∧', '&', // AND
      '∨', '|', // OR
      '⇒', '⇔', '￩', // conditionals
      '⊕', '⊻', // XOR
      '⊼', // NAND
      '↓', // NOR
      '⇍', '⇏', '⇎', // NOT-conditionals
      '┲', '┹', // tautology / contradiction ops
    };
    return ops.contains(c);
  }
}
