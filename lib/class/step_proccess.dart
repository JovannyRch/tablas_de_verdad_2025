import 'package:tablas_de_verdad_2025/class/operator.dart';

class StepProcess {
  String variable1;
  String variable2 = "";
  Operator operator;
  bool isSingleVariable;
  int index = 0;
  static int currentIndex = 0;
  static int labelIndex = 0;

  StepProcess({
    required this.variable1,
    required this.variable2,
    required this.operator,
    this.isSingleVariable = false,
  }) {
    index = ++labelIndex;
    currentIndex++;
  }

  @override
  String toString() {
    if (this.isSingleVariable) {
      return "${operator.value}$variable1";
    }
    return "$variable1${operator.value}$variable2";
  }

  static void backStep() {
    labelIndex--;
  }
}
