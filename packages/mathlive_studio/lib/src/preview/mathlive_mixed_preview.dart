import 'package:flutter/material.dart';

import 'mathlive_mixed_preview_io.dart'
    if (dart.library.html) 'mathlive_mixed_preview_web.dart';

/// Read-only mixed plain text + inline LaTeX `\(...\)` rendered with MathLive.
class MathLiveMixedPreview extends StatelessWidget {
  const MathLiveMixedPreview({
    super.key,
    required this.previewText,
    required this.isDark,
    required this.backgroundColor,
    required this.baseStyle,
    this.maxViewportHeight,
    this.expandToContent = false,
    this.displayOnly = false,
    this.clipOverflow = false,
    this.preventShrinkingReportedHeight = false,
  });

  final String previewText;
  final bool isDark;
  final Color backgroundColor;
  final TextStyle baseStyle;
  final double? maxViewportHeight;
  final bool expandToContent;
  final bool displayOnly;
  final bool clipOverflow;
  final bool preventShrinkingReportedHeight;

  @override
  Widget build(BuildContext context) {
    final double fontSize = baseStyle.fontSize ?? 14;
    final double defaultMax = MediaQuery.sizeOf(context).height * 0.45;
    final double resolvedMax = expandToContent
        ? (maxViewportHeight ?? 8000.0)
        : (maxViewportHeight ?? defaultMax);
    final FontWeight w = baseStyle.fontWeight ?? FontWeight.w400;
    return MathLiveMixedPreviewBody(
      previewText: previewText,
      isDark: isDark,
      backgroundColor: backgroundColor,
      textColor: baseStyle.color ?? (isDark ? Colors.white : Colors.black87),
      fontSizePx: fontSize,
      fontFamily: baseStyle.fontFamily,
      lineHeight: baseStyle.height ?? 1.45,
      fontWeight: w.value,
      letterSpacing: baseStyle.letterSpacing ?? 0,
      maxViewportHeight: resolvedMax,
      expandToContent: expandToContent,
      disableTextInteraction: displayOnly,
      clipOverflow: clipOverflow,
      preventShrinkingReportedHeight: preventShrinkingReportedHeight,
    );
  }
}
