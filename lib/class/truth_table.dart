import 'dart:math';

import 'package:tablas_de_verdad_2025/class/operator.dart';
import 'package:tablas_de_verdad_2025/class/row_table.dart';
import 'package:tablas_de_verdad_2025/class/step_proccess.dart';

// ── Parser error messages (all 10 supported locales) ─────────────────────────

const _kCloseParenthesis = {
  'es': 'Error de sintaxis: falta cerrar el paréntesis',
  'en': 'Syntax error: unclosed parenthesis',
  'pt': 'Erro de sintaxe: parêntese não fechado',
  'fr': 'Erreur de syntaxe : parenthèse non fermée',
  'de': 'Syntaxfehler: Klammer nicht geschlossen',
  'hi': 'वाक्यविन्यास त्रुटि: कोष्ठक बंद नहीं है',
  'ru': 'Синтаксическая ошибка: скобка не закрыта',
  'it': 'Errore di sintassi: parentesi non chiusa',
  'zh': '语法错误：括号未闭合',
  'ja': '構文エラー：括弧が閉じられていません',
};

const _kUncompletedParenthesis = {
  'es': 'Error de paréntesis: cierre sin apertura correspondiente',
  'en': 'Parenthesis error: no matching open bracket',
  'pt': 'Erro de parêntese: fechamento sem abertura correspondente',
  'fr': 'Erreur de parenthèse : fermeture sans ouverture correspondante',
  'de': 'Klammerfehler: schließende Klammer ohne öffnende',
  'hi': 'कोष्ठक त्रुटि: खुले कोष्ठक के बिना बंद कोष्ठक',
  'ru': 'Ошибка скобок: закрывающая без открывающей',
  'it': 'Errore di parentesi: chiusura senza apertura',
  'zh': '括号错误：无对应开括号',
  'ja': '括弧エラー：対応する開き括弧がありません',
};

const _kRequired2Operands = {
  'es': 'requiere 2 operandos',
  'en': 'requires 2 operands',
  'pt': 'requer 2 operandos',
  'fr': 'nécessite 2 opérandes',
  'de': 'benötigt 2 Operanden',
  'hi': '2 संकार्य आवश्यक हैं',
  'ru': 'требует 2 операнда',
  'it': 'richiede 2 operandi',
  'zh': '需要2个操作数',
  'ja': '2つのオペランドが必要です',
};

const _kRequired1Operand = {
  'es': 'requiere 1 operando',
  'en': 'requires 1 operand',
  'pt': 'requer 1 operando',
  'fr': 'nécessite 1 opérande',
  'de': 'benötigt 1 Operanden',
  'hi': '1 संकार्य आवश्यक है',
  'ru': 'требует 1 операнд',
  'it': 'richiede 1 operando',
  'zh': '需要1个操作数',
  'ja': '1つのオペランドが必要です',
};

const _kSyntaxError = {
  'es': 'Error de sintaxis',
  'en': 'Syntax error',
  'pt': 'Erro de sintaxe',
  'fr': 'Erreur de syntaxe',
  'de': 'Syntaxfehler',
  'hi': 'वाक्यविन्यास त्रुटि',
  'ru': 'Синтаксическая ошибка',
  'it': 'Errore di sintassi',
  'zh': '语法错误',
  'ja': '構文エラー',
};

const _kInvalidCharacter = {
  'es': 'Carácter no válido en la expresión',
  'en': 'Invalid character in the expression',
  'pt': 'Caractere inválido na expressão',
  'fr': 'Caractère non valide dans l\'expression',
  'de': 'Ungültiges Zeichen im Ausdruck',
  'hi': 'अभिव्यक्ति में अमान्य वर्ण',
  'ru': 'Недопустимый символ в выражении',
  'it': 'Carattere non valido nell\'espressione',
  'zh': '表达式中有无效字符',
  'ja': '式に無効な文字があります',
};

const _kTooManyVariables = {
  'es': 'Demasiadas variables (máximo {max})',
  'en': 'Too many variables (maximum {max})',
  'pt': 'Muitas variáveis (máximo {max})',
  'fr': 'Trop de variables (maximum {max})',
  'de': 'Zu viele Variablen (maximal {max})',
  'hi': 'बहुत अधिक चर (अधिकतम {max})',
  'ru': 'Слишком много переменных (максимум {max})',
  'it': 'Troppe variabili (massimo {max})',
  'zh': '变量过多（最多 {max} 个）',
  'ja': '変数が多すぎます（最大 {max}）',
};

/// Returns the localized string for [lang], falling back to English.
String _errorMsg(Map<String, String> map, String lang) =>
    map[lang] ?? map['en']!;

/// Upper bound on distinct variables. The table has 2^n rows, so this caps it
/// at 1024 — already huge to read, and keeps the UI/web from freezing on
/// pathological input.
const int kMaxTruthTableVariables = 10;

enum TruthTableType { tautology, contradiction, contingency }

class TruthTable {
  String infix;
  String initialInfix = '';
  String postfix = '';
  int evaluationId = 2;
  static const int contradictionId = 0;
  static const int tautologyId = 1;
  static const int contingencyId = 2;

  final String language;

  int counter1s = 0;
  int counters0s = 0;
  List<String> variables = [];
  List<RowTable> table = [];
  List<String> notOpers = [
    Operators.NOT.value,
    Operators.NOT2.value,
    Operators.NOT3.value,
  ];
  List<String> andOpers = [Operators.AND.value, Operators.AND2.value];
  List<String> orOpers = [Operators.OR.value, Operators.OR2.value];
  List<String> xorOpers = [Operators.XOR.value, Operators.XOR2.value];
  String errorMessage = "";

  /// Column key of the whole expression (the postfix root): a variable name
  /// when there are no operators, otherwise the outermost step's `toString()`.
  String rootKey = '';

  int index0InVariables = -1;
  int index1InVariables = -1;
  List<StepProcess> steps = [];
  Map<String, String> opersHistory = {};
  int keyStepGenerator = 0;
  Map<String, List<String>> columns = {};
  int totalRows = 0;
  List<List<String>> finalTable = [];

  Map<String, int> priorities = {
    "~": 16,
    "!": 15,
    "¬": 15,
    "⊼": 14,
    "⊻": 13,
    "⊕": 12,
    "↓": 11,
    "&": 10,
    "∧": 10,
    "|": 9,
    "∨": 9,
    "⇍": 8,
    "￩": 7,
    "⇏": 6,
    "⇎": 5,
    "┲": 4,
    "┹": 3,
    "⇒": 2,
    "⇔": 1,
    "(": 0,
  };

  String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01";
  TruthTableType tipo = TruthTableType.contingency;

  TruthTable(this.infix, this.language) {
    initialInfix = infix;
    formatInput();
  }

  void formatInput() {
    // Drop all whitespace first: the parser is char-by-char and a space has no
    // priority, so "p ∧ q" would otherwise throw. (The calculator strips
    // spaces in the UI, but other callers — quiz, web paste — do not.)
    infix = infix.replaceAll(RegExp(r'\s+'), '');
    infix = infix.replaceAll('[', '(');
    infix = infix.replaceAll(']', ')');
    infix = infix.replaceAll('{', '(');
    infix = infix.replaceAll('}', ')');
  }

  /// Returns false (with [errorMessage] set) when parsing fails, so [makeAll]
  /// keeps the specific message instead of letting the structural check
  /// overwrite it with a generic syntax error.
  bool convertInfixToPostix() {
    postfix = infixToPostfix(infix);
    return errorMessage.isEmpty;
  }

  void createColumnsForVariables() {
    for (int i = 0; i < variables.length; i++) {
      columns[variables[i]] = [];
    }
  }

  void generateFinalTable() {
    List<String> headers = [...variables];
    finalTable = [];

    for (StepProcess step in steps) {
      headers.add(
        step.isSingleVariable
            ? "${step.operator.value}${StepProcess.displayOperand(step.variable1)}"
            : "${StepProcess.displayOperand(step.variable1)} ${step.operator.value} ${StepProcess.displayOperand(step.variable2)}",
      );
    }

    finalTable.add(headers);

    for (int i = 0; i < totalRows; i++) {
      List<String> row = [];
      for (String variable in variables) {
        row.add(columns[variable]![i]);
      }
      for (StepProcess step in steps) {
        row.add(columns[step.toString()]![i]);
      }
      finalTable.add(row);
    }
  }

  /// True when parsing/validation failed (and [errorMessage] is set).
  bool get hasError => errorMessage.isNotEmpty;

  /// True when the table was built successfully and is ready to read.
  bool get isValid => errorMessage.isEmpty && finalTable.isNotEmpty;

  /// Parses, validates and builds the table. Returns whether it succeeded;
  /// on failure [errorMessage] holds a localized reason and the table fields
  /// stay empty.
  bool makeAll() {
    if (!convertInfixToPostix()) return false; // parse error: message set
    if (variables.length > kMaxTruthTableVariables) {
      errorMessage = _errorMsg(
        _kTooManyVariables,
        language,
      ).replaceAll('{max}', '$kMaxTruthTableVariables');
      return false;
    }
    if (!checkIfIsCorrectlyFormed()) return false;
    calculate();
    return true;
  }

  void calculate() {
    table = [];
    counter1s = 0;
    counters0s = 0;
    variables.sort();
    createColumnsForVariables();

    getSteps(postfix);

    if (variables.contains("0")) {
      index0InVariables = variables.indexOf("0");
    }
    if (variables.contains("1")) {
      index1InVariables = variables.indexOf("1");
    }

    final totalCombinations = pow(2, variables.length).toInt();
    final sizeOfCombinations = (totalCombinations - 1).toRadixString(2).length;
    totalRows = totalCombinations;
    for (int i = totalCombinations - 1; i >= 0; i--) {
      final combination = formatCombination(
        i.toRadixString(2),
        sizeOfCombinations,
      );
      final result = _evaluateRow(combination);
      table.add(
        RowTable(index: i, combination: combination, result: "$result"),
      );
      if (result == 1) {
        counter1s++;
      } else {
        counters0s++;
      }
    }
    if (counter1s == totalCombinations) {
      tipo = TruthTableType.tautology;
      evaluationId = TruthTable.tautologyId;
    } else if (counters0s == totalCombinations) {
      tipo = TruthTableType.contradiction;
      evaluationId = TruthTable.contradictionId;
    } else {
      tipo = TruthTableType.contingency;
      evaluationId = TruthTable.contingencyId;
    }

    generateFinalTable();
  }

  String formatCombination(String combination, int lenght) {
    while (combination.length < lenght) {
      combination = "0$combination";
    }

    if (index0InVariables != -1) {
      combination = combination.replaceRange(
        index0InVariables,
        index0InVariables + 1,
        "0",
      );
    }

    if (index1InVariables != -1) {
      combination = combination.replaceRange(
        index1InVariables,
        index1InVariables + 1,
        "1",
      );
    }

    return combination;
  }

  /// Evaluates every sub-expression for a single row and returns the value of
  /// the whole expression.
  ///
  /// [combination] is a string of '0'/'1', one digit per variable in
  /// [variables] order. Variables are seeded into a value map; then each step
  /// (already in dependency order, children before parents) is evaluated by
  /// looking up its operands — which are either variable names or earlier
  /// steps' `toString()` keys. Each value is appended to its column. Identical
  /// sub-expressions share one column and are written once (the map dedups).
  int _evaluateRow(String combination) {
    final values = <String, int>{};

    for (int i = 0; i < variables.length; i++) {
      final v = int.parse(combination[i]);
      values[variables[i]] = v;
      columns[variables[i]]!.add('$v');
    }

    for (final step in steps) {
      final left = values[step.variable1]!;
      final result =
          step.isSingleVariable
              ? not(left)
              : _applyBinary(step.operator, left, values[step.variable2]!);
      values[step.toString()] = result;
      columns[step.toString()]!.add('$result');
    }

    return values[rootKey] ?? 0;
  }

  /// Applies a binary [op] to its [left] and [right] operand values. Mirrors
  /// the operand order used when building steps (variable1 = left).
  int _applyBinary(Operator op, int left, int right) {
    final v = op.value;
    if (orOpers.contains(v)) return or(left, right);
    if (andOpers.contains(v)) return and(left, right);
    if (xorOpers.contains(v)) return xor(left, right);
    if (v == Operators.CODICIONAL.value) return condicional(left, right);
    if (v == Operators.BICODICIONAL.value) return bicondicional(left, right);
    if (v == Operators.NOR.value) return nor(left, right);
    if (v == Operators.NAND.value) return nand(left, right);
    if (v == Operators.ANTICODICIONAL.value) return replicador(left, right);
    if (v == Operators.NOT_CONDITIONAL.value) {
      return not(condicional(left, right));
    }
    if (v == Operators.NOT_CONDITIONAL_INVERSE.value) {
      return not(replicador(left, right));
    }
    if (v == Operators.NOT_BICONDITIONAL.value) {
      return not(bicondicional(left, right));
    }
    if (v == Operators.TAUTOLOGY.value) return 1;
    if (v == Operators.CONTRADICTION.value) return 0;
    return 0; // unreachable for validated operators
  }

  int replicador(int a, int b) {
    if (a == 0 && b == 1) return 0;
    return 1;
  }

  int or(int a, int b) {
    if (a == 1 || b == 1) return 1;
    return 0;
  }

  int and(int a, int b) {
    if (a == 1 && b == 1) return 1;
    return 0;
  }

  int not(int a) {
    if (a == 1) return 0;
    return 1;
  }

  int xor(int a, int b) {
    if (a == b) return 0;
    return 1;
  }

  int nand(int a, int b) {
    return not(and(a, b));
  }

  int nor(int a, int b) {
    return not(or(a, b));
  }

  int condicional(int a, int b) {
    if (a == 1 && b == 0) return 0;
    return 1;
  }

  int bicondicional(int a, int b) {
    if (a == b) return 1;
    return 0;
  }

  String infixToPostfix(String infix) {
    List<String> opStack = [];
    List<String> postfixList = [];

    for (String token in infix.split("")) {
      if (alphabet.contains(token)) {
        postfixList.add(token);
        if (!variables.contains(token)) {
          variables.add(token);
        }
      } else if (token == "(") {
        opStack.add(token);
      } else if (token == ")") {
        if (opStack.isEmpty) {
          errorMessage = _errorMsg(_kUncompletedParenthesis, language);
          return '';
        }
        String topToken = opStack.removeLast();

        while (topToken != "(") {
          postfixList.add(topToken);

          if (opStack.isEmpty) {
            errorMessage = _errorMsg(_kUncompletedParenthesis, language);
            return '';
          }

          topToken = opStack.removeLast();
        }
      } else {
        // Operator token. Anything not in `priorities` is an unknown character
        // (stray punctuation, an unsupported digit, an emoji, …) — fail with a
        // friendly message instead of a null-check crash.
        if (!priorities.containsKey(token)) {
          errorMessage = _errorMsg(_kInvalidCharacter, language);
          return '';
        }
        while (opStack.isNotEmpty &&
            priorities[opStack.last]! > priorities[token]!) {
          postfixList.add(opStack.removeLast());
        }
        opStack.add(token);
      }
    }

    while (opStack.isNotEmpty) {
      String last = opStack.removeLast();
      if (last == "(") {
        errorMessage = _errorMsg(_kCloseParenthesis, language);
        return '';
      }
      postfixList.add(last);
    }
    return postfixList.join();
  }

  bool checkIfIsCorrectlyFormed() {
    List<String> pila = [];
    /* print("Postfija: $postfix"); */
    for (String c in postfix.split("")) {
      if (isOperator(c)) {
        if (pila.isEmpty) {
          if (required2Operators(c)) {
            errorMessage = "$c: ${_errorMsg(_kRequired2Operands, language)}";
          } else {
            errorMessage = "$c: ${_errorMsg(_kRequired1Operand, language)}";
          }
          return false;
        }
        pila.removeLast();
        String resultado = '';
        if (required2Operators(c)) {
          if (pila.isEmpty) {
            errorMessage = "$c: ${_errorMsg(_kRequired2Operands, language)}";
            return false;
          }
          pila.removeLast();
          resultado = "0";
        } else if (notOpers.contains(c)) {
          resultado = "9";
        }
        pila.add(resultado);
      } else {
        pila.add(c);
      }
    }
    if (pila.length == 1) {
      return true;
    } else {
      errorMessage = _errorMsg(_kSyntaxError, language);
      return false;
    }
  }

  bool required2Operators(String operator) {
    if (notOpers.contains(operator)) return false;
    return true;
  }

  bool isOperator(String val) {
    if ("$alphabet()[]{}".contains(val)) return false;
    return true;
  }

  Operator? getCurrentOperFromString(String oper) {
    if (oper == Operators.OR.value) return Operators.OR;
    if (oper == Operators.OR2.value) return Operators.OR2;

    if (oper == Operators.AND.value) return Operators.AND;
    if (oper == Operators.AND2.value) return Operators.AND2;

    if (oper == Operators.NOT.value) return Operators.NOT;
    if (oper == Operators.NOT2.value) return Operators.NOT2;
    if (oper == Operators.NOT3.value) return Operators.NOT3;

    if (oper == Operators.XOR.value) return Operators.XOR;
    if (oper == Operators.XOR2.value) return Operators.XOR2;

    return null;
  }

  bool _stepExists(StepProcess step) {
    for (final s in steps) {
      if (s.toString() == step.toString()) return true;
    }
    return false;
  }

  /// Registers a distinct sub-expression as a column. Identical
  /// sub-expressions (same `toString()`) share a single column.
  void _addStep(StepProcess step) {
    if (!_stepExists(step)) {
      columns[step.toString()] = [];
      steps.add(step);
    }
  }

  void getSteps(String postfija) {
    List<String> stack = [];
    steps = [];
    for (String c in postfija.split("")) {
      Operator currentOper = Operators.AND;
      if (alphabet.contains(c)) {
        stack.add(c);
      } else {
        String a, b;
        a = stack.removeLast();
        StepProcess s;
        if (notOpers.contains(c)) {
          currentOper = getCurrentOperFromString(c)!;
          s = StepProcess(
            operator: currentOper,
            variable1: a,
            isSingleVariable: true,
            variable2: '',
          );
        } else {
          b = stack.removeLast();
          if (orOpers.contains(c)) {
            currentOper = getCurrentOperFromString(c)!;
          } else if (andOpers.contains(c)) {
            currentOper = getCurrentOperFromString(c)!;
          } else if (c == Operators.CODICIONAL.value) {
            currentOper = Operators.CODICIONAL;
          } else if (c == Operators.BICODICIONAL.value) {
            currentOper = Operators.BICODICIONAL;
          } else if (c == Operators.NOR.value) {
            currentOper = Operators.NOR;
          } else if (c == Operators.NAND.value) {
            currentOper = Operators.NAND;
          } else if (xorOpers.contains(c)) {
            currentOper = getCurrentOperFromString(c)!;
          } else if (c == Operators.ANTICODICIONAL.value) {
            currentOper = Operators.ANTICODICIONAL;
          } else if (c == Operators.NOT_CONDITIONAL.value) {
            currentOper = Operators.NOT_CONDITIONAL;
          } else if (c == Operators.NOT_CONDITIONAL_INVERSE.value) {
            currentOper = Operators.NOT_CONDITIONAL_INVERSE;
          } else if (c == Operators.NOT_BICONDITIONAL.value) {
            currentOper = Operators.NOT_BICONDITIONAL;
          } else if (c == Operators.TAUTOLOGY.value) {
            currentOper = Operators.TAUTOLOGY;
          } else if (c == Operators.CONTRADICTION.value) {
            currentOper = Operators.CONTRADICTION;
          }
          // ignore: unnecessary_new

          s = StepProcess(operator: currentOper, variable1: b, variable2: a);
        }
        _addStep(s);
        stack.add(s.toString());
      }
    }
    // The lone remaining token is the whole expression's column key (a step's
    // toString, or a bare variable/constant when there are no operators).
    rootKey = stack.isNotEmpty ? stack.last : '';
  }
}
