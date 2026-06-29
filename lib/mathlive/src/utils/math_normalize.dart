/// True when [text] should use [MathLiveMixedPreview] (mixed `\(...\)` or LaTeX commands).
bool textUsesMathLivePreview(String text) => threadTextUsesMixedMathPreview(text);

/// @nodoc
bool threadTextUsesMixedMathPreview(String text) {
  final String t = text.trim();
  if (t.isEmpty) {
    return false;
  }
  if (t.contains(r'\(') && t.contains(r'\)')) {
    return true;
  }
  if (RegExp(
    r'\\(?:frac|dfrac|sqrt|int|sum|prod|alpha|beta|gamma|pi|infty|partial|nabla|mathrm|text|big|Big|left|right|bigm|cdot|times|div|pm|mp|leq|geq|neq|approx|equiv|forall|exists|ldots|cdots|dots|quad|qquad)\b',
  ).hasMatch(t)) {
    return true;
  }
  return false;
}

/// Normalizes MathLive / editor LaTeX for the lightweight inline renderer.
String normalizeLatexForFlutterMath(String tex) {
  if (tex.trim().isEmpty) {
    return tex;
  }
  String s = tex;
  s = s.replaceAllMapped(
    RegExp(r'\\placeholder\*?(?:\[[^\]]*\])?\{[^}]*\}'),
    (_) => r'\square',
  );
  s = s.replaceAll(RegExp(r'\\placeholder\b'), r'\square');
  return s;
}

/// Wraps common LaTeX fragments in `\(`…`\)` when delimiters were omitted.
String normalizeInlineMath(String input) => normalizeMentorEditorInlineMath(input);

/// @nodoc
String normalizeMentorEditorInlineMath(String input) {
  if (input.isEmpty) {
    return input;
  }
  final StringBuffer out = StringBuffer();
  int i = 0;
  while (i < input.length) {
    if (_startsWithInlineMathOpen(input, i)) {
      final int? close = _indexOfInlineMathClose(input, i + 2);
      if (close == null) {
        out.write(input.substring(i));
        break;
      }
      out.write(input.substring(i, close + 2));
      i = close + 2;
      continue;
    }
    if (input.startsWith(r'\sqrt{', i)) {
      final String? frag = _extractSqrt(input, i);
      if (frag != null) {
        out.write(r'\(');
        out.write(frag);
        out.write(r'\)');
        i += frag.length;
        continue;
      }
    }
    if (input.startsWith(r'\frac{', i)) {
      final String? frag = _extractFrac(input, i);
      if (frag != null) {
        out.write(r'\(');
        out.write(frag);
        out.write(r'\)');
        i += frag.length;
        continue;
      }
    }
    out.write(input[i]);
    i++;
  }
  return out.toString();
}

bool _startsWithInlineMathOpen(String s, int i) {
  return i + 1 < s.length && s.codeUnitAt(i) == 0x5C && s[i + 1] == '(';
}

int? _indexOfInlineMathClose(String s, int from) {
  int j = from;
  while (j + 1 < s.length) {
    if (s.codeUnitAt(j) == 0x5C && s[j + 1] == ')') {
      return j;
    }
    j++;
  }
  return null;
}

int? _endAfterBalancedBrace(String s, int openBraceIndex) {
  if (openBraceIndex >= s.length || s[openBraceIndex] != '{') {
    return null;
  }
  int depth = 0;
  for (int p = openBraceIndex; p < s.length; p++) {
    final int c = s.codeUnitAt(p);
    if (c == 0x7B) {
      depth++;
    } else if (c == 0x7D) {
      depth--;
      if (depth == 0) {
        return p + 1;
      }
    }
  }
  return null;
}

String? _extractSqrt(String s, int start) {
  if (!s.startsWith(r'\sqrt{', start)) {
    return null;
  }
  final int open = start + 5;
  final int? end = _endAfterBalancedBrace(s, open);
  if (end == null) {
    return null;
  }
  return s.substring(start, end);
}

String? _extractFrac(String s, int start) {
  if (!s.startsWith(r'\frac{', start)) {
    return null;
  }
  final int openNum = start + 5;
  final int? afterNum = _endAfterBalancedBrace(s, openNum);
  if (afterNum == null || afterNum >= s.length || s[afterNum] != '{') {
    return null;
  }
  final int? afterDen = _endAfterBalancedBrace(s, afterNum);
  if (afterDen == null) {
    return null;
  }
  return s.substring(start, afterDen);
}
