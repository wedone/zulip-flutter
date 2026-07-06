import 'package:flutter/material.dart';

/// IO/Android/iOS — web uses [mathlive_editor_web.dart] via conditional import.
Widget mathLiveMixedWebEditorBody({
  required bool isDark,
  required void Function(String latex) onLatex,
  required void Function(void Function() triggerExportFromHost) onExporterReady,
  required void Function(bool success) onWebEditorReady,
  required Color backgroundColor,
  String? initialLatex,
  void Function(double chromeHeight)? onEditorChromeHeight,
  TextStyle? loadingTextStyle,
  Color? accentColor,
}) {
  return const SizedBox.shrink();
}
