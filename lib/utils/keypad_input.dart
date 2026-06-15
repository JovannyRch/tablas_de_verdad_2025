import 'package:flutter/widgets.dart' show TextEditingValue, TextSelection;

import 'package:tablas_de_verdad_2025/const/calculator.dart' show Case;

/// Pure text-editing logic for the calculator keypad, extracted from the
/// screen so it can be unit-tested without a widget tree.
class KeypadInput {
  /// Computes the editing value produced by inserting [rawPiece] into [text]
  /// at [selection].
  ///
  /// Smart parentheses: pressing `(` while a non-empty range is selected wraps
  /// that range in parentheses (e.g. `p∧q` → `(p∧q)`) and places the caret
  /// after the closing parenthesis, instead of replacing the selection.
  /// Otherwise the selection (possibly empty) is replaced by [rawPiece],
  /// cased according to [keyboardCase].
  static TextEditingValue insert({
    required String text,
    required TextSelection selection,
    required String rawPiece,
    required Case keyboardCase,
  }) {
    var sel = selection;
    if (!sel.isValid || sel.start < 0 || sel.end < 0) {
      sel = TextSelection.collapsed(offset: text.length);
    }

    if (rawPiece == '(' && sel.start != sel.end) {
      final selected = text.substring(sel.start, sel.end);
      final newText = text.replaceRange(sel.start, sel.end, '($selected)');
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: sel.start + selected.length + 2,
        ),
      );
    }

    final piece =
        keyboardCase == Case.lower
            ? rawPiece.toLowerCase()
            : rawPiece.toUpperCase();
    final newText = text.replaceRange(sel.start, sel.end, piece);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: sel.start + piece.length),
    );
  }
}
