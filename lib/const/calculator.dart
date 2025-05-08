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
