import 'package:flutter/material.dart';

import '../utils/math_normalize.dart';
import 'simple_latex_inline.dart';

/// Renders plain text with inline LaTeX segments wrapped as `\(...\)`, matching
/// mentor equation insertions. Uses [buildSimpleLatexInline] only (no
/// flutter_math_fork — it breaks on some Flutter SDKs due to internal rendering API changes).
///
/// Plain segments may include Parchment-style markdown from [Fleather]: `**bold**`,
/// `_italic_`, and simple list lines (`* item`, `- item`, `1. item`).
class InlineTexMixedText extends StatelessWidget {
  const InlineTexMixedText({
    super.key,
    required this.source,
    required this.style,
  });

  final String source;
  final TextStyle style;

  static final RegExp _inlineMath = RegExp(r'\\\(([\s\S]*?)\\\)');

  static final RegExp _mdBoldItalic = RegExp(r'\*\*(.+?)\*\*|_(.+?)_');

  /// Markdown-ish inline + line prefixes inside a non-math segment.
  static List<InlineSpan> markdownPlainSegmentToSpans(String plain, TextStyle base) {
    final List<InlineSpan> out = <InlineSpan>[];
    final List<String> lines = plain.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (i > 0) {
        out.add(TextSpan(text: '\n', style: base));
      }
      String line = lines[i];
      final RegExpMatch? ulStar = RegExp(r'^\s*\*\s+(.*)$').firstMatch(line);
      final RegExpMatch? ulDash = RegExp(r'^\s*-\s+(.*)$').firstMatch(line);
      final RegExpMatch? ol = RegExp(r'^\s*\d+[.)]\s+(.*)$').firstMatch(line);
      if (ulStar != null) {
        line = '• ${ulStar.group(1)!}';
      } else if (ulDash != null) {
        line = '• ${ulDash.group(1)!}';
      } else if (ol != null) {
        line = ol.group(1)!;
      }
      out.addAll(_inlineMarkdownSpansForLine(line, base));
    }
    return out;
  }

  static List<InlineSpan> _inlineMarkdownSpansForLine(String line, TextStyle base) {
    final List<InlineSpan> spans = <InlineSpan>[];
    int t = 0;
    for (final RegExpMatch m in _mdBoldItalic.allMatches(line)) {
      if (m.start > t) {
        spans.add(TextSpan(text: line.substring(t, m.start), style: base));
      }
      final String? bold = m.group(1);
      final String? italic = m.group(2);
      if (bold != null) {
        spans.add(
          TextSpan(
            text: bold,
            style: base.merge(const TextStyle(fontWeight: FontWeight.w700)),
          ),
        );
      } else if (italic != null) {
        spans.add(
          TextSpan(
            text: italic,
            style: base.merge(const TextStyle(fontStyle: FontStyle.italic)),
          ),
        );
      }
      t = m.end;
    }
    if (t < line.length) {
      spans.add(TextSpan(text: line.substring(t), style: base));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final String src = normalizeInlineMath(source.trim());
    if (src.isEmpty) {
      return const SizedBox.shrink();
    }
    if (!_inlineMath.hasMatch(src)) {
      return Text.rich(
        TextSpan(style: style, children: markdownPlainSegmentToSpans(src, style)),
        strutStyle: StrutStyle(
          fontFamily: style.fontFamily,
          fontSize: style.fontSize,
          height: style.height,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );
    }
    final List<InlineSpan> spans = <InlineSpan>[];
    int start = 0;
    for (final Match m in _inlineMath.allMatches(src)) {
      if (m.start > start) {
        final String plain = src.substring(start, m.start);
        if (plain.isNotEmpty) {
          spans.addAll(markdownPlainSegmentToSpans(plain, style));
        }
      }
      final String tex = m.group(1)!.trim();
      final String forRender = normalizeLatexForFlutterMath(tex);
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: forRender.isEmpty
              ? const SizedBox.shrink()
              : buildSimpleLatexInline(forRender, style),
        ),
      );
      start = m.end;
    }
    if (start < src.length) {
      final String tail = src.substring(start);
      if (tail.isNotEmpty) {
        spans.addAll(markdownPlainSegmentToSpans(tail, style));
      }
    }
    return Text.rich(
      TextSpan(style: style, children: spans),
      strutStyle: StrutStyle(
        fontFamily: style.fontFamily,
        fontSize: style.fontSize,
        height: style.height,
        leadingDistribution: TextLeadingDistribution.even,
      ),
    );
  }
}
