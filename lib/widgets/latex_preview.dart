import 'dart:async';

import 'package:flutter/material.dart';

import '../model/latex_preview.dart';
import 'color.dart';
import 'math_widget.dart';
import 'theme.dart';

/// A widget that shows a live LaTeX preview when the cursor is inside
/// a pair of math delimiters.
///
/// The preview appears between the content input and the compose buttons.
/// It automatically hides when the input loses focus or the cursor moves
/// outside a formula.
class LatexPreviewArea extends StatefulWidget {
  const LatexPreviewArea({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<LatexPreviewArea> createState() => _LatexPreviewAreaState();
}

class _LatexPreviewAreaState extends State<LatexPreviewArea> {
  String? _previewContent;
  bool _displayMode = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onContentChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant LatexPreviewArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onContentChanged);
      widget.controller.addListener(_onContentChanged);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChanged);
      widget.focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onContentChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onContentChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), _updatePreview);
  }

  void _onFocusChanged() {
    if (!widget.focusNode.hasFocus) {
      _debounceTimer?.cancel();
      if (_previewContent != null) {
        setState(() {
          _previewContent = null;
        });
      }
    } else {
      _updatePreview();
    }
  }

  void _updatePreview() {
    if (!mounted) return;
    if (!widget.focusNode.hasFocus) {
      if (_previewContent != null) {
        setState(() { _previewContent = null; });
      }
      return;
    }

    final selection = widget.controller.selection;
    if (!selection.isValid || !selection.isCollapsed) {
      // No cursor or text is selected; don't preview.
      if (_previewContent != null) {
        setState(() { _previewContent = null; });
      }
      return;
    }

    final result = findLatexAtCursor(
      widget.controller.text,
      selection.baseOffset,
    );

    final newContent = result?.content;
    final newDisplayMode = result?.displayMode ?? false;

    if (newContent != _previewContent || newDisplayMode != _displayMode) {
      setState(() {
        _previewContent = newContent;
        _displayMode = newDisplayMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_previewContent == null) return const SizedBox.shrink();

    final designVariables = DesignVariables.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: designVariables.composeBoxBg,
        border: Border(
          top: BorderSide(
            width: 1,
            color: designVariables.foreground.withFadedAlpha(0.1),
          ),
        ),
      ),
      constraints: const BoxConstraints(maxHeight: 120),
      child: SingleChildScrollView(
        child: Align(
          alignment: _displayMode ? Alignment.center : Alignment.centerLeft,
          child: MathWidget(
            texSource: _previewContent!,
            displayMode: _displayMode,
          ),
        ),
      ),
    );
  }
}
