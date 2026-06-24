/// Data definitions for the math symbols toolbar.
library;

/// Categories for organizing math keyboard symbols.
enum MathKeyboardCategory {
  common,
  relations,
  functions,
  greek,
  templates,
  recent,
}

/// An item in the math keyboard toolbar.
sealed class MathKeyboardItem {
  /// What's shown on the toolbar button.
  final String display;

  /// The category this symbol belongs to.
  final MathKeyboardCategory category;

  const MathKeyboardItem({required this.display, required this.category});
}

/// A single Unicode character, shown and inserted as-is.
///
/// For example, `UnicodeSymbol(display: 'α', output: 'α', category: MathKeyboardCategory.greek)`.
class UnicodeSymbol extends MathKeyboardItem {
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
/// For example, `LatexSnippet(display: 'a/b', output: '\\frac{}{}', cursorOffset: 3, category: MathKeyboardCategory.common)`
/// inserts `\frac{}{}` and positions the cursor inside the first `{}`.
class LatexSnippet extends MathKeyboardItem {
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
/// between them. For example, `LatexWrapper(display: '\$…\$', prefix: '\$\$', suffix: '\$\$', category: MathKeyboardCategory.templates)`
/// wraps selected text in `$$` delimiters.
class LatexWrapper extends MathKeyboardItem {
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

/// 常用标签左栏：数字+运算符+成对符号+模板
const kCommonLeftSymbols = <MathKeyboardItem>[
  // 第1行: 数字 0-3
  UnicodeSymbol(display: '0', output: '0', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '1', output: '1', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '2', output: '2', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '3', output: '3', category: MathKeyboardCategory.common),
  // 第2行: 数字 4-7
  UnicodeSymbol(display: '4', output: '4', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '5', output: '5', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '6', output: '6', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '7', output: '7', category: MathKeyboardCategory.common),
  // 第3行: 数字 8-9 + 小数点 + 等号
  UnicodeSymbol(display: '8', output: '8', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '9', output: '9', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '.', output: '.', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '=', output: '=', category: MathKeyboardCategory.common),
  // 第4行: 四则运算
  UnicodeSymbol(display: '+', output: '+', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '−', output: '−', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '×', output: '×', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '/', output: '/', category: MathKeyboardCategory.common),
  // 第5行: 根号+点乘+逗号+行内公式界定符
  UnicodeSymbol(display: '√', output: '√', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '⋅', output: '⋅', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: ',', output: ',', category: MathKeyboardCategory.common),
  LatexSnippet(display: '\$\$', output: '\$\$', cursorOffset: 1, category: MathKeyboardCategory.common),
  // 第6行: 成对括号（光标在中间）
  LatexSnippet(display: '()', output: '()', cursorOffset: 1, category: MathKeyboardCategory.common),
  LatexSnippet(display: '[]', output: '[]', cursorOffset: 1, category: MathKeyboardCategory.common),
  LatexSnippet(display: '{}', output: '{}', cursorOffset: 1, category: MathKeyboardCategory.common),
  LatexSnippet(display: '||', output: '||', cursorOffset: 1, category: MathKeyboardCategory.common),
  // 第7行: 关系符+上下标
  UnicodeSymbol(display: '<', output: '<', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '>', output: '>', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '_', output: '_', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '^', output: '^', category: MathKeyboardCategory.common),
  // 第8行: 上标+LaTeX模板
  UnicodeSymbol(display: '²', output: '²', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '³', output: '³', category: MathKeyboardCategory.common),
  LatexSnippet(display: 'a/b', output: '\\frac{}{}', cursorOffset: 3, category: MathKeyboardCategory.common),
  LatexSnippet(display: 'xₙᵐ', output: '_{}^{}', cursorOffset: 4, category: MathKeyboardCategory.common),
  // 第9行: 根号模板+向量
  LatexSnippet(display: '√□', output: '\\sqrt{}', cursorOffset: 1, category: MathKeyboardCategory.common),
  LatexSnippet(display: 'ⁿ√□', output: '\\sqrt[n]{}', cursorOffset: 1, category: MathKeyboardCategory.common),
  LatexSnippet(display: '向量', output: '\\vec{}', cursorOffset: 1, category: MathKeyboardCategory.common),
];

/// 常用标签右栏：26个英文字母+高频希腊字母
const kCommonRightSymbols = <UnicodeSymbol>[
  // A-H
  UnicodeSymbol(display: 'A', output: 'A', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'B', output: 'B', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'C', output: 'C', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'D', output: 'D', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'E', output: 'E', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'F', output: 'F', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'G', output: 'G', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'H', output: 'H', category: MathKeyboardCategory.common),
  // I-P
  UnicodeSymbol(display: 'I', output: 'I', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'J', output: 'J', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'K', output: 'K', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'L', output: 'L', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'M', output: 'M', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'N', output: 'N', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'O', output: 'O', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'P', output: 'P', category: MathKeyboardCategory.common),
  // Q-T
  UnicodeSymbol(display: 'Q', output: 'Q', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'R', output: 'R', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'S', output: 'S', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'T', output: 'T', category: MathKeyboardCategory.common),
  // U-X
  UnicodeSymbol(display: 'U', output: 'U', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'V', output: 'V', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'W', output: 'W', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'X', output: 'X', category: MathKeyboardCategory.common),
  // Y-Z + 高频希腊字母
  UnicodeSymbol(display: 'Y', output: 'Y', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'Z', output: 'Z', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'α', output: 'α', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'β', output: 'β', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'γ', output: 'γ', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'θ', output: 'θ', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'λ', output: 'λ', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'π', output: 'π', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'Δ', output: 'Δ', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'Σ', output: 'Σ', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: 'Ω', output: 'Ω', category: MathKeyboardCategory.common),
  UnicodeSymbol(display: '∞', output: '∞', category: MathKeyboardCategory.common),
];

/// All math symbols, organized by category.
const kMathKeyboard = <MathKeyboardCategory, List<MathKeyboardItem>>{
  MathKeyboardCategory.common: [
    ...kCommonLeftSymbols,
    ...kCommonRightSymbols,
  ],

  MathKeyboardCategory.relations: [
    UnicodeSymbol(display: '=',  output: '=',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '≠',  output: '≠',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '≡',  output: '≡',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '≈',  output: '≈',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '≅',  output: '≅',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∝',  output: '∝',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '<',  output: '<',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '>',  output: '>',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '≤',  output: '≤',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '≥',  output: '≥',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '≪',  output: '≪',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '≫',  output: '≫',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∥',  output: '∥',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '⊥',  output: '⊥',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∠',  output: '∠',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '△',  output: '△',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∼',  output: '∼',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '±',  output: '±',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∈',  output: '∈',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∉',  output: '∉',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '⊆',  output: '⊆',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '⊇',  output: '⊇',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '⊂',  output: '⊂',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '⊃',  output: '⊃',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∪',  output: '∪',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∩',  output: '∩',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∖',  output: '∖',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∅',  output: '∅',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∀',  output: '∀',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∃',  output: '∃',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '⇒',  output: '⇒',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '⇔',  output: '⇔',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∧',  output: '∧',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '∨',  output: '∨',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '→',  output: '→',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '←',  output: '←',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '↑',  output: '↑',  category: MathKeyboardCategory.relations),
    UnicodeSymbol(display: '↓',  output: '↓',  category: MathKeyboardCategory.relations),
  ],

  MathKeyboardCategory.functions: [
    // 三角函数
    UnicodeSymbol(display: 'sin', output: 'sin', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: 'cos', output: 'cos', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: 'tan', output: 'tan', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: 'cot', output: 'cot', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: 'sec', output: 'sec', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: 'csc', output: 'csc', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: 'arcsin', output: 'arcsin', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: 'arccos', output: 'arccos', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: 'arctan', output: 'arctan', category: MathKeyboardCategory.functions),
    // 对数+极限
    UnicodeSymbol(display: 'log', output: 'log', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: 'ln', output: 'ln', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: 'lg', output: 'lg', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: 'lim', output: 'lim', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: 'max', output: 'max', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: 'min', output: 'min', category: MathKeyboardCategory.functions),
    // 微积分符号
    UnicodeSymbol(display: '∫', output: '∫', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: '∬', output: '∬', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: '∮', output: '∮', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: '∑', output: '∑', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: '∏', output: '∏', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: '∂', output: '∂', category: MathKeyboardCategory.functions),
    UnicodeSymbol(display: '∇', output: '∇', category: MathKeyboardCategory.functions),
  ],

  MathKeyboardCategory.greek: [
    // Lowercase
    UnicodeSymbol(display: 'α', output: 'α', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'β', output: 'β', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'γ', output: 'γ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'δ', output: 'δ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'ε', output: 'ε', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'ζ', output: 'ζ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'η', output: 'η', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'θ', output: 'θ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'ι', output: 'ι', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'κ', output: 'κ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'λ', output: 'λ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'μ', output: 'μ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'ν', output: 'ν', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'ξ', output: 'ξ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'ο', output: 'ο', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'π', output: 'π', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'ρ', output: 'ρ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'σ', output: 'σ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'τ', output: 'τ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'υ', output: 'υ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'φ', output: 'φ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'χ', output: 'χ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'ψ', output: 'ψ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'ω', output: 'ω', category: MathKeyboardCategory.greek),
    // Uppercase
    UnicodeSymbol(display: 'Α', output: 'Α', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Β', output: 'Β', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Γ', output: 'Γ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Δ', output: 'Δ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Ε', output: 'Ε', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Ζ', output: 'Ζ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Η', output: 'Η', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Θ', output: 'Θ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Ι', output: 'Ι', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Κ', output: 'Κ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Λ', output: 'Λ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Μ', output: 'Μ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Ν', output: 'Ν', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Ξ', output: 'Ξ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Ο', output: 'Ο', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Π', output: 'Π', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Ρ', output: 'Ρ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Σ', output: 'Σ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Τ', output: 'Τ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Υ', output: 'Υ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Φ', output: 'Φ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Χ', output: 'Χ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Ψ', output: 'Ψ', category: MathKeyboardCategory.greek),
    UnicodeSymbol(display: 'Ω', output: 'Ω', category: MathKeyboardCategory.greek),
  ],

  MathKeyboardCategory.templates: [
    LatexSnippet(display: 'a/b',    output: '\\frac{}{}',              cursorOffset: 3, category: MathKeyboardCategory.templates),
    LatexSnippet(display: '√□',     output: '\\sqrt{}',                cursorOffset: 1, category: MathKeyboardCategory.templates),
    LatexSnippet(display: 'ⁿ√□',    output: '\\sqrt[n]{}',             cursorOffset: 1, category: MathKeyboardCategory.templates),
    LatexSnippet(display: 'xₙᵐ',    output: '_{}^{}',                  cursorOffset: 4, category: MathKeyboardCategory.templates),
    LatexSnippet(display: '∑ⁿᵢ₌₁',  output: '\\sum_{i=1}^{n}',        cursorOffset: 0, category: MathKeyboardCategory.templates),
    LatexSnippet(display: '∫ᵃᵇ',    output: '\\int_{a}^{b}',           cursorOffset: 0, category: MathKeyboardCategory.templates),
    LatexSnippet(display: 'lim→∞',  output: '\\lim_{x \\to \\infty}', cursorOffset: 0, category: MathKeyboardCategory.templates),
    LatexSnippet(display: '矩阵',    output: '\\begin{pmatrix}\n\\end{pmatrix}', cursorOffset: 14, category: MathKeyboardCategory.templates),
    LatexSnippet(display: '分段',    output: '\\begin{cases}\n\\end{cases}',     cursorOffset: 11, category: MathKeyboardCategory.templates),
    LatexWrapper(display: '\$…\$',  prefix: '\$', suffix: '\$', category: MathKeyboardCategory.templates),
    LatexWrapper(display: '\$\$\\n…\\n\$\$', prefix: '\$\$\n', suffix: '\n\$\$', category: MathKeyboardCategory.templates),
    LatexSnippet(display: 'logₐb', output: '\\log_{}{}', cursorOffset: 3, category: MathKeyboardCategory.templates),
    LatexWrapper(display: '{…}', prefix: '\\{', suffix: '\\}', category: MathKeyboardCategory.templates),
    LatexSnippet(display: 'align', output: '\\begin{align}\n\\end{align}', cursorOffset: 14, category: MathKeyboardCategory.templates),
    LatexSnippet(display: 'C(n,k)', output: '\\binom{}{}', cursorOffset: 3, category: MathKeyboardCategory.templates),
  ],

  MathKeyboardCategory.recent: [],
};
