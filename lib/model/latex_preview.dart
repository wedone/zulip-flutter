/// Finds the LaTeX formula at the cursor position for live preview.
///
/// This module detects paired LaTeX delimiters around the cursor
/// and returns the formula content for rendering.
library;

/// Result of finding a LaTeX formula at the cursor.
///
/// [content] is the formula text between delimiters (delimiters excluded).
/// [displayMode] is true for display math, false for inline math.
typedef LatexAtCursor = ({String content, bool displayMode});

/// Finds the LaTeX formula at [cursorPosition] in [text].
///
/// Returns a [LatexAtCursor] if the cursor is inside a pair of matched
/// delimiters, or null if no formula is found.
///
/// Delimiter types checked in order (longer delimiters first to avoid
/// `$$` being misinterpreted as two `$`):
/// 1. `$$...$$` with newlines inside (display math)
/// 2. `$$...$$` without newlines (inline math, for preview purposes)
/// 3. `\[...\]` (display math)
/// 4. `\(...\)` (inline math)
/// 5. `$...$` (inline math, content must not contain `$` or newlines)
///
/// Escaped delimiters (preceded by odd number of backslashes) are not matched.
LatexAtCursor? findLatexAtCursor(String text, int cursorPosition) {
  if (cursorPosition < 0 || cursorPosition > text.length) return null;
  if (text.isEmpty) return null;

  // Try each delimiter type in order of precedence.
  return _findDollarDollarDisplay(text, cursorPosition)
      ?? _findDollarDollarInline(text, cursorPosition)
      ?? _findDisplayBrackets(text, cursorPosition)
      ?? _findInlineParentheses(text, cursorPosition)
      ?? _findSingleDollar(text, cursorPosition);
}

/// Finds `$$...$$` with newlines inside (display math).
LatexAtCursor? _findDollarDollarDisplay(String text, int cursorPosition) {
  // (?<!\\) ensures the opening $$ is not escaped.
  // (?<!\$) ensures it's not preceded by another $ (not part of $$$).
  // (?!\$) after closing $$ ensures it's not followed by another $.
  final pattern = RegExp(r'(?<!\\)(?<!\$)\$\$([\s\S]*?\n[\s\S]*?)\$\$(?!\$)');
  for (final match in pattern.allMatches(text)) {
    final start = match.start;
    final end = match.end;
    // Cursor must be strictly inside the delimiters (not at the boundary).
    if (cursorPosition > start && cursorPosition < end) {
      return (content: match.group(1)!, displayMode: true);
    }
  }
  return null;
}

/// Finds `$$...$$` without newlines (inline math).
///
/// This handles the case where the user types `$$x^2$$` without newlines.
/// While this is Zulip's inline math format, for preview purposes we
/// still want to show the rendered formula.
LatexAtCursor? _findDollarDollarInline(String text, int cursorPosition) {
  final pattern = RegExp(r'(?<!\\)(?<!\$)\$\$([^\n$]*?)\$\$(?!\$)');
  for (final match in pattern.allMatches(text)) {
    final start = match.start;
    final end = match.end;
    if (cursorPosition > start && cursorPosition < end) {
      return (content: match.group(1)!, displayMode: false);
    }
  }
  return null;
}

/// Finds `\[...\]` (display math).
LatexAtCursor? _findDisplayBrackets(String text, int cursorPosition) {
  // (?<!\\) before \[ ensures it's not escaped (like \\[).
  // (?<!\\) before \] ensures it's not escaped.
  final pattern = RegExp(r'(?<!\\)\\\[([\s\S]*?)(?<!\\)\\\]');
  for (final match in pattern.allMatches(text)) {
    final start = match.start;
    final end = match.end;
    // Cursor must be strictly inside the delimiters.
    if (cursorPosition > start && cursorPosition < end) {
      return (content: match.group(1)!, displayMode: true);
    }
  }
  return null;
}

/// Finds `\(...\)` (inline math).
LatexAtCursor? _findInlineParentheses(String text, int cursorPosition) {
  final pattern = RegExp(r'(?<!\\)\\\(([\s\S]*?)(?<!\\)\\\)');
  for (final match in pattern.allMatches(text)) {
    final start = match.start;
    final end = match.end;
    if (cursorPosition > start && cursorPosition < end) {
      return (content: match.group(1)!, displayMode: false);
    }
  }
  return null;
}

/// Finds `$...$` (inline math).
///
/// Uses regex pattern similar to latex_converter.dart but with escape check:
/// - `(?<!\\)(?<!\$)\$(?!\$)` matches a single `$` not escaped and not part of `$$`
/// - `([^\n$]*?)` content must not contain `$` or newlines
/// - `\$(?!\$)` closing `$` not part of `$$`
LatexAtCursor? _findSingleDollar(String text, int cursorPosition) {
  final pattern = RegExp(r'(?<!\\)(?<!\$)\$(?!\$)([^\n$]*?)\$(?!\$)');
  for (final match in pattern.allMatches(text)) {
    final start = match.start;
    final end = match.end;
    if (cursorPosition > start && cursorPosition < end) {
      return (content: match.group(1)!, displayMode: false);
    }
  }
  return null;
}