class Operator {
  String value;
  String esName;
  String enName;

  Operator({required this.enName, required this.esName, required this.value});
}

class Operators {
  static final Operator EQUAL = new Operator(
    value: "=",
    enName: "",
    esName: "",
  );
  static final Operator NOT = new Operator(
    value: "~",
    enName: "Negation",
    esName: "Negación",
  );
  static final Operator NOT2 = new Operator(
    value: "¬",
    enName: "Negation",
    esName: "Negación",
  );
  static final Operator NOT3 = new Operator(
    value: "!",
    enName: "Negation",
    esName: "Negación",
  );
  static final Operator AND = new Operator(
    value: "∧",
    enName: "Conjunction",
    esName: "Conjunción",
  );
  static final Operator AND2 = new Operator(
    value: "&",
    enName: "Conjunction",
    esName: "Conjunción",
  );
  static final Operator OR = new Operator(
    value: "∨",
    enName: "Disjunction",
    esName: "Disyunción",
  );
  static final Operator OR2 = new Operator(
    value: "|",
    enName: "Disjunction",
    esName: "Disyunción",
  );
  static final Operator BICODICIONAL = new Operator(
    value: "⇔",
    enName: "Material Equivalence",
    esName: "Bicondicional/Doble implicación",
  );
  static final Operator CODICIONAL = new Operator(
    value: "⇒",
    enName: "Material Implication",
    esName: "Condicional/Implicación",
  );
  static final Operator ANTICODICIONAL = new Operator(
    value: "￩",
    enName: "Inverse conditional/Replier",
    esName: "Condicional inverso/Replicador",
  );
  static final Operator TRUE = new Operator(
    value: "TRUE",
    enName: "1",
    esName: "1",
  );
  static final Operator FALSE = new Operator(
    value: "FALSE",
    enName: "1",
    esName: "1",
  );

  static final Operator XOR = new Operator(
    value: "⊕",
    enName: "Exclusive Disjunction",
    esName: "XOR/Disyunción exclusiva",
  );
  static final Operator XOR2 = new Operator(
    value: "⊻",
    enName: "Exclusive Disjunction",
    esName: "XOR/Disyunción exclusiva",
  );
  static final Operator NOR = new Operator(
    value: "↓",
    enName: "NOR",
    esName: "NOR",
  );
  static final Operator NAND = new Operator(
    value: "⊼",
    enName: "NAND",
    esName: "NAND",
  );
  static final Operator NOT_CONDITIONAL_INVERSE = new Operator(
    value: "⇍",
    enName: "Inverse Conditional Negation",
    esName: "Negación del condicional inverso",
  );
  static final Operator NOT_CONDITIONAL = new Operator(
    value: "⇏",
    enName: "Implication Negation",
    esName: "Negación del condicional",
  );
  static final Operator NOT_BICONDITIONAL = new Operator(
    value: "⇎",
    enName: "Equivalence negation/XOR",
    esName: "Negación del bicondicional",
  );
  static final Operator CONTRADICTION = new Operator(
    value: "┹",
    enName: "Contradiction",
    esName: "Contradicción",
  );
  static final Operator TAUTOLOGY = new Operator(
    value: "┲",
    enName: "Tautology",
    esName: "Tautología",
  );

  static final Operator ABC = new Operator(
    value: "ABC",
    enName: "",
    esName: "",
  );
  static final Operator MODE = new Operator(
    value: "MODE",
    enName: "",
    esName: "",
  );
}
