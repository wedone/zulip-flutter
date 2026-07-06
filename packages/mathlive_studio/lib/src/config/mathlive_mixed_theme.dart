import 'package:flutter/material.dart';

/// Optional bundled colors for editor chrome (hosts can override via parameters).
class MathLiveMixedTheme {
  const MathLiveMixedTheme({
    this.editorBackgroundLight = Colors.white,
    this.editorBackgroundDark = const Color(0xFF141922),
    this.editorForegroundLight = const Color(0xFF0F172A),
    this.editorForegroundDark = const Color(0xFFE2E8F0),
    this.accent = const Color(0xFF2563EB),
  });

  final Color editorBackgroundLight;
  final Color editorBackgroundDark;
  final Color editorForegroundLight;
  final Color editorForegroundDark;
  final Color accent;

  Color editorBackground(bool isDark) =>
      isDark ? editorBackgroundDark : editorBackgroundLight;

  Color editorForeground(bool isDark) =>
      isDark ? editorForegroundDark : editorForegroundLight;

  static const MathLiveMixedTheme defaults = MathLiveMixedTheme();
}
