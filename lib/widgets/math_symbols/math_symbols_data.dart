/// Data definitions for the math symbols toolbar.
library;

/// Categories for organizing math symbols in the toolbar.
enum MathSymbolCategory {
  common,
  relations,
  functions,
  greek,
  templates,
  recent,
}

/// An item in the math symbols toolbar.
sealed class MathSymbolItem {
  /// What's shown on the toolbar button.
  final String display;

  /// The category this symbol belongs to.
  final MathSymbolCategory category;

  const MathSymbolItem({required this.display, required this.category});
}

/// A single Unicode character, shown and inserted as-is.
///
/// For example, `UnicodeSymbol(display: 'α', output: 'α', category: MathSymbolCategory.greek)`.
class UnicodeSymbol extends MathSymbolItem {
  /// What gets inserted into the text field.
  final String output;

  const UnicodeSymbol({
    required super.display,
    required this.output,
    required super.category,
  });
}

/// A LaTeX snippet that may contain placeholders for the cursor.
///
/// For example, `LatexSnippet(display: 'a/b', output: '\\frac{}{}', cursorOffset: 3, category: MathSymbolCategory.common)`
/// inserts `\frac{}{}` and positions the cursor inside the first `{}`.
class LatexSnippet extends MathSymbolItem {
  /// What gets inserted into the text field.
  final String output;

  /// How many characters back from the end to position the cursor.
  final int cursorOffset;

  const LatexSnippet({
    required super.display,
    required this.output,
    required this.cursorOffset,
    required super.category,
  });
}

/// A LaTeX wrapper that wraps selected text with prefix and suffix.
///
/// When no text is selected, inserts the prefix and suffix with the cursor
/// between them. For example, `LatexWrapper(display: '\$…\$', prefix: '\$\$', suffix: '\$\$', category: MathSymbolCategory.templates)`
/// wraps selected text in `$$` delimiters.
class LatexWrapper extends MathSymbolItem {
  /// The text to insert before the cursor/selection.
  final String prefix;

  /// The text to insert after the cursor/selection.
  final String suffix;

  const LatexWrapper({
    required super.display,
    required this.prefix,
    required this.suffix,
    required super.category,
  });
}

/// 常用标签左栏：数字+运算符
const kCommonLeftSymbols = <UnicodeSymbol>[
  UnicodeSymbol(display: '0', output: '0', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '1', output: '1', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '2', output: '2', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '3', output: '3', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '4', output: '4', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '5', output: '5', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '6', output: '6', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '7', output: '7', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '8', output: '8', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '9', output: '9', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '.', output: '.', category: MathSymbolCategory.common),
  UnicodeSymbol(display: ',', output: ',', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '+', output: '+', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '−', output: '−', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '×', output: '×', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '÷', output: '÷', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '=', output: '=', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '√', output: '√', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '⋅', output: '⋅', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '|', output: '|', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '/', output: '/', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '≠', output: '≠', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '(', output: '(', category: MathSymbolCategory.common),
  UnicodeSymbol(display: ')', output: ')', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '[', output: '[', category: MathSymbolCategory.common),
  UnicodeSymbol(display: ']', output: ']', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '{', output: '{', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '}', output: '}', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '≤', output: '≤', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '≥', output: '≥', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '<', output: '<', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '>', output: '>', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '_', output: '_', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '^', output: '^', category: MathSymbolCategory.common),
];

/// 常用标签右栏：字母+高频希腊字母
const kCommonRightSymbols = <UnicodeSymbol>[
  UnicodeSymbol(display: 'A', output: 'A', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'B', output: 'B', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'C', output: 'C', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'D', output: 'D', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'E', output: 'E', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'F', output: 'F', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'G', output: 'G', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'H', output: 'H', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'I', output: 'I', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'J', output: 'J', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'K', output: 'K', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'L', output: 'L', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'M', output: 'M', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'N', output: 'N', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'O', output: 'O', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'P', output: 'P', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'Q', output: 'Q', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'R', output: 'R', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'S', output: 'S', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'T', output: 'T', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'U', output: 'U', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'V', output: 'V', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'W', output: 'W', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'X', output: 'X', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'Y', output: 'Y', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'Z', output: 'Z', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'α', output: 'α', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'β', output: 'β', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'γ', output: 'γ', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'θ', output: 'θ', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'λ', output: 'λ', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'π', output: 'π', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'Δ', output: 'Δ', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'Σ', output: 'Σ', category: MathSymbolCategory.common),
  UnicodeSymbol(display: 'Ω', output: 'Ω', category: MathSymbolCategory.common),
  UnicodeSymbol(display: '∞', output: '∞', category: MathSymbolCategory.common),
];

/// All math symbols, organized by category.
const kMathSymbols = <MathSymbolCategory, List<MathSymbolItem>>{
  MathSymbolCategory.common: [
    ...kCommonLeftSymbols,
    ...kCommonRightSymbols,
  ],

  MathSymbolCategory.relations: [
    UnicodeSymbol(display: '=',  output: '=',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '≠',  output: '≠',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '≡',  output: '≡',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '≈',  output: '≈',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '≅',  output: '≅',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∝',  output: '∝',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '<',  output: '<',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '>',  output: '>',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '≤',  output: '≤',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '≥',  output: '≥',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '≪',  output: '≪',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '≫',  output: '≫',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∥',  output: '∥',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '⊥',  output: '⊥',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∠',  output: '∠',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '△',  output: '△',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∼',  output: '∼',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '±',  output: '±',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∈',  output: '∈',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∉',  output: '∉',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '⊆',  output: '⊆',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '⊇',  output: '⊇',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '⊂',  output: '⊂',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '⊃',  output: '⊃',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∪',  output: '∪',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∩',  output: '∩',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∖',  output: '∖',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∅',  output: '∅',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∀',  output: '∀',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∃',  output: '∃',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '⇒',  output: '⇒',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '⇔',  output: '⇔',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∧',  output: '∧',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '∨',  output: '∨',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '→',  output: '→',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '←',  output: '←',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '↑',  output: '↑',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '↓',  output: '↓',  category: MathSymbolCategory.relations),
  ],

  MathSymbolCategory.functions: [
    // 三角函数
    UnicodeSymbol(display: 'sin', output: 'sin', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: 'cos', output: 'cos', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: 'tan', output: 'tan', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: 'cot', output: 'cot', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: 'sec', output: 'sec', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: 'csc', output: 'csc', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: 'arcsin', output: 'arcsin', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: 'arccos', output: 'arccos', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: 'arctan', output: 'arctan', category: MathSymbolCategory.functions),
    // 对数+极限
    UnicodeSymbol(display: 'log', output: 'log', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: 'ln', output: 'ln', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: 'lg', output: 'lg', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: 'lim', output: 'lim', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: 'max', output: 'max', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: 'min', output: 'min', category: MathSymbolCategory.functions),
    // 微积分符号
    UnicodeSymbol(display: '∫', output: '∫', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: '∬', output: '∬', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: '∮', output: '∮', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: '∑', output: '∑', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: '∏', output: '∏', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: '∂', output: '∂', category: MathSymbolCategory.functions),
    UnicodeSymbol(display: '∇', output: '∇', category: MathSymbolCategory.functions),
  ],

  MathSymbolCategory.greek: [
    // Lowercase
    UnicodeSymbol(display: 'α', output: 'α', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'β', output: 'β', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'γ', output: 'γ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'δ', output: 'δ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'ε', output: 'ε', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'ζ', output: 'ζ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'η', output: 'η', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'θ', output: 'θ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'ι', output: 'ι', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'κ', output: 'κ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'λ', output: 'λ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'μ', output: 'μ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'ν', output: 'ν', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'ξ', output: 'ξ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'ο', output: 'ο', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'π', output: 'π', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'ρ', output: 'ρ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'σ', output: 'σ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'τ', output: 'τ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'υ', output: 'υ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'φ', output: 'φ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'χ', output: 'χ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'ψ', output: 'ψ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'ω', output: 'ω', category: MathSymbolCategory.greek),
    // Uppercase
    UnicodeSymbol(display: 'Α', output: 'Α', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Β', output: 'Β', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Γ', output: 'Γ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Δ', output: 'Δ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Ε', output: 'Ε', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Ζ', output: 'Ζ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Η', output: 'Η', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Θ', output: 'Θ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Ι', output: 'Ι', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Κ', output: 'Κ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Λ', output: 'Λ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Μ', output: 'Μ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Ν', output: 'Ν', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Ξ', output: 'Ξ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Ο', output: 'Ο', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Π', output: 'Π', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Ρ', output: 'Ρ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Σ', output: 'Σ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Τ', output: 'Τ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Υ', output: 'Υ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Φ', output: 'Φ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Χ', output: 'Χ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Ψ', output: 'Ψ', category: MathSymbolCategory.greek),
    UnicodeSymbol(display: 'Ω', output: 'Ω', category: MathSymbolCategory.greek),
  ],

  MathSymbolCategory.templates: [
    LatexSnippet(display: 'a/b',    output: '\\frac{}{}',              cursorOffset: 3, category: MathSymbolCategory.templates),
    LatexSnippet(display: '√□',     output: '\\sqrt{}',                cursorOffset: 1, category: MathSymbolCategory.templates),
    LatexSnippet(display: 'ⁿ√□',    output: '\\sqrt[n]{}',             cursorOffset: 1, category: MathSymbolCategory.templates),
    LatexSnippet(display: 'xₙᵐ',    output: '_{}^{}',                  cursorOffset: 4, category: MathSymbolCategory.templates),
    LatexSnippet(display: '∑ⁿᵢ₌₁',  output: '\\sum_{i=1}^{n}',        cursorOffset: 0, category: MathSymbolCategory.templates),
    LatexSnippet(display: '∫ᵃᵇ',    output: '\\int_{a}^{b}',           cursorOffset: 0, category: MathSymbolCategory.templates),
    LatexSnippet(display: 'lim→∞',  output: '\\lim_{x \\to \\infty}', cursorOffset: 0, category: MathSymbolCategory.templates),
    LatexSnippet(display: '矩阵',    output: '\\begin{pmatrix}\n\\end{pmatrix}', cursorOffset: 14, category: MathSymbolCategory.templates),
    LatexSnippet(display: '分段',    output: '\\begin{cases}\n\\end{cases}',     cursorOffset: 11, category: MathSymbolCategory.templates),
    LatexWrapper(display: '\$…\$',  prefix: '\$', suffix: '\$', category: MathSymbolCategory.templates),
    LatexWrapper(display: '\$\$…\$\$', prefix: '\$\$', suffix: '\$\$', category: MathSymbolCategory.templates),
    LatexSnippet(display: 'logₐb', output: '\\log_{}{}', cursorOffset: 3, category: MathSymbolCategory.templates),
    LatexWrapper(display: '{…}', prefix: '\\{', suffix: '\\}', category: MathSymbolCategory.templates),
    LatexSnippet(display: 'align', output: '\\begin{align}\n\\end{align}', cursorOffset: 14, category: MathSymbolCategory.templates),
    LatexSnippet(display: 'C(n,k)', output: '\\binom{}{}', cursorOffset: 3, category: MathSymbolCategory.templates),
  ],

  MathSymbolCategory.recent: [],
};
