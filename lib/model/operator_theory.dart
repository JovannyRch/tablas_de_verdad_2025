import 'package:tablas_de_verdad_2025/class/operator.dart';

/// Provides concise theory explanations for each logical operator.
///
/// Each entry includes:
/// - A localized description of what the operator does
/// - The operator's truth table definition (universal, no translation needed)
/// - An example expression
class OperatorTheory {
  final String symbol;
  final String definition;
  final String example;
  final List<List<String>> truthTable; // rows of [inputs..., output]

  const OperatorTheory({
    required this.symbol,
    required this.definition,
    required this.example,
    required this.truthTable,
  });

  /// Returns the theory card for the given operator symbol and locale.
  static OperatorTheory? forOperator(Operator op, String locale) {
    final symbol = op.value;
    final theories = _theoriesBySymbol[symbol];
    if (theories == null) return null;
    final def = theories[locale] ?? theories['en'] ?? '';
    final example = _examples[symbol] ?? '';
    final table = _truthTables[symbol] ?? [];
    return OperatorTheory(
      symbol: symbol,
      definition: def,
      example: example,
      truthTable: table,
    );
  }

  // ─── Truth table definitions (universal) ───

  static const _ttNot = [
    ['0', '1'],
    ['1', '0'],
  ];

  static const _ttAnd = [
    ['0', '0', '0'],
    ['0', '1', '0'],
    ['1', '0', '0'],
    ['1', '1', '1'],
  ];

  static const _ttOr = [
    ['0', '0', '0'],
    ['0', '1', '1'],
    ['1', '0', '1'],
    ['1', '1', '1'],
  ];

  static const _ttXor = [
    ['0', '0', '0'],
    ['0', '1', '1'],
    ['1', '0', '1'],
    ['1', '1', '0'],
  ];

  static const _ttImplication = [
    ['0', '0', '1'],
    ['0', '1', '1'],
    ['1', '0', '0'],
    ['1', '1', '1'],
  ];

  static const _ttBiconditional = [
    ['0', '0', '1'],
    ['0', '1', '0'],
    ['1', '0', '0'],
    ['1', '1', '1'],
  ];

  static const _ttNand = [
    ['0', '0', '1'],
    ['0', '1', '1'],
    ['1', '0', '1'],
    ['1', '1', '0'],
  ];

  static const _ttNor = [
    ['0', '0', '1'],
    ['0', '1', '0'],
    ['1', '0', '0'],
    ['1', '1', '0'],
  ];

  static const _ttConverse = [
    ['0', '0', '1'],
    ['0', '1', '0'],
    ['1', '0', '1'],
    ['1', '1', '1'],
  ];

  static const _ttNotImplication = [
    ['0', '0', '0'],
    ['0', '1', '0'],
    ['1', '0', '1'],
    ['1', '1', '0'],
  ];

  static const _ttNotConverse = [
    ['0', '0', '0'],
    ['0', '1', '1'],
    ['1', '0', '0'],
    ['1', '1', '0'],
  ];

  static const _ttNotBiconditional = [
    ['0', '0', '0'],
    ['0', '1', '1'],
    ['1', '0', '1'],
    ['1', '1', '0'],
  ];

  // Map symbol → truth table rows
  static const Map<String, List<List<String>>> _truthTables = {
    '~': _ttNot,
    '¬': _ttNot,
    '!': _ttNot,
    '∧': _ttAnd,
    '&': _ttAnd,
    '∨': _ttOr,
    '|': _ttOr,
    '⇒': _ttImplication,
    '⇔': _ttBiconditional,
    '￩': _ttConverse,
    '⊕': _ttXor,
    '⊻': _ttXor,
    '⊼': _ttNand,
    '↓': _ttNor,
    '⇍': _ttNotConverse,
    '⇏': _ttNotImplication,
    '⇎': _ttNotBiconditional,
    '┲': _ttOr, // tautology op placeholder
    '┹': _ttAnd, // contradiction op placeholder
  };

  // Example expressions
  static const Map<String, String> _examples = {
    '~': '~p',
    '¬': '¬p',
    '!': '!p',
    '∧': 'p ∧ q',
    '&': 'p & q',
    '∨': 'p ∨ q',
    '|': 'p | q',
    '⇒': 'p ⇒ q',
    '⇔': 'p ⇔ q',
    '￩': 'p ￩ q',
    '⊕': 'p ⊕ q',
    '⊻': 'p ⊻ q',
    '⊼': 'p ⊼ q',
    '↓': 'p ↓ q',
    '⇍': 'p ⇍ q',
    '⇏': 'p ⇏ q',
    '⇎': 'p ⇎ q',
    '┲': 'p ┲ q',
    '┹': 'p ┹ q',
  };

  // ─── Localized definitions ───
  // Short, educational descriptions for each operator.

  static const Map<String, Map<String, String>> _theoriesBySymbol = {
    '~': {
      'en':
          'Negation inverts the truth value. If the input is true, the output is false, and vice versa.',
      'es':
          'La negación invierte el valor de verdad. Si la entrada es verdadera, la salida es falsa, y viceversa.',
      'pt':
          'A negação inverte o valor de verdade. Se a entrada é verdadeira, a saída é falsa, e vice-versa.',
      'fr':
          'La négation inverse la valeur de vérité. Si l\'entrée est vraie, la sortie est fausse, et vice versa.',
      'de':
          'Die Negation kehrt den Wahrheitswert um. Ist die Eingabe wahr, ist die Ausgabe falsch und umgekehrt.',
      'hi':
          'निषेध सत्य मान को उलट देता है। यदि इनपुट सत्य है, तो आउटपुट असत्य है, और इसके विपरीत।',
      'ru':
          'Отрицание инвертирует значение истинности. Если вход истинен, выход ложен, и наоборот.',
      'it':
          'La negazione inverte il valore di verità. Se l\'input è vero, l\'output è falso e viceversa.',
      'zh': '否定反转真值。如果输入为真，则输出为假，反之亦然。',
      'ja': '否定は真理値を反転します。入力が真なら出力は偽、その逆も同様です。',
    },
    '¬': {
      'en':
          'Negation inverts the truth value. If the input is true, the output is false, and vice versa.',
      'es':
          'La negación invierte el valor de verdad. Si la entrada es verdadera, la salida es falsa, y viceversa.',
      'pt':
          'A negação inverte o valor de verdade. Se a entrada é verdadeira, a saída é falsa, e vice-versa.',
      'fr':
          'La négation inverse la valeur de vérité. Si l\'entrée est vraie, la sortie est fausse, et vice versa.',
      'de':
          'Die Negation kehrt den Wahrheitswert um. Ist die Eingabe wahr, ist die Ausgabe falsch und umgekehrt.',
      'hi':
          'निषेध सत्य मान को उलट देता है। यदि इनपुट सत्य है, तो आउटपुट असत्य है, और इसके विपरीत।',
      'ru':
          'Отрицание инвертирует значение истинности. Если вход истинен, выход ложен, и наоборот.',
      'it':
          'La negazione inverte il valore di verità. Se l\'input è vero, l\'output è falso e viceversa.',
      'zh': '否定反转真值。如果输入为真，则输出为假，反之亦然。',
      'ja': '否定は真理値を反転します。入力が真なら出力は偽、その逆も同様です。',
    },
    '!': {
      'en':
          'Negation inverts the truth value. If the input is true, the output is false, and vice versa.',
      'es':
          'La negación invierte el valor de verdad. Si la entrada es verdadera, la salida es falsa, y viceversa.',
      'pt':
          'A negação inverte o valor de verdade. Se a entrada é verdadeira, a saída é falsa, e vice-versa.',
      'fr':
          'La négation inverse la valeur de vérité. Si l\'entrée est vraie, la sortie est fausse, et vice versa.',
      'de':
          'Die Negation kehrt den Wahrheitswert um. Ist die Eingabe wahr, ist die Ausgabe falsch und umgekehrt.',
      'hi':
          'निषेध सत्य मान को उलट देता है। यदि इनपुट सत्य है, तो आउटपुट असत्य है, और इसके विपरीत।',
      'ru':
          'Отрицание инвертирует значение истинности. Если вход истинен, выход ложен, и наоборот.',
      'it':
          'La negazione inverte il valore di verità. Se l\'input è vero, l\'output è falso e viceversa.',
      'zh': '否定反转真值。如果输入为真，则输出为假，反之亦然。',
      'ja': '否定は真理値を反転します。入力が真なら出力は偽、その逆も同様です。',
    },
    '∧': {
      'en': 'Conjunction (AND) is true only when both operands are true.',
      'es':
          'La conjunción (Y) es verdadera solo cuando ambos operandos son verdaderos.',
      'pt':
          'A conjunção (E) é verdadeira apenas quando ambos operandos são verdadeiros.',
      'fr':
          'La conjonction (ET) est vraie uniquement quand les deux opérandes sont vrais.',
      'de':
          'Die Konjunktion (UND) ist nur wahr, wenn beide Operanden wahr sind.',
      'hi': 'संयोजन (AND) तभी सत्य है जब दोनों ऑपरेंड सत्य हों।',
      'ru': 'Конъюнкция (И) истинна только тогда, когда оба операнда истинны.',
      'it':
          'La congiunzione (AND) è vera solo quando entrambi gli operandi sono veri.',
      'zh': '合取（AND）仅当两个操作数都为真时才为真。',
      'ja': '論理積（AND）は両方のオペランドが真の場合にのみ真です。',
    },
    '&': {
      'en': 'Conjunction (AND) is true only when both operands are true.',
      'es':
          'La conjunción (Y) es verdadera solo cuando ambos operandos son verdaderos.',
      'pt':
          'A conjunção (E) é verdadeira apenas quando ambos operandos são verdadeiros.',
      'fr':
          'La conjonction (ET) est vraie uniquement quand les deux opérandes sont vrais.',
      'de':
          'Die Konjunktion (UND) ist nur wahr, wenn beide Operanden wahr sind.',
      'hi': 'संयोजन (AND) तभी सत्य है जब दोनों ऑपरेंड सत्य हों।',
      'ru': 'Конъюнкция (И) истинна только тогда, когда оба операнда истинны.',
      'it':
          'La congiunzione (AND) è vera solo quando entrambi gli operandi sono veri.',
      'zh': '合取（AND）仅当两个操作数都为真时才为真。',
      'ja': '論理積（AND）は両方のオペランドが真の場合にのみ真です。',
    },
    '∨': {
      'en': 'Disjunction (OR) is true when at least one operand is true.',
      'es':
          'La disyunción (O) es verdadera cuando al menos un operando es verdadero.',
      'pt':
          'A disjunção (OU) é verdadeira quando pelo menos um operando é verdadeiro.',
      'fr':
          'La disjonction (OU) est vraie quand au moins un opérande est vrai.',
      'de':
          'Die Disjunktion (ODER) ist wahr, wenn mindestens ein Operand wahr ist.',
      'hi': 'वियोजन (OR) तब सत्य है जब कम से कम एक ऑपरेंड सत्य हो।',
      'ru': 'Дизъюнкция (ИЛИ) истинна, когда хотя бы один операнд истинен.',
      'it': 'La disgiunzione (OR) è vera quando almeno un operando è vero.',
      'zh': '析取（OR）当至少一个操作数为真时为真。',
      'ja': '論理和（OR）は少なくとも一つのオペランドが真であれば真です。',
    },
    '|': {
      'en': 'Disjunction (OR) is true when at least one operand is true.',
      'es':
          'La disyunción (O) es verdadera cuando al menos un operando es verdadero.',
      'pt':
          'A disjunção (OU) é verdadeira quando pelo menos um operando é verdadeiro.',
      'fr':
          'La disjonction (OU) est vraie quand au moins un opérande est vrai.',
      'de':
          'Die Disjunktion (ODER) ist wahr, wenn mindestens ein Operand wahr ist.',
      'hi': 'वियोजन (OR) तब सत्य है जब कम से कम एक ऑपरेंड सत्य हो।',
      'ru': 'Дизъюнкция (ИЛИ) истинна, когда хотя бы один операнд истинен.',
      'it': 'La disgiunzione (OR) è vera quando almeno un operando è vero.',
      'zh': '析取（OR）当至少一个操作数为真时为真。',
      'ja': '論理和（OR）は少なくとも一つのオペランドが真であれば真です。',
    },
    '⇒': {
      'en':
          'Material implication is false only when the antecedent is true and the consequent is false.',
      'es':
          'La implicación material es falsa solo cuando el antecedente es verdadero y el consecuente es falso.',
      'pt':
          'A implicação material é falsa somente quando o antecedente é verdadeiro e o consequente é falso.',
      'fr':
          'L\'implication matérielle est fausse uniquement quand l\'antécédent est vrai et le conséquent est faux.',
      'de':
          'Die materiale Implikation ist nur falsch, wenn das Antezedens wahr und das Konsequens falsch ist.',
      'hi':
          'भौतिक निहितार्थ तभी असत्य है जब पूर्ववर्ती सत्य हो और परिणामी असत्य हो।',
      'ru':
          'Материальная импликация ложна только тогда, когда антецедент истинен, а консеквент ложен.',
      'it':
          'L\'implicazione materiale è falsa solo quando l\'antecedente è vero e il conseguente è falso.',
      'zh': '实质蕴涵仅当前件为真且后件为假时才为假。',
      'ja': '実質含意は、前件が真で後件が偽の場合にのみ偽です。',
    },
    '⇔': {
      'en':
          'Biconditional (equivalence) is true when both operands have the same truth value.',
      'es':
          'El bicondicional (equivalencia) es verdadero cuando ambos operandos tienen el mismo valor de verdad.',
      'pt':
          'O bicondicional (equivalência) é verdadeiro quando ambos operandos têm o mesmo valor de verdade.',
      'fr':
          'Le biconditionnel (équivalence) est vrai quand les deux opérandes ont la même valeur de vérité.',
      'de':
          'Das Bikonditional (Äquivalenz) ist wahr, wenn beide Operanden denselben Wahrheitswert haben.',
      'hi':
          'द्विसशर्त (तुल्यता) तब सत्य है जब दोनों ऑपरेंड का सत्य मान समान हो।',
      'ru':
          'Бикондиционал (эквивалентность) истинен, когда оба операнда имеют одинаковое значение истинности.',
      'it':
          'Il bicondizionale (equivalenza) è vero quando entrambi gli operandi hanno lo stesso valore di verità.',
      'zh': '双条件（等价）当两个操作数的真值相同时为真。',
      'ja': '双条件（等価）は両方のオペランドの真理値が同じ場合に真です。',
    },
    '￩': {
      'en':
          'Converse implication is false only when the antecedent is false and the consequent is true.',
      'es':
          'La implicación inversa es falsa solo cuando el antecedente es falso y el consecuente es verdadero.',
      'pt':
          'A implicação conversa é falsa somente quando o antecedente é falso e o consequente é verdadeiro.',
      'fr':
          'L\'implication réciproque est fausse uniquement quand l\'antécédent est faux et le conséquent est vrai.',
      'de':
          'Die Umkehrimplifikation ist nur falsch, wenn das Antezedens falsch und das Konsequens wahr ist.',
      'hi':
          'उलट निहितार्थ तभी असत्य है जब पूर्ववर्ती असत्य हो और परिणामी सत्य हो।',
      'ru':
          'Обратная импликация ложна только тогда, когда антецедент ложен, а консеквент истинен.',
      'it':
          'L\'implicazione conversa è falsa solo quando l\'antecedente è falso e il conseguente è vero.',
      'zh': '逆蕴涵仅当前件为假且后件为真时才为假。',
      'ja': '逆含意は、前件が偽で後件が真の場合にのみ偽です。',
    },
    '⊕': {
      'en':
          'Exclusive disjunction (XOR) is true when exactly one operand is true.',
      'es':
          'La disyunción exclusiva (XOR) es verdadera cuando exactamente un operando es verdadero.',
      'pt':
          'A disjunção exclusiva (XOR) é verdadeira quando exatamente um operando é verdadeiro.',
      'fr':
          'La disjonction exclusive (XOR) est vraie quand exactement un opérande est vrai.',
      'de':
          'Die exklusive Disjunktion (XOR) ist wahr, wenn genau ein Operand wahr ist.',
      'hi': 'अनन्य वियोजन (XOR) तब सत्य है जब ठीक एक ऑपरेंड सत्य हो।',
      'ru':
          'Исключающая дизъюнкция (XOR) истинна, когда ровно один операнд истинен.',
      'it':
          'La disgiunzione esclusiva (XOR) è vera quando esattamente un operando è vero.',
      'zh': '异或（XOR）当恰好一个操作数为真时为真。',
      'ja': '排他的論理和（XOR）は、正確に一つのオペランドが真の場合に真です。',
    },
    '⊻': {
      'en':
          'Exclusive disjunction (XOR) is true when exactly one operand is true.',
      'es':
          'La disyunción exclusiva (XOR) es verdadera cuando exactamente un operando es verdadero.',
      'pt':
          'A disjunção exclusiva (XOR) é verdadeira quando exatamente um operando é verdadeiro.',
      'fr':
          'La disjonction exclusive (XOR) est vraie quand exactement un opérande est vrai.',
      'de':
          'Die exklusive Disjunktion (XOR) ist wahr, wenn genau ein Operand wahr ist.',
      'hi': 'अनन्य वियोजन (XOR) तब सत्य है जब ठीक एक ऑपरेंड सत्य हो।',
      'ru':
          'Исключающая дизъюнкция (XOR) истинна, когда ровно один операнд истинен.',
      'it':
          'La disgiunzione esclusiva (XOR) è vera quando esattamente un operando è vero.',
      'zh': '异或（XOR）当恰好一个操作数为真时为真。',
      'ja': '排他的論理和（XOR）は、正確に一つのオペランドが真の場合に真です。',
    },
    '⊼': {
      'en':
          'NAND (Sheffer stroke) is false only when both operands are true. It is the negation of AND.',
      'es':
          'NAND (barra de Sheffer) es falso solo cuando ambos operandos son verdaderos. Es la negación de AND.',
      'pt':
          'NAND (traço de Sheffer) é falso somente quando ambos operandos são verdadeiros. É a negação de AND.',
      'fr':
          'NAND (barre de Sheffer) est faux uniquement quand les deux opérandes sont vrais. C\'est la négation du ET.',
      'de':
          'NAND (Sheffer-Strich) ist nur falsch, wenn beide Operanden wahr sind. Es ist die Negation von UND.',
      'hi':
          'NAND (शेफर स्ट्रोक) तभी असत्य है जब दोनों ऑपरेंड सत्य हों। यह AND का निषेध है।',
      'ru':
          'NAND (штрих Шеффера) ложен только тогда, когда оба операнда истинны. Это отрицание И.',
      'it':
          'NAND (barra di Sheffer) è falso solo quando entrambi gli operandi sono veri. È la negazione dell\'AND.',
      'zh': 'NAND（谢弗竖线）仅当两个操作数都为真时才为假。它是AND的否定。',
      'ja': 'NAND（シェファーストローク）は両方のオペランドが真の場合にのみ偽です。ANDの否定です。',
    },
    '↓': {
      'en':
          'NOR (Peirce arrow) is true only when both operands are false. It is the negation of OR.',
      'es':
          'NOR (flecha de Peirce) es verdadero solo cuando ambos operandos son falsos. Es la negación de OR.',
      'pt':
          'NOR (seta de Peirce) é verdadeiro somente quando ambos operandos são falsos. É a negação de OR.',
      'fr':
          'NOR (flèche de Peirce) est vrai uniquement quand les deux opérandes sont faux. C\'est la négation du OU.',
      'de':
          'NOR (Peirce-Pfeil) ist nur wahr, wenn beide Operanden falsch sind. Es ist die Negation von ODER.',
      'hi':
          'NOR (पियर्स तीर) तभी सत्य है जब दोनों ऑपरेंड असत्य हों। यह OR का निषेध है।',
      'ru':
          'NOR (стрелка Пирса) истинен только тогда, когда оба операнда ложны. Это отрицание ИЛИ.',
      'it':
          'NOR (freccia di Peirce) è vero solo quando entrambi gli operandi sono falsi. È la negazione dell\'OR.',
      'zh': 'NOR（皮尔斯箭头）仅当两个操作数都为假时才为真。它是OR的否定。',
      'ja': 'NOR（ピアスの矢印）は両方のオペランドが偽の場合にのみ真です。ORの否定です。',
    },
    '⇍': {
      'en':
          'Negation of the converse: true only when the first operand is false and the second is true.',
      'es':
          'Negación de la inversa: verdadero solo cuando el primer operando es falso y el segundo es verdadero.',
      'pt':
          'Negação da conversa: verdadeiro somente quando o primeiro operando é falso e o segundo é verdadeiro.',
      'fr':
          'Négation de la réciproque : vrai uniquement quand le premier opérande est faux et le second est vrai.',
      'de':
          'Negation der Umkehrung: nur wahr, wenn der erste Operand falsch und der zweite wahr ist.',
      'hi': 'उलटे का निषेध: तभी सत्य जब पहला ऑपरेंड असत्य हो और दूसरा सत्य हो।',
      'ru':
          'Отрицание обратной импликации: истинно, только когда первый операнд ложен, а второй истинен.',
      'it':
          'Negazione della conversa: vero solo quando il primo operando è falso e il secondo è vero.',
      'zh': '逆蕴涵的否定：仅当第一个操作数为假且第二个为真时才为真。',
      'ja': '逆の否定：最初のオペランドが偽で2番目が真の場合にのみ真です。',
    },
    '⇏': {
      'en':
          'Negation of implication: true only when the first operand is true and the second is false.',
      'es':
          'Negación de la implicación: verdadero solo cuando el primer operando es verdadero y el segundo es falso.',
      'pt':
          'Negação da implicação: verdadeiro somente quando o primeiro operando é verdadeiro e o segundo é falso.',
      'fr':
          'Négation de l\'implication : vrai uniquement quand le premier opérande est vrai et le second est faux.',
      'de':
          'Negation der Implikation: nur wahr, wenn der erste Operand wahr und der zweite falsch ist.',
      'hi':
          'निहितार्थ का निषेध: तभी सत्य जब पहला ऑपरेंड सत्य हो और दूसरा असत्य हो।',
      'ru':
          'Отрицание импликации: истинно, только когда первый операнд истинен, а второй ложен.',
      'it':
          'Negazione dell\'implicazione: vero solo quando il primo operando è vero e il secondo è falso.',
      'zh': '蕴涵的否定：仅当第一个操作数为真且第二个为假时才为真。',
      'ja': '含意の否定：最初のオペランドが真で2番目が偽の場合にのみ真です。',
    },
    '⇎': {
      'en':
          'Negation of equivalence: true when operands have different truth values. Equivalent to XOR.',
      'es':
          'Negación de la equivalencia: verdadero cuando los operandos tienen valores de verdad diferentes. Equivalente a XOR.',
      'pt':
          'Negação da equivalência: verdadeiro quando os operandos têm valores de verdade diferentes. Equivalente a XOR.',
      'fr':
          'Négation de l\'équivalence : vrai quand les opérandes ont des valeurs de vérité différentes. Équivalent au XOR.',
      'de':
          'Negation der Äquivalenz: wahr, wenn die Operanden verschiedene Wahrheitswerte haben. Entspricht XOR.',
      'hi':
          'तुल्यता का निषेध: तब सत्य जब ऑपरेंड के अलग सत्य मान हों। XOR के समतुल्य।',
      'ru':
          'Отрицание эквивалентности: истинно, когда операнды имеют разные значения истинности. Эквивалентно XOR.',
      'it':
          'Negazione dell\'equivalenza: vero quando gli operandi hanno valori di verità diversi. Equivalente a XOR.',
      'zh': '等价的否定：当操作数的真值不同时为真。等价于XOR。',
      'ja': '等価の否定：オペランドの真理値が異なる場合に真。XORと等価です。',
    },
    '┲': {
      'en':
          'Tautology operator: the result is always true regardless of the operand values.',
      'es':
          'Operador tautología: el resultado siempre es verdadero, sin importar los valores de los operandos.',
      'pt':
          'Operador tautologia: o resultado é sempre verdadeiro, independentemente dos valores dos operandos.',
      'fr':
          'Opérateur tautologie : le résultat est toujours vrai, quelles que soient les valeurs des opérandes.',
      'de':
          'Tautologie-Operator: das Ergebnis ist immer wahr, unabhängig von den Operandenwerten.',
      'hi':
          'तॉटोलॉजी ऑपरेटर: परिणाम हमेशा सत्य होता है, ऑपरेंड मूल्यों की परवाह किए बिना।',
      'ru':
          'Оператор тавтологии: результат всегда истинен, независимо от значений операндов.',
      'it':
          'Operatore tautologia: il risultato è sempre vero, indipendentemente dai valori degli operandi.',
      'zh': '重言式运算符：无论操作数的值如何，结果始终为真。',
      'ja': 'トートロジー演算子：オペランドの値に関係なく、結果は常に真です。',
    },
    '┹': {
      'en':
          'Contradiction operator: the result is always false regardless of the operand values.',
      'es':
          'Operador contradicción: el resultado siempre es falso, sin importar los valores de los operandos.',
      'pt':
          'Operador contradição: o resultado é sempre falso, independentemente dos valores dos operandos.',
      'fr':
          'Opérateur contradiction : le résultat est toujours faux, quelles que soient les valeurs des opérandes.',
      'de':
          'Widerspruch-Operator: das Ergebnis ist immer falsch, unabhängig von den Operandenwerten.',
      'hi':
          'विरोधाभास ऑपरेटर: परिणाम हमेशा असत्य होता है, ऑपरेंड मूल्यों की परवाह किए बिना।',
      'ru':
          'Оператор противоречия: результат всегда ложен, независимо от значений операндов.',
      'it':
          'Operatore contraddizione: il risultato è sempre falso, indipendentemente dai valori degli operandi.',
      'zh': '矛盾式运算符：无论操作数的值如何，结果始终为假。',
      'ja': '矛盾演算子：オペランドの値に関係なく、結果は常に偽です。',
    },
  };
}
