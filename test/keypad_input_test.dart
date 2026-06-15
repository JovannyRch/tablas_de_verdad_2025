import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tablas_de_verdad_2025/const/calculator.dart';
import 'package:tablas_de_verdad_2025/utils/keypad_input.dart';

void main() {
  TextEditingValue insert(
    String text,
    TextSelection selection,
    String piece, {
    Case keyboardCase = Case.lower,
  }) {
    return KeypadInput.insert(
      text: text,
      selection: selection,
      rawPiece: piece,
      keyboardCase: keyboardCase,
    );
  }

  group('smart parentheses', () {
    test('wraps a non-empty selection in parentheses', () {
      final result = insert(
        'p∧q',
        const TextSelection(baseOffset: 0, extentOffset: 3),
        '(',
      );
      expect(result.text, '(p∧q)');
      // Caret lands right after the closing parenthesis.
      expect(result.selection.baseOffset, 5);
      expect(result.selection.isCollapsed, true);
    });

    test('wraps only the selected sub-range, leaving the rest intact', () {
      // Select "q∨r" inside "p∧q∨r∧s" (offsets 2..5).
      final result = insert(
        'p∧q∨r∧s',
        const TextSelection(baseOffset: 2, extentOffset: 5),
        '(',
      );
      expect(result.text, 'p∧(q∨r)∧s');
      expect(result.selection.baseOffset, 7); // after the ')'
    });

    test('inserts a literal "(" when the selection is collapsed', () {
      final result = insert(
        'pq',
        const TextSelection.collapsed(offset: 1),
        '(',
      );
      expect(result.text, 'p(q');
      expect(result.selection.baseOffset, 2);
    });
  });

  group('plain insertion', () {
    test('replaces a selected range with the pressed key', () {
      final result = insert(
        'p∧q',
        const TextSelection(baseOffset: 0, extentOffset: 3),
        'r',
      );
      expect(result.text, 'r');
      expect(result.selection.baseOffset, 1);
    });

    test('appends at a collapsed caret', () {
      final result = insert(
        'p∧',
        const TextSelection.collapsed(offset: 2),
        'q',
      );
      expect(result.text, 'p∧q');
      expect(result.selection.baseOffset, 3);
    });

    test('uppercases the inserted operand when keyboard case is upper', () {
      final result = insert(
        '',
        const TextSelection.collapsed(offset: 0),
        'p',
        keyboardCase: Case.upper,
      );
      expect(result.text, 'P');
    });

    test('falls back to end-of-text when the selection is invalid', () {
      final result = insert(
        'pq',
        const TextSelection.collapsed(offset: -1),
        'r',
      );
      expect(result.text, 'pqr');
      expect(result.selection.baseOffset, 3);
    });
  });
}
