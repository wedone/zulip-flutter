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

  // Step 3: Restore protected regions.
  text = _restoreProtected(text, protectedRegions);

  return text;
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
