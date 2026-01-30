class Operator {
  String value;
  String esName;
  String enName;

  Operator({required this.enName, required this.esName, required this.value});
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
