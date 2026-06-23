/// Converts standard LaTeX delimiters to Zulip's non-standard format.
///
/// Zulip uses:
/// - `$$...$$` for inline math (instead of standard `$...$`)
/// - `` ```math\n...\n``` `` for display math (instead of standard `$$...$$`)
///
/// The conversion rules applied in order:
/// 1. `\[...\]` → `` ```math\n...\n``` `` (LaTeX display → Zulip display)
/// 2. `$$...$$` with newlines inside → `` ```math\n...\n``` `` (standard display → Zulip display)
/// 3. `\(...\)` → `$$...$$` (LaTeX inline → Zulip inline)
/// 4. `$...$` → `$$...$$` (standard inline → Zulip inline)
///
/// Rules for display math (1, 2) are applied before rules for inline math
/// (3, 4) so that `$$...$$` produced by rule 3 won't be incorrectly
/// re-processed by rule 2.
///
/// Content inside code blocks, inline code, and existing ```math blocks
/// is protected from conversion. Escaped `\$` is also protected.
///
/// After conversion, zero-width spaces (U+200B) are inserted between `$$`
/// delimiters and adjacent `\w` characters (letters, digits, underscores).
/// This is necessary because the Zulip server's Markdown regex uses `\B`
/// (non-word-boundary) around `$$`, which rejects `$$` adjacent to `\w`
/// characters. The ZWSP breaks the word boundary without affecting rendering.
String convertLatexDelimitersToZulip(String input) {
  // Step 1: Protect regions that should not be converted.
  final protectedRegions = <_ProtectedRegion>[];
  var text = input;

  // Protect existing ```math blocks first (before generic code blocks,
  // so they don't get double-processed).
  text = _protectPattern(text, protectedRegions,
    RegExp(r'```math\n[\s\S]*?\n```'));

  // Protect code blocks (```...```), including the language hint.
  text = _protectPattern(text, protectedRegions,
    RegExp(r'```[^\n]*\n[\s\S]*?\n```'));

  // Protect inline code (`...`).
  text = _protectPattern(text, protectedRegions,
    RegExp(r'`[^`\n]+`'));

  // Protect escaped dollar signs (\$).
  text = _protectPattern(text, protectedRegions,
    RegExp(r'\\\$'));

  // Step 2: Apply conversion rules in order.

  // Rule 1: \[...\] → ```math\n...\n```
  text = text.replaceAllMapped(
    RegExp(r'\\\[([\s\S]*?)\\\]'),
    (m) => '```math\n${m[1]}\n```');

  // Protect newly created ```math blocks from Rule 1, so that
  // subsequent rules don't match $ signs inside them.
  text = _protectPattern(text, protectedRegions,
    RegExp(r'```math\n[\s\S]*?\n```'));

  // Rule 2: $$...$$ with newlines inside → ```math\n...\n```
  text = text.replaceAllMapped(
    RegExp(r'\$\$([\s\S]*?)\$\$'),
    (m) {
      final content = m[1]!;
      if (content.contains('\n')) {
        return '```math\n$content\n```';
      }
      return m[0]!; // Leave as-is (already Zulip inline format)
    });

  // Protect newly created ```math blocks from Rule 2, so that
  // subsequent rules don't match $ signs inside them.
  text = _protectPattern(text, protectedRegions,
    RegExp(r'```math\n[\s\S]*?\n```'));

  // Rule 3: \(...\) → $$...$$
  text = text.replaceAllMapped(
    RegExp(r'\\\(([\s\S]*?)\\\)'),
    (m) => '\$\$${m[1]}\$\$');

  // Rule 4: $...$ → $$...$$
  // Use negative lookbehind/ahead to avoid matching $$.
  // Use [^\n$]*? so that the content cannot contain $ (which would
  // indicate a broken or ambiguous delimiter).
  text = text.replaceAllMapped(
    RegExp(r'(?<!\$)\$(?!\$)([^\n$]*?)\$(?!\$)'),
    (m) => '\$\$${m[1]}\$\$');

  // Step 2.5: Insert zero-width spaces between $$ and adjacent \w characters.
  // The Zulip server's TEX_RE uses \B (non-word-boundary) around $$,
  // which fails when $$ is adjacent to a \w character (letter, digit, _).
  // Inserting ZWSP (U+200B, a \W character) breaks the word boundary
  // so the server regex matches, without affecting visual rendering.
  text = _insertZwspAroundDollarDollar(text);

  // Step 3: Restore protected regions.
  text = _restoreProtected(text, protectedRegions);

  return text;
}

/// Inserts zero-width spaces (U+200B) between `$$` delimiters and adjacent
/// `\w` characters, so the server's `\B` assertion passes.
///
/// For example, `a$$x^2$$b` becomes `a\u200B$$x^2$$\u200Bb`.
/// Characters like `#`, `%`, spaces, etc. are `\W` and need no separator.
String _insertZwspAroundDollarDollar(String text) {
  final pattern = RegExp(r'\$\$([\s\S]*?)\$\$');
  final result = StringBuffer();
  int lastEnd = 0;

  for (final match in pattern.allMatches(text)) {
    // Append text before this match.
    result.write(text.substring(lastEnd, match.start));

    // If the character before the opening $$ is a \w character,
    // insert ZWSP to break the word boundary for the server's \B check.
    if (match.start > 0) {
      final charBefore = text[match.start - 1];
      if (_isWordChar(charBefore)) {
        result.write('\u200B');
      }
    }

    // Append the full match ($$content$$).
    result.write(match[0]);

    // If the character after the closing $$ is a \w character,
    // insert ZWSP to break the word boundary for the server's \B check.
    if (match.end < text.length) {
      final charAfter = text[match.end];
      if (_isWordChar(charAfter)) {
        result.write('\u200B');
      }
    }

    lastEnd = match.end;
  }
  result.write(text.substring(lastEnd));
  return result.toString();
}

/// Whether [char] is a `\w` character (letter, digit, or underscore),
/// matching Python's `\w` behavior which the server regex relies on.
bool _isWordChar(String char) {
  // \w in Python matches [a-zA-Z0-9_] plus Unicode letters/digits
  // when the regex is not ASCII-only. We check the same categories.
  final rune = char.codeUnitAt(0);
  if (rune >= 0x30 && rune <= 0x39) return true; // 0-9
  if (rune >= 0x41 && rune <= 0x5A) return true; // A-Z
  if (rune >= 0x61 && rune <= 0x7A) return true; // a-z
  if (rune == 0x5F) return true;                  // _
  // Unicode letters (CJK, Greek, Cyrillic, etc.)
  return RegExp(r'\p{L}', unicode: true).hasMatch(char);
}

class _ProtectedRegion {
  final String placeholder;
  final String original;
  _ProtectedRegion(this.placeholder, this.original);
}

String _protectPattern(String text, List<_ProtectedRegion> regions, RegExp pattern) {
  return text.replaceAllMapped(pattern, (m) {
    final index = regions.length;
    final placeholder = '\x00PROTECTED_$index\x00';
    regions.add(_ProtectedRegion(placeholder, m[0]!));
    return placeholder;
  });
}

String _restoreProtected(String text, List<_ProtectedRegion> regions) {
  for (final region in regions.reversed) {
    text = text.replaceAll(region.placeholder, region.original);
  }
  return text;
}
