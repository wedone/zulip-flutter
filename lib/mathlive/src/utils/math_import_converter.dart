import 'math_normalize.dart' show normalizeLatexForFlutterMath;

/// Converts plain text into LaTeX that MathLive can import without mis-parsing prose.
String convertOuterPlainTextToMathliveLatex(String raw) {
  final String normalizedWs = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final String t = normalizedWs.trim();
  if (t.isEmpty) {
    return t;
  }
  final String normalized = normalizeLatexForFlutterMath(t);
  if (_shouldPassThroughAsMathLatex(normalized)) {
    return normalized.trim();
  }
  return r'\text{' + _escapeLatexTextBody(normalized) + r'}';
}

bool _shouldPassThroughAsMathLatex(String s) {
  if (RegExp(r'\\[a-zA-Z]').hasMatch(s)) {
    return true;
  }
  if (s.contains('^') || s.contains('_')) {
    return true;
  }
  if (s.contains('×') || s.contains('÷') || s.contains('·')) {
    return true;
  }
  if (RegExp(r'^[0-9+\-*/().=\s,;:]+$').hasMatch(s)) {
    return true;
  }
  return false;
}

String _escapeLatexTextBody(String s) {
  final StringBuffer b = StringBuffer();
  for (final int c in s.runes) {
    if (c == 0x5C) {
      b.write(r'\textbackslash{}');
    } else if (c == 0x7B) {
      b.write(r'\{');
    } else if (c == 0x7D) {
      b.write(r'\}');
    } else if (c == 0x23) {
      b.write(r'\#');
    } else if (c == 0x24) {
      b.write(r'\$');
    } else if (c == 0x25) {
      b.write(r'\%');
    } else if (c == 0x26) {
      b.write(r'\&');
    } else if (c == 0x5E) {
      b.write(r'\^{}');
    } else if (c == 0x5F) {
      b.write(r'\_');
    } else if (c == 0x7E) {
      b.write(r'\textasciitilde{}');
    } else if (c == 0x0A) {
      b.write(r'\\');
    } else if (c == 0x09) {
      b.write(' ');
    } else {
      b.writeCharCode(c);
    }
  }
  return b.toString();
}
