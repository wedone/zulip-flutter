import 'package:flutter/material.dart';

/// Renders a small subset of LaTeX used by the mentor editor (no external math package).
Widget buildSimpleLatexInline(String tex, TextStyle style) {
  final String t = tex.trim();
  if (t.isEmpty) {
    return const SizedBox.shrink();
  }
  final List<Widget> parts = _scan(t, style);
  if (parts.isEmpty) {
    return const SizedBox.shrink();
  }
  if (parts.length == 1) {
    return parts.first;
  }
  final bool allPlainText = parts.every((Widget w) => w is Text);
  if (allPlainText) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        for (int i = 0; i < parts.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 2),
          parts[i],
        ],
      ],
    );
  }
  return Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 2,
    runSpacing: 2,
    children: parts,
  );
}

const Map<String, String> _latexSymbol = <String, String>{
  'cdot': '·',
  'times': '×',
  'div': '÷',
  'pm': '±',
  'mp': '∓',
  'leq': '≤',
  'geq': '≥',
  'neq': '≠',
  'approx': '≈',
  'equiv': '≡',
  'infty': '∞',
  'pi': 'π',
  'theta': 'θ',
  'alpha': 'α',
  'beta': 'β',
  'gamma': 'γ',
  'delta': 'δ',
  'sigma': 'σ',
  'omega': 'ω',
  'sum': 'Σ',
  'prod': 'Π',
  'int': '∫',
  'partial': '∂',
  'cdots': '⋯',
  'ldots': '…',
  'rightarrow': '→',
  'leftarrow': '←',
  'Rightarrow': '⇒',
  'in': '∈',
  // MathLive placeholders normalized to TeX-style box commands
  'square': '□',
  'Box': '□',
};

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

({String num, String den, int end})? _parseFracAt(String s, int start) {
  if (!s.startsWith(r'\frac{', start)) {
    return null;
  }
  final int openNum = start + 5;
  final int? afterNum = _endAfterBalancedBrace(s, openNum);
  if (afterNum == null || afterNum >= s.length || s[afterNum] != '{') {
    return null;
  }
  final String num = s.substring(openNum + 1, afterNum - 1);
  final int openDen = afterNum;
  final int? afterDen = _endAfterBalancedBrace(s, openDen);
  if (afterDen == null) {
    return null;
  }
  final String den = s.substring(openDen + 1, afterDen - 1);
  return (num: num, den: den, end: afterDen);
}

/// `\sqrt[n]{x}` (n-th root).
({String index, String inner, int end})? _parseSqrtNAt(String s, int start) {
  if (!s.startsWith(r'\sqrt[', start)) {
    return null;
  }
  final int openBracket = start + 5;
  final int closeBracket = s.indexOf(']', openBracket);
  if (closeBracket <= openBracket) {
    return null;
  }
  final String indexStr = s.substring(openBracket + 1, closeBracket);
  if (closeBracket + 1 >= s.length || s[closeBracket + 1] != '{') {
    return null;
  }
  final int openBrace = closeBracket + 1;
  final int? end = _endAfterBalancedBrace(s, openBrace);
  if (end == null) {
    return null;
  }
  final String inner = s.substring(openBrace + 1, end - 1);
  return (index: indexStr, inner: inner, end: end);
}

({String inner, int end})? _parseSqrtAt(String s, int start) {
  if (!s.startsWith(r'\sqrt{', start)) {
    return null;
  }
  final int open = start + 5;
  final int? end = _endAfterBalancedBrace(s, open);
  if (end == null) {
    return null;
  }
  final String inner = s.substring(open + 1, end - 1);
  return (inner: inner, end: end);
}

int _endOfLatexCommandName(String s, int backslashIndex) {
  int j = backslashIndex + 1;
  while (j < s.length) {
    final String ch = s[j];
    final bool az = (ch.compareTo('a') >= 0 && ch.compareTo('z') <= 0) ||
        (ch.compareTo('A') >= 0 && ch.compareTo('Z') <= 0);
    if (!az) {
      break;
    }
    j++;
  }
  return j;
}

bool _isLatexLetterCodeUnit(int c) =>
    (c >= 0x61 && c <= 0x7A) || (c >= 0x41 && c <= 0x5A);

/// `\int` with optional `_` / `^` limits (braced or single char), MathLive-style.
({String? lower, String? upper, int end})? _parseIntWithLimitsAt(
    String s, int start) {
  if (!s.startsWith(r'\int', start)) {
    return null;
  }
  int i = start + 4;
  if (i < s.length && _isLatexLetterCodeUnit(s.codeUnitAt(i))) {
    return null;
  }
  String? lower;
  String? upper;
  if (i < s.length && s[i] == '_') {
    i++;
    if (i < s.length && s[i] == '{') {
      final int? e = _endAfterBalancedBrace(s, i);
      if (e != null) {
        lower = s.substring(i + 1, e - 1);
        i = e;
      }
    } else if (i < s.length) {
      lower = s[i];
      i++;
    }
  }
  if (i < s.length && s[i] == '^') {
    i++;
    if (i < s.length && s[i] == '{') {
      final int? e = _endAfterBalancedBrace(s, i);
      if (e != null) {
        upper = s.substring(i + 1, e - 1);
        i = e;
      }
    } else if (i < s.length) {
      upper = s[i];
      i++;
    }
  }
  return (lower: lower, upper: upper, end: i);
}

Widget _intWithLimitsRow(
    String? lower, String? upper, TextStyle st) {
  final double fs = st.fontSize ?? 14;
  final TextStyle limStyle = st.copyWith(fontSize: fs * 0.68, height: 1.05);
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Text(
        '∫',
        style: st.copyWith(fontSize: fs * 1.2, height: 1, fontWeight: FontWeight.w400),
      ),
      if (lower != null && lower.isNotEmpty || upper != null && upper.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(left: 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (upper != null && upper.isNotEmpty)
                buildSimpleLatexInline(upper, limStyle),
              if (lower != null && lower.isNotEmpty)
                buildSimpleLatexInline(lower, limStyle),
            ],
          ),
        ),
    ],
  );
}

String _unicodeSubs(String plain) {
  String o = plain;
  for (final MapEntry<String, String> e in _latexSymbol.entries) {
    o = o.replaceAll('\\${e.key}', e.value);
  }
  return o;
}

List<Widget> _scan(String s, TextStyle st) {
  final List<Widget> parts = <Widget>[];
  final StringBuffer plain = StringBuffer();

  void flushPlain() {
    if (plain.isEmpty) {
      return;
    }
    final String t = _unicodeSubs(plain.toString());
    plain.clear();
    if (t.isEmpty) {
      return;
    }
    parts.add(Text(t, style: st));
  }

  int i = 0;
  while (i < s.length) {
    if (s.startsWith(r'\,', i)) {
      flushPlain();
      parts.add(SizedBox(width: (st.fontSize ?? 14) * 0.22));
      i += 2;
      continue;
    }
    if (s.startsWith(r'\mathrm{', i)) {
      final int openBrace = i + 7;
      final int? e = _endAfterBalancedBrace(s, openBrace);
      if (e != null) {
        flushPlain();
        final String inner = s.substring(openBrace + 1, e - 1);
        parts.add(
          Text(
            inner,
            style: st.copyWith(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal,
            ),
          ),
        );
        i = e;
        continue;
      }
    }
    final ({String? lower, String? upper, int end})? intLim =
        _parseIntWithLimitsAt(s, i);
    if (intLim != null) {
      flushPlain();
      parts.add(_intWithLimitsRow(intLim.lower, intLim.upper, st));
      i = intLim.end;
      continue;
    }
    final frac = _parseFracAt(s, i);
    if (frac != null) {
      flushPlain();
      parts.add(_fracColumn(frac.num, frac.den, st));
      i = frac.end;
      continue;
    }
    final sqrtN = _parseSqrtNAt(s, i);
    if (sqrtN != null) {
      flushPlain();
      parts.add(_nthSqrtRow(sqrtN.index, sqrtN.inner, st));
      i = sqrtN.end;
      continue;
    }
    final sqrt = _parseSqrtAt(s, i);
    if (sqrt != null) {
      flushPlain();
      parts.add(_sqrtRow(sqrt.inner, st));
      i = sqrt.end;
      continue;
    }
    if (s.codeUnitAt(i) == 0x5C && i + 1 < s.length) {
      final int cmdEnd = _endOfLatexCommandName(s, i);
      final String cmd = s.substring(i + 1, cmdEnd);
      if (cmd.isEmpty) {
        plain.write(r'\');
        i++;
        continue;
      }
      final String? sym = _latexSymbol[cmd];
      if (sym != null) {
        flushPlain();
        parts.add(Text(sym, style: st));
        i = cmdEnd;
        continue;
      }
      flushPlain();
      parts.add(Text(s.substring(i, cmdEnd), style: st));
      i = cmdEnd;
      continue;
    }
    if (s[i] == '^' && i + 1 < s.length) {
      if (s[i + 1] == '{') {
        final String base = plain.toString();
        plain.clear();
        final int? end = _endAfterBalancedBrace(s, i + 1);
        if (end != null) {
          final String sup = s.substring(i + 2, end - 1);
          parts.add(_superscriptRow(base, sup, st));
          i = end;
          continue;
        }
        plain.write(base);
        plain.write('^{');
        i += 2;
        continue;
      } else {
        final String base = plain.toString();
        plain.clear();
        final String sup = s[i + 1];
        parts.add(_superscriptRow(base, sup, st));
        i += 2;
        continue;
      }
    }
    if (s[i] == '_' && i + 1 < s.length && s[i + 1] == '{') {
      final String base = plain.toString();
      plain.clear();
      final int? end = _endAfterBalancedBrace(s, i + 1);
      if (end != null) {
        final String sub = s.substring(i + 2, end - 1);
        parts.add(_subscriptRow(base, sub, st));
        i = end;
        continue;
      }
      plain.write(base);
      plain.write('_{');
      i += 2;
      continue;
    }
    plain.write(s[i]);
    i++;
  }
  flushPlain();
  return parts;
}

Widget _fracColumn(String numTex, String denTex, TextStyle st) {
  final double fs = st.fontSize ?? 14;
  final TextStyle small = st.copyWith(fontSize: fs * 0.92);
  return IntrinsicWidth(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildSimpleLatexInline(numTex, small),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Divider(height: 1, thickness: 1, color: st.color?.withOpacity(0.85)),
        ),
        buildSimpleLatexInline(denTex, small),
      ],
    ),
  );
}

Widget _nthSqrtRow(String indexTex, String innerTex, TextStyle st) {
  final double fs = st.fontSize ?? 14;
  final TextStyle rootStyle = st.copyWith(
    fontSize: fs * 1.18,
    fontWeight: FontWeight.w600,
    height: 1,
  );
  final TextStyle idxStyle = st.copyWith(fontSize: fs * 0.62, height: 1);
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: <Widget>[
      Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomLeft,
        children: <Widget>[
          Text('√', style: rootStyle),
          Positioned(
            right: -1,
            top: -6,
            child: buildSimpleLatexInline(indexTex, idxStyle),
          ),
        ],
      ),
      const SizedBox(width: 4),
      buildSimpleLatexInline(innerTex, st),
    ],
  );
}

/// Simple preview: √ + radicand only (no vinculum); stable inside [WidgetSpan].
Widget _sqrtRow(String innerTex, TextStyle st) {
  final double fs = st.fontSize ?? 14;
  final TextStyle rootStyle = st.copyWith(
    fontSize: fs * 1.2,
    fontWeight: FontWeight.w600,
    height: 1,
  );
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 2, bottom: 1),
        child: Text('√', style: rootStyle),
      ),
      buildSimpleLatexInline(innerTex, st),
    ],
  );
}

Widget _superscriptRow(String base, String sup, TextStyle st) {
  final double fs = st.fontSize ?? 14;
  final TextStyle supStyle = st.copyWith(fontSize: fs * 0.72, height: 1.1);
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      if (base.isNotEmpty) Text(base, style: st),
      Transform.translate(
        offset: const Offset(0, -3),
        child: buildSimpleLatexInline(sup, supStyle),
      ),
    ],
  );
}

Widget _subscriptRow(String base, String sub, TextStyle st) {
  final double fs = st.fontSize ?? 14;
  final TextStyle subStyle = st.copyWith(fontSize: fs * 0.72, height: 1.1);
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: <Widget>[
      if (base.isNotEmpty) Text(base, style: st),
      Transform.translate(
        offset: const Offset(0, 3),
        child: buildSimpleLatexInline(sub, subStyle),
      ),
    ],
  );
}
