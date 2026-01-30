class Operator {
  String value;
  String esName;
  String enName;

  Operator({required this.enName, required this.esName, required this.value});

  /// Devuelve el nombre localizado del operador según el locale
  String getLocalizedName(String locale) {
    switch (locale) {
      case 'es':
        return esName;
      case 'pt':
        return _getPortugueseName();
      case 'fr':
        return _getFrenchName();
      case 'de':
        return _getGermanName();
      case 'hi':
        return _getHindiName();
      case 'ru':
        return _getRussianName();
      case 'it':
        return _getItalianName();
      case 'zh':
        return _getChineseName();
      case 'ja':
        return _getJapaneseName();
      default:
        return enName;
    }
  }

  String _getPortugueseName() {
    // Negación
    if (value == '~' || value == '¬' || value == '!') return 'Negação';
    // Conjunción
    if (value == '∧' || value == '&') return 'Conjunção';
    // Disyunción
    if (value == '∨' || value == '|') return 'Disjunção';
    // Condicional
    if (value == '⇒') return 'Condicional/Implicação';
    // Bicondicional
    if (value == '⇔') return 'Bicondicional/Dupla implicação';
    // Anticondicional
    if (value == '￩') return 'Condicional inverso/Replicador';
    // XOR
    if (value == '⊕' || value == '⊻') return 'XOR/Disjunção exclusiva';
    // NOR
    if (value == '↓') return 'NOR';
    // NAND
    if (value == '⊼') return 'NAND';
    // NOT Condicional Inverso
    if (value == '⇍') return 'Negação do condicional inverso';
    // NOT Condicional
    if (value == '⇏') return 'Negação do condicional';
    // NOT Bicondicional
    if (value == '⇎') return 'Negação do bicondicional';
    // Contradicción
    if (value == '┹') return 'Contradição';
    // Tautología
    if (value == '┲') return 'Tautologia';
    return enName;
  }

  String _getFrenchName() {
    // Negación
    if (value == '~' || value == '¬' || value == '!') return 'Négation';
    // Conjunción
    if (value == '∧' || value == '&') return 'Conjonction';
    // Disyunción
    if (value == '∨' || value == '|') return 'Disjonction';
    // Condicional
    if (value == '⇒') return 'Conditionnel/Implication';
    // Bicondicional
    if (value == '⇔') return 'Biconditionnel/Double implication';
    // Anticondicional
    if (value == '￩') return 'Conditionnel inverse/Réplicateur';
    // XOR
    if (value == '⊕' || value == '⊻') return 'XOR/Disjonction exclusive';
    // NOR
    if (value == '↓') return 'NOR';
    // NAND
    if (value == '⊼') return 'NAND';
    // NOT Condicional Inverso
    if (value == '⇍') return 'Négation du conditionnel inverse';
    // NOT Condicional
    if (value == '⇏') return 'Négation du conditionnel';
    // NOT Bicondicional
    if (value == '⇎') return 'Négation du biconditionnel';
    // Contradicción
    if (value == '┹') return 'Contradiction';
    // Tautología
    if (value == '┲') return 'Tautologie';
    return enName;
  }

  String _getGermanName() {
    // Negación
    if (value == '~' || value == '¬' || value == '!') return 'Negation';
    // Conjunción
    if (value == '∧' || value == '&') return 'Konjunktion';
    // Disyunción
    if (value == '∨' || value == '|') return 'Disjunktion';
    // Condicional
    if (value == '⇒') return 'Konditional/Implikation';
    // Bicondicional
    if (value == '⇔') return 'Bikonditional/Doppelte Implikation';
    // Anticondicional
    if (value == '￩') return 'Umgekehrtes Konditional/Replikator';
    // XOR
    if (value == '⊕' || value == '⊻') return 'XOR/Exklusive Disjunktion';
    // NOR
    if (value == '↓') return 'NOR';
    // NAND
    if (value == '⊼') return 'NAND';
    // NOT Condicional Inverso
    if (value == '⇍') return 'Negation des umgekehrten Konditionals';
    // NOT Condicional
    if (value == '⇏') return 'Negation der Implikation';
    // NOT Bicondicional
    if (value == '⇎') return 'Negation des Bikonditionals';
    // Contradicción
    if (value == '┹') return 'Widerspruch';
    // Tautología
    if (value == '┲') return 'Tautologie';
    return enName;
  }

  String _getRussianName() {
    // Negación
    if (value == '~' || value == '¬' || value == '!') return 'Отрицание';
    // Conjunción
    if (value == '∧' || value == '&') return 'Конъюнкция';
    // Disyunción
    if (value == '∨' || value == '|') return 'Дизъюнкция';
    // Condicional
    if (value == '⇒') return 'Условное/Импликация';
    // Bicondicional
    if (value == '⇔') return 'Двуусловное/Двойная импликация';
    // Anticondicional
    if (value == '￩') return 'Обратное условное/Репликатор';
    // XOR
    if (value == '⊕' || value == '⊻') return 'XOR/Исключающая дизъюнкция';
    // NOR
    if (value == '↓') return 'NOR';
    // NAND
    if (value == '⊼') return 'NAND';
    // NOT Condicional Inverso
    if (value == '⇍') return 'Отрицание обратного условного';
    // NOT Condicional
    if (value == '⇏') return 'Отрицание импликации';
    // NOT Bicondicional
    if (value == '⇎') return 'Отрицание двуусловного';
    // Contradicción
    if (value == '┹') return 'Противоречие';
    // Tautología
    if (value == '┲') return 'Тавтология';
    return enName;
  }

  String _getHindiName() {
    // Negación
    if (value == '~' || value == '¬' || value == '!') return 'निषेध';
    // Conjunción
    if (value == '∧' || value == '&') return 'संयोजन';
    // Disyunción
    if (value == '∨' || value == '|') return 'वियोजन';
    // Condicional
    if (value == '⇒') return 'सशर्त/निहितार्थ';
    // Bicondicional
    if (value == '⇔') return 'द्विसशर्त/दोहरा निहितार्थ';
    // Anticondicional
    if (value == '￩') return 'उल्टा सशर्त/प्रतिकृतिकर्ता';
    // XOR
    if (value == '⊕' || value == '⊻') return 'XOR/विशेष वियोजन';
    // NOR
    if (value == '↓') return 'NOR';
    // NAND
    if (value == '⊼') return 'NAND';
    // NOT Condicional Inverso
    if (value == '⇍') return 'उल्टे सशर्त का निषेध';
    // NOT Condicional
    if (value == '⇏') return 'निहितार्थ का निषेध';
    // NOT Bicondicional
    if (value == '⇎') return 'द्विसशर्त का निषेध';
    // Contradicción
    if (value == '┹') return 'विरोधाभास';
    // Tautología
    if (value == '┲') return 'टॉटोलॉजी';
    return enName;
  }

  String _getItalianName() {
    // Negación
    if (value == '~' || value == '¬' || value == '!') return 'Negazione';
    // Conjunción
    if (value == '∧' || value == '&') return 'Congiunzione';
    // Disyunción
    if (value == '∨' || value == '|') return 'Disgiunzione';
    // Condicional
    if (value == '⇒') return 'Condizionale/Implicazione';
    // Bicondicional
    if (value == '⇔') return 'Bicondizionale/Doppia implicazione';
    // Anticondicional
    if (value == '￩') return 'Condizionale inverso/Replicatore';
    // XOR
    if (value == '⊕' || value == '⊻') return 'XOR/Disgiunzione esclusiva';
    // NOR
    if (value == '↓') return 'NOR';
    // NAND
    if (value == '⊼') return 'NAND';
    // NOT Condicional Inverso
    if (value == '⇍') return 'Negazione del condizionale inverso';
    // NOT Condicional
    if (value == '⇏') return 'Negazione dell\'implicazione';
    // NOT Bicondicional
    if (value == '⇎') return 'Negazione del bicondizionale';
    // Contradicción
    if (value == '┹') return 'Contraddizione';
    // Tautología
    if (value == '┲') return 'Tautologia';
    return enName;
  }

  String _getChineseName() {
    // Negación
    if (value == '~' || value == '¬' || value == '!') return '否定';
    // Conjunción
    if (value == '∧' || value == '&') return '合取';
    // Disyunción
    if (value == '∨' || value == '|') return '析取';
    // Condicional
    if (value == '⇒') return '条件/蕴含';
    // Bicondicional
    if (value == '⇔') return '双条件/双重蕴含';
    // Anticondicional
    if (value == '￩') return '逆条件/复制器';
    // XOR
    if (value == '⊕' || value == '⊻') return 'XOR/异或';
    // NOR
    if (value == '↓') return 'NOR/或非';
    // NAND
    if (value == '⊼') return 'NAND/与非';
    // NOT Condicional Inverso
    if (value == '⇍') return '逆条件否定';
    // NOT Condicional
    if (value == '⇏') return '蕴含否定';
    // NOT Bicondicional
    if (value == '⇎') return '双条件否定';
    // Contradicción
    if (value == '┹') return '矛盾式';
    // Tautología
    if (value == '┲') return '重言式';
    return enName;
  }

  String _getJapaneseName() {
    // Negación
    if (value == '~' || value == '¬' || value == '!') return '否定';
    // Conjunción
    if (value == '∧' || value == '&') return '連言';
    // Disyunción
    if (value == '∨' || value == '|') return '選言';
    // Condicional
    if (value == '⇒') return '条件/含意';
    // Bicondicional
    if (value == '⇔') return '双条件/双方向含意';
    // Anticondicional
    if (value == '￩') return '逆条件/複製器';
    // XOR
    if (value == '⊕' || value == '⊻') return 'XOR/排他的論理和';
    // NOR
    if (value == '↓') return 'NOR/否定論理和';
    // NAND
    if (value == '⊼') return 'NAND/否定論理積';
    // NOT Condicional Inverso
    if (value == '⇍') return '逆条件の否定';
    // NOT Condicional
    if (value == '⇏') return '含意の否定';
    // NOT Bicondicional
    if (value == '⇎') return '双条件の否定';
    // Contradicción
    if (value == '┹') return '矛盾';
    // Tautología
    if (value == '┲') return '恒真式';
    return enName;
  }
}

class Operators {
  static final Operator EQUAL = Operator(value: "=", enName: "", esName: "");
  static final Operator NOT = Operator(
    value: "~",
    enName: "Negation",
    esName: "Negación",
  );
  static final Operator NOT2 = Operator(
    value: "¬",
    enName: "Negation",
    esName: "Negación",
  );
  static final Operator NOT3 = Operator(
    value: "!",
    enName: "Negation",
    esName: "Negación",
  );
  static final Operator AND = Operator(
    value: "∧",
    enName: "Conjunction",
    esName: "Conjunción",
  );
  static final Operator AND2 = Operator(
    value: "&",
    enName: "Conjunction",
    esName: "Conjunción",
  );
  static final Operator OR = Operator(
    value: "∨",
    enName: "Disjunction",
    esName: "Disyunción",
  );
  static final Operator OR2 = Operator(
    value: "|",
    enName: "Disjunction",
    esName: "Disyunción",
  );
  static final Operator BICODICIONAL = Operator(
    value: "⇔",
    enName: "Material Equivalence",
    esName: "Bicondicional/Doble implicación",
  );
  static final Operator CODICIONAL = Operator(
    value: "⇒",
    enName: "Material Implication",
    esName: "Condicional/Implicación",
  );
  static final Operator ANTICODICIONAL = Operator(
    value: "￩",
    enName: "Inverse conditional/Replier",
    esName: "Condicional inverso/Replicador",
  );
  static final Operator TRUE = Operator(
    value: "TRUE",
    enName: "1",
    esName: "1",
  );
  static final Operator FALSE = Operator(
    value: "FALSE",
    enName: "1",
    esName: "1",
  );

  static final Operator XOR = Operator(
    value: "⊕",
    enName: "Exclusive Disjunction",
    esName: "XOR/Disyunción exclusiva",
  );
  static final Operator XOR2 = Operator(
    value: "⊻",
    enName: "Exclusive Disjunction",
    esName: "XOR/Disyunción exclusiva",
  );
  static final Operator NOR = Operator(
    value: "↓",
    enName: "NOR",
    esName: "NOR",
  );
  static final Operator NAND = Operator(
    value: "⊼",
    enName: "NAND",
    esName: "NAND",
  );
  static final Operator NOT_CONDITIONAL_INVERSE = Operator(
    value: "⇍",
    enName: "Inverse Conditional Negation",
    esName: "Negación del condicional inverso",
  );
  static final Operator NOT_CONDITIONAL = Operator(
    value: "⇏",
    enName: "Implication Negation",
    esName: "Negación del condicional",
  );
  static final Operator NOT_BICONDITIONAL = Operator(
    value: "⇎",
    enName: "Equivalence negation/XOR",
    esName: "Negación del bicondicional",
  );
  static final Operator CONTRADICTION = Operator(
    value: "┹",
    enName: "Contradiction",
    esName: "Contradicción",
  );
  static final Operator TAUTOLOGY = Operator(
    value: "┲",
    enName: "Tautology",
    esName: "Tautología",
  );

  static final Operator ABC = Operator(value: "ABC", enName: "", esName: "");
  static final Operator MODE = Operator(value: "MODE", enName: "", esName: "");
}
