const kLettersSimple = ['p', 'q', 'r', 's', 'a', 'b', '0', '1'];
const kOperatorsSimple = ['∧', '∨', '⇒', '¬', '~', '⇔', '(', ')'];

const kLettersAdvanced = [
  'p',
  'q',
  'r',
  's',
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'x',
  'y',
  'z',
  '0',
  '1',
];

const kOperatorsAdvanced = [
  ...kOperatorsSimple,
  '{',
  '}',
  '[',
  ']',
  '!',
  '|',
  '&',
  '⇏',
  '⊻',
  '￩',
  '⇎',
  '⊕',
  '⊼',
  '⇍',
  '↓',
  '┹',
  '┲',
];

// Operadores premium que requieren ver un rewarded ad (usuarios no Pro)
const kPremiumOperators = [
  '⇏', // NOT Condicional
  '⊻', // XOR
  '￩', // Anticondicional
  '⇎', // NOT Bicondicional
  '⊕', // XOR2
  '⊼', // NAND
  '⇍', // NOT Condicional Inverso
  '↓', // NOR
  '┹', // Operador especial 1
  '┲', // Operador especial 2
];

enum Case { lower, upper }
