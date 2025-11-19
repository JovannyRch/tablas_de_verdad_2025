const kLettersSimple = [
  'a',
  'b',
  'c',
  'd',
  'e',
  'p',
  'q',
  'r',
  's',
  't',
  'w',
  'x',
  'y',
  'z',
  '0',
  '1',
];
const kOperatorsSimple = ['∧', '∨', '⇒', '¬', '~', '⇔'];

const kLogicOperators = ['∧', '∨', '⇒', '¬', '~', '⇒', '⇔'];

const kOperatorsAdvanced = [
  ...kOperatorsSimple,
  '(',
  ')',
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

enum Case { lower, upper }
