import 'dart:math';

import 'package:tablas_de_verdad_2025/class/operator.dart';
import 'package:tablas_de_verdad_2025/class/row_table.dart';
import 'package:tablas_de_verdad_2025/class/step_proccess.dart';
import 'package:tablas_de_verdad_2025/const/translations.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';

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
  final TruthFormat format;

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

  List<int> statesSteps = [];

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

  TruthTable(this.infix, this.language, this.format) {
    initialInfix = infix;
    formatInput();
  }

  void formatInput() {
    infix = infix.replaceAll('[', '(');
    infix = infix.replaceAll(']', ')');
    infix = infix.replaceAll('{', '(');
    infix = infix.replaceAll('}', ')');
  }

  bool convertInfixToPostix() {
    postfix = infixToPostfix(infix);
    return true;
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
            ? "${step.operator.value}${step.variable1}"
            : "${step.variable1} ${step.operator.value} ${step.variable2}",
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

  void makeAll() {
    if (convertInfixToPostix()) {
      if (checkIfIsCorrectlyFormed()) {
        calculate();
      }
    }
  }

  void calculate() {
    table = [];
    counter1s = 0;
    counters0s = 0;
    variables.sort();
    createColumnsForVariables();

    StepProcess.currentIndex = variables.length - 1;
    StepProcess.labelIndex = 0;
    //Get steps
    getSteps(postfix);

    if (variables.contains("0")) {
      index0InVariables = variables.indexOf("0");
    }

    if (variables.contains("1")) {
      index1InVariables = variables.indexOf("1");
    }

    int totalCombinations = pow(2, variables.length).toInt();
    int sizeOfCombinations = (totalCombinations - 1).toRadixString(2).length;
    totalRows = totalCombinations;
    for (int i = totalCombinations - 1; i >= 0; i--) {
      String combination = i.toRadixString(2);
      combination = formatCombination(combination, sizeOfCombinations);
      String combinationInPostfix = varSubstitutions(postfix, combination);
      int result = evaluation(combinationInPostfix);
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

  int evaluation(combination) {
    List<String> stack = [];
    List<String> stepsKeys = columns.keys.toList().sublist(variables.length);

    int counterSteps = 0;
    for (String c in combination.split("")) {
      if ("01".contains(c)) {
        stack.add(c);
      } else {
        int resultado = 0;
        int a, b;
        a = int.parse(stack.removeLast());
        if (notOpers.contains(c)) {
          resultado = not(a);
        } else {
          b = int.parse(stack.removeLast());
          if (orOpers.contains(c)) {
            resultado = or(b, a);
          } else if (andOpers.contains(c)) {
            resultado = and(b, a);
          } else if (c == Operators.CODICIONAL.value) {
            resultado = condicional(b, a);
          } else if (c == Operators.BICODICIONAL.value) {
            resultado = bicondicional(b, a);
          } else if (c == Operators.NOR.value) {
            resultado = nor(b, a);
          } else if (c == Operators.NAND.value) {
            resultado = nand(b, a);
          } else if (xorOpers.contains(c)) {
            resultado = xor(b, a);
          } else if (c == Operators.ANTICODICIONAL.value) {
            resultado = replicador(b, a);
          } else if (c == Operators.NOT_CONDITIONAL.value) {
            resultado = not(condicional(b, a));
          } else if (c == Operators.NOT_CONDITIONAL_INVERSE.value) {
            resultado = not(replicador(b, a));
          } else if (c == Operators.NOT_BICONDITIONAL.value) {
            resultado = not(bicondicional(b, a));
          } else if (c == Operators.TAUTOLOGY.value) {
            resultado = 1;
          } else if (c == Operators.CONTRADICTION.value) {
            resultado = 0;
          }
        }
        stack.add("$resultado");
        if (columns.containsKey(stepsKeys[statesSteps[counterSteps] - 1])) {
          columns[stepsKeys[statesSteps[counterSteps] - 1]]?.add("$resultado");
          counterSteps++;
        }
      }
    }

    return int.parse(stack.last);
  }

  int replicador(int a, int b) {
    if (a == 0 && b == 1) return 0;
    return 1;
  }

  int tautologia(int a, int b) {
    return 1;
  }

  int contradiccion(int a, int b) {
    return 0;
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

  int xnor(int a, int b) {
    return not(xor(a, b));
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

  String varSubstitutions(String postfix, String combination) {
    for (int i = 0; i < variables.length; i++) {
      String val = combination[i];
      String variable = variables[i];
      columns[variable]?.add(val);
      postfix = postfix.replaceAll(variable, val);
    }
    return postfix;
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
          errorMessage = UNCOMPLETED_PARENTHESIS[language]!;
          return '';
        }
        String topToken = opStack.removeLast();

        while (topToken != "(") {
          postfixList.add(topToken);

          if (opStack.isEmpty) {
            errorMessage = UNCOMPLETED_PARENTHESIS[language]!;
            return '';
          }

          topToken = opStack.removeLast();
        }
      } else {
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
        errorMessage = CLOSE_PARENTHESIS[language]!;
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
            errorMessage = "$c: ${REQUIRED_2_OPERATORS[language]}";
          } else {
            errorMessage = "$c: ${REQUIRED_1_OPERATORS[language]}";
          }
          return false;
        }
        pila.removeLast();
        String resultado = '';
        if (required2Operators(c)) {
          if (pila.isEmpty) {
            errorMessage = "$c: ${REQUIRED_2_OPERATORS[language]}";
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
      errorMessage = SINTAXIS_ERROR[language]!;
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

  int _checkCanAddStep(StepProcess step) {
    for (StepProcess s in steps) {
      if (s.toString() == step.toString()) return s.index;
    }
    return -1;
  }

  void _addStep(StepProcess step) {
    int index = _checkCanAddStep(step);
    if (index == -1) {
      columns[step.toString()] = [];
      steps.add(step);
      statesSteps.add(step.index);
    } else {
      statesSteps.add(index);
      StepProcess.backStep();
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
  }
}
