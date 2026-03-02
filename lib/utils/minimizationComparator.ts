type SolveType = "SOP" | "POS";

interface Implicant {
  pattern: string; // e.g. 10-1
  covers: number[];
}

interface ComparatorInput {
  values: string[];
  variableQuantity: number;
  resultType: SolveType;
  currentResult?: string;
}

export interface ComparatorOutput {
  exactExpression: string;
  exactExpressions: string[];
  heuristicExpression: string;
  equivalentSolutions: number;
  hasMultipleEquivalent: boolean;
  heuristicIsOptimal: boolean;
  currentResultEquivalent: boolean | null;
}

const VARIABLES = ["A", "B", "C", "D", "E"];

const toBinary = (value: number, width: number) => {
  return value.toString(2).padStart(width, "0");
};

const literalCount = (pattern: string) =>
  pattern.split("").filter((bit) => bit !== "-").length;

const matchesPattern = (pattern: string, minterm: string) => {
  for (let i = 0; i < pattern.length; i++) {
    if (pattern[i] === "-") {
      continue;
    }
    if (pattern[i] !== minterm[i]) {
      return false;
    }
  }
  return true;
};

const combinePattern = (a: string, b: string): string | null => {
  let diff = 0;
  let result = "";

  for (let i = 0; i < a.length; i++) {
    if (a[i] === b[i]) {
      result += a[i];
      continue;
    }
    if (a[i] === "-" || b[i] === "-") {
      return null;
    }
    diff += 1;
    result += "-";
  }

  return diff === 1 ? result : null;
};

const buildPrimeImplicants = (
  variableQuantity: number,
  minterms: number[],
  dontCares: number[],
) => {
  const source = [...new Set([...minterms, ...dontCares])];
  let groups = source.map((value) => ({
    pattern: toBinary(value, variableQuantity),
    raw: [value],
    used: false,
  }));
  const primes: string[] = [];

  while (groups.length > 0) {
    const next: typeof groups = [];
    const seen = new Set<string>();

    for (let i = 0; i < groups.length; i++) {
      for (let j = i + 1; j < groups.length; j++) {
        const combined = combinePattern(groups[i].pattern, groups[j].pattern);
        if (!combined) {
          continue;
        }
        groups[i].used = true;
        groups[j].used = true;
        if (!seen.has(combined)) {
          seen.add(combined);
          next.push({
            pattern: combined,
            raw: [...new Set([...groups[i].raw, ...groups[j].raw])],
            used: false,
          });
        }
      }
    }

    groups.forEach((item) => {
      if (!item.used && !primes.includes(item.pattern)) {
        primes.push(item.pattern);
      }
    });

    groups = next;
  }

  const mintermPatterns = minterms.map((value) =>
    toBinary(value, variableQuantity),
  );
  const implicants: Implicant[] = primes
    .map((pattern) => ({
      pattern,
      covers: minterms.filter((m, idx) =>
        matchesPattern(pattern, mintermPatterns[idx]),
      ),
    }))
    .filter((item) => item.covers.length > 0);

  return implicants;
};

const isFullyCovered = (cover: Set<number>, targets: number[]) =>
  targets.every((target) => cover.has(target));

const normalizeExpression = (expression: string) => {
  return expression
    .replace(/\u00B7/g, "·")
    .replace(/\*/g, "·")
    .replace(/[|∨]/g, "+")
    .replace(/[∧]/g, "·")
    .replace(/\)\s*\(/g, ")·(")
    .replace(/\s+/g, " ")
    .trim();
};

const parseLiteralValue = (
  token: string,
  variableQuantity: number,
  assignmentIndex: number,
) => {
  for (let i = 0; i < token.length; i++) {
    const char = token[i].toUpperCase();
    const variableIndex = VARIABLES.indexOf(char);
    if (variableIndex === -1 || variableIndex >= variableQuantity) {
      continue;
    }

    const bit = (assignmentIndex >> (variableQuantity - 1 - variableIndex)) & 1;
    const next = token[i + 1];
    const negated = next === "'" || next === "\u0305";
    return negated ? bit === 0 : bit === 1;
  }

  return null;
};

const evaluateSOP = (
  expression: string,
  variableQuantity: number,
  assignmentIndex: number,
) => {
  const normalized = normalizeExpression(expression);
  if (normalized === "1") return true;
  if (normalized === "0" || normalized.length === 0) return false;

  const terms = normalized.split("+").map((term) => term.trim());
  return terms.some((term) => {
    const clean = term
      .replace(/[()]/g, "")
      .replace(/[·*]/g, "")
      .replace(/\s+/g, "");
    if (clean === "1") return true;
    if (clean === "0" || clean.length === 0) return false;

    const literals: boolean[] = [];
    for (let i = 0; i < clean.length; i++) {
      const maybeLiteral = parseLiteralValue(
        clean.slice(i, i + 2),
        variableQuantity,
        assignmentIndex,
      );
      if (maybeLiteral !== null) {
        literals.push(maybeLiteral);
      }
    }

    return literals.length > 0 && literals.every(Boolean);
  });
};

const evaluatePOS = (
  expression: string,
  variableQuantity: number,
  assignmentIndex: number,
) => {
  const normalized = normalizeExpression(expression);
  if (normalized === "1") return true;
  if (normalized === "0" || normalized.length === 0) return false;

  const factors = normalized
    .split(/[·*]/)
    .map((factor) => factor.trim())
    .filter(Boolean);

  return factors.every((factor) => {
    const clean = factor.replace(/[()]/g, "").replace(/\s+/g, "");
    if (clean === "1") return true;
    if (clean === "0" || clean.length === 0) return false;

    const sumLiterals = clean.split("+").filter(Boolean);
    return sumLiterals.some((literalToken) => {
      const literalValue = parseLiteralValue(
        literalToken,
        variableQuantity,
        assignmentIndex,
      );
      return literalValue === true;
    });
  });
};

const evaluateExpression = (
  expression: string,
  type: SolveType,
  variableQuantity: number,
  assignmentIndex: number,
) => {
  return type === "SOP"
    ? evaluateSOP(expression, variableQuantity, assignmentIndex)
    : evaluatePOS(expression, variableQuantity, assignmentIndex);
};

const areEquivalentOnDefinedCells = (
  firstExpression: string,
  secondExpression: string,
  values: string[],
  type: SolveType,
  variableQuantity: number,
) => {
  for (let index = 0; index < values.length; index++) {
    if (values[index] === "X") {
      continue;
    }

    const a = evaluateExpression(
      firstExpression,
      type,
      variableQuantity,
      index,
    );
    const b = evaluateExpression(
      secondExpression,
      type,
      variableQuantity,
      index,
    );
    if (a !== b) {
      return false;
    }
  }

  return true;
};

const expressionFromImplicants = (type: SolveType, implicants: string[]) => {
  if (implicants.length === 0) {
    return type === "SOP" ? "0" : "1";
  }

  const terms = implicants.map((pattern) => {
    const literals: string[] = [];
    for (let i = 0; i < pattern.length; i++) {
      const bit = pattern[i];
      if (bit === "-") {
        continue;
      }
      const variable = VARIABLES[i];
      if (type === "SOP") {
        literals.push(bit === "1" ? variable : `${variable}'`);
      } else {
        literals.push(bit === "0" ? variable : `${variable}'`);
      }
    }

    if (literals.length === 0) {
      return type === "SOP" ? "1" : "0";
    }

    if (type === "SOP") {
      return literals.join("");
    }

    return `(${literals.join(" ∨ ")})`;
  });

  return type === "SOP" ? terms.join(" ∨ ") : terms.join(" ∧ ");
};

const solveExact = (
  variableQuantity: number,
  resultType: SolveType,
  minterms: number[],
  dontCares: number[],
) => {
  if (minterms.length === 0) {
    return {
      expressions: [resultType === "SOP" ? "0" : "1"],
      termCount: 0,
      literalTotal: 0,
    };
  }

  const implicants = buildPrimeImplicants(
    variableQuantity,
    minterms,
    dontCares,
  );
  if (implicants.length === 0) {
    return {
      expressions: [resultType === "SOP" ? "0" : "1"],
      termCount: 0,
      literalTotal: 0,
    };
  }

  const essential = new Set<number>();
  minterms.forEach((target) => {
    const owners = implicants
      .map((item, index) => ({ index, covers: item.covers.includes(target) }))
      .filter((item) => item.covers);
    if (owners.length === 1) {
      essential.add(owners[0].index);
    }
  });

  const essentialPatterns = [...essential].map(
    (index) => implicants[index].pattern,
  );
  const baseCovered = new Set<number>();
  [...essential].forEach((index) => {
    implicants[index].covers.forEach((value) => baseCovered.add(value));
  });

  const uncovered = minterms.filter((value) => !baseCovered.has(value));
  const candidates = implicants
    .map((item, index) => ({ item, index }))
    .filter(({ index }) => !essential.has(index))
    .filter(({ item }) =>
      item.covers.some((value) => uncovered.includes(value)),
    );

  const candidateCount = candidates.length;
  const solutions: string[][] = [];
  let bestTerms = Number.POSITIVE_INFINITY;
  let bestLiterals = Number.POSITIVE_INFINITY;

  const recurse = (at: number, picked: number[], covered: Set<number>) => {
    const totalTerms = essentialPatterns.length + picked.length;
    if (totalTerms > bestTerms) {
      return;
    }

    if (isFullyCovered(covered, uncovered)) {
      const patterns = [
        ...essentialPatterns,
        ...picked.map((idx) => candidates[idx].item.pattern),
      ];
      const literalTotal = patterns.reduce(
        (acc, p) => acc + literalCount(p),
        0,
      );

      if (
        totalTerms < bestTerms ||
        (totalTerms === bestTerms && literalTotal < bestLiterals)
      ) {
        bestTerms = totalTerms;
        bestLiterals = literalTotal;
        solutions.length = 0;
        solutions.push(patterns);
      } else if (totalTerms === bestTerms && literalTotal === bestLiterals) {
        solutions.push(patterns);
      }
      return;
    }

    if (at >= candidateCount) {
      return;
    }

    recurse(at + 1, picked, covered);

    const nextCovered = new Set(covered);
    candidates[at].item.covers.forEach((value) => nextCovered.add(value));
    recurse(at + 1, [...picked, at], nextCovered);
  };

  recurse(0, [], new Set<number>());

  const dedupExpressions = [
    ...new Set(
      solutions.map((patterns) =>
        expressionFromImplicants(
          resultType,
          [...patterns].sort((a, b) => literalCount(a) - literalCount(b)),
        ),
      ),
    ),
  ];

  return {
    expressions:
      dedupExpressions.length > 0
        ? dedupExpressions
        : [expressionFromImplicants(resultType, essentialPatterns)],
    termCount: bestTerms,
    literalTotal: bestLiterals,
  };
};

const solveHeuristic = (
  variableQuantity: number,
  resultType: SolveType,
  minterms: number[],
  dontCares: number[],
) => {
  if (minterms.length === 0) {
    return resultType === "SOP" ? "0" : "1";
  }

  const implicants = buildPrimeImplicants(
    variableQuantity,
    minterms,
    dontCares,
  );
  const uncovered = new Set(minterms);
  const selected: string[] = [];

  while (uncovered.size > 0) {
    let best: Implicant | null = null;
    let bestScore = -1;

    implicants.forEach((candidate) => {
      const newlyCovered = candidate.covers.filter((value) =>
        uncovered.has(value),
      ).length;
      if (newlyCovered === 0) {
        return;
      }
      const score = newlyCovered * 100 - literalCount(candidate.pattern);
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    });

    if (!best) {
      break;
    }

    const chosen = best as Implicant;
    selected.push(chosen.pattern);
    chosen.covers.forEach((value: number) => uncovered.delete(value));
  }

  const minimized = selected.filter((pattern, index) => {
    const others = selected.filter((_, i) => i !== index);
    const cover = new Set<number>();
    others.forEach((candidatePattern) => {
      const implicant = implicants.find(
        (item) => item.pattern === candidatePattern,
      );
      implicant?.covers.forEach((value) => cover.add(value));
    });
    return !isFullyCovered(cover, minterms);
  });

  return expressionFromImplicants(resultType, minimized);
};

export const buildMinimizationComparison = (
  input: ComparatorInput,
): ComparatorOutput => {
  const { values, variableQuantity, resultType, currentResult } = input;
  const targetValue = resultType === "SOP" ? "1" : "0";

  const minterms: number[] = [];
  const dontCares: number[] = [];
  values.forEach((value, index) => {
    if (value === targetValue) {
      minterms.push(index);
    } else if (value === "X") {
      dontCares.push(index);
    }
  });

  const exact = solveExact(variableQuantity, resultType, minterms, dontCares);
  const heuristic = solveHeuristic(
    variableQuantity,
    resultType,
    minterms,
    dontCares,
  );
  const heuristicIsOptimal = exact.expressions.includes(heuristic);
  const currentResultEquivalent = currentResult
    ? areEquivalentOnDefinedCells(
        currentResult,
        exact.expressions[0],
        values,
        resultType,
        variableQuantity,
      )
    : null;

  return {
    exactExpression: exact.expressions[0],
    exactExpressions: exact.expressions,
    heuristicExpression: heuristic,
    equivalentSolutions: exact.expressions.length,
    hasMultipleEquivalent: exact.expressions.length > 1,
    heuristicIsOptimal,
    currentResultEquivalent,
  };
};
