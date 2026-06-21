/// Data definitions for the math symbols toolbar.

/// Categories for organizing math symbols in the toolbar.
enum MathSymbolCategory {
  common,
  greek,
  operators,
  relations,
  sets,
  templates,
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

/// All math symbols, organized by category.
const kMathSymbols = <MathSymbolCategory, List<MathSymbolItem>>{
  MathSymbolCategory.common: [
    // Functions
    LatexSnippet(display: 'sin',    output: '\\sin',    cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'cos',    output: '\\cos',    cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'tan',    output: '\\tan',    cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'cot',    output: '\\cot',    cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'sec',    output: '\\sec',    cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'csc',    output: '\\csc',    cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'arcsin', output: '\\arcsin', cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'arccos', output: '\\arccos', cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'arctan', output: '\\arctan', cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'log',    output: '\\log',    cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'ln',     output: '\\ln',     cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'lg',     output: '\\lg',     cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'lim',    output: '\\lim',    cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'max',    output: '\\max',    cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'min',    output: '\\min',    cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'sup',    output: '\\sup',    cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'inf',    output: '\\inf',    cursorOffset: 0, category: MathSymbolCategory.common),
    LatexSnippet(display: 'arg',    output: '\\arg',    cursorOffset: 0, category: MathSymbolCategory.common),
    // Common symbols
    UnicodeSymbol(display: '±', output: '±', category: MathSymbolCategory.common),
    UnicodeSymbol(display: '×', output: '×', category: MathSymbolCategory.common),
    UnicodeSymbol(display: '÷', output: '÷', category: MathSymbolCategory.common),
    UnicodeSymbol(display: '√', output: '√', category: MathSymbolCategory.common),
    UnicodeSymbol(display: '∞', output: '∞', category: MathSymbolCategory.common),
    UnicodeSymbol(display: '∠', output: '∠', category: MathSymbolCategory.common),
    UnicodeSymbol(display: '°', output: '°', category: MathSymbolCategory.common),
    UnicodeSymbol(display: '≠', output: '≠', category: MathSymbolCategory.common),
    UnicodeSymbol(display: '≤', output: '≤', category: MathSymbolCategory.common),
    UnicodeSymbol(display: '≥', output: '≥', category: MathSymbolCategory.common),
    UnicodeSymbol(display: '∈', output: '∈', category: MathSymbolCategory.common),
    // LaTeX snippets
    LatexSnippet(display: 'a/b', output: '\\frac{}{}', cursorOffset: 3, category: MathSymbolCategory.common),
    LatexSnippet(display: '√□',  output: '\\sqrt{}',   cursorOffset: 1, category: MathSymbolCategory.common),
    LatexSnippet(display: 'xⁿ',  output: '^{}',        cursorOffset: 1, category: MathSymbolCategory.common),
    LatexSnippet(display: 'xₙ',  output: '_{}',        cursorOffset: 1, category: MathSymbolCategory.common),
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

  MathSymbolCategory.operators: [
    UnicodeSymbol(display: '±', output: '±', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '×', output: '×', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '÷', output: '÷', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '∘', output: '∘', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '⊙', output: '⊙', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '⊗', output: '⊗', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '⊕', output: '⊕', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '∂', output: '∂', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '∇', output: '∇', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '∫', output: '∫', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '∬', output: '∬', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '∮', output: '∮', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '∑', output: '∑', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '∏', output: '∏', category: MathSymbolCategory.operators),
    UnicodeSymbol(display: '∞', output: '∞', category: MathSymbolCategory.operators),
  ],

  MathSymbolCategory.relations: [
    UnicodeSymbol(display: '=',  output: '=',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '≠',  output: '≠',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '≡',  output: '≡',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '≈',  output: '≈',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '≅',  output: '≅',  category: MathSymbolCategory.relations),
    UnicodeSymbol(display: '≃',  output: '≃',  category: MathSymbolCategory.relations),
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
  ],

  MathSymbolCategory.sets: [
    UnicodeSymbol(display: '∈', output: '∈', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: '∉', output: '∉', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: '⊆', output: '⊆', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: '⊇', output: '⊇', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: '⊂', output: '⊂', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: '⊃', output: '⊃', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: '⊈', output: '⊈', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: '⊉', output: '⊉', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: '∪', output: '∪', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: '∩', output: '∩', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: '∖', output: '∖', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: '△', output: '△', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: '∅', output: '∅', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: '𝕌', output: '𝕌', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: 'ℕ', output: 'ℕ', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: 'ℤ', output: 'ℤ', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: 'ℚ', output: 'ℚ', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: 'ℝ', output: 'ℝ', category: MathSymbolCategory.sets),
    UnicodeSymbol(display: 'ℂ', output: 'ℂ', category: MathSymbolCategory.sets),
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
    LatexWrapper(display: '\$…\$',  prefix: '\$\$', suffix: '\$\$', category: MathSymbolCategory.templates),
    LatexWrapper(display: '```math', prefix: '```math\n', suffix: '\n```', category: MathSymbolCategory.templates),
  ],
};
