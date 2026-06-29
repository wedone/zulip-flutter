import 'package:flutter/material.dart';

import '../compose_box.dart';

/// 可视公式编辑器服务。
///
/// 封装将 LaTeX 插入 [ComposeContentController] 的逻辑。
/// [openEditor] 在 Task 5 中将替换为 [MathFormulaPanel] 调用。
class MathEditorService {
  MathEditorService._();

  /// 打开 MathLive WYSIWYG 编辑器；用户确认后返回 LaTeX 字符串（不含界定符）。
  ///
  /// 用户点击返回按钮（不确认）时返回 null。
  /// [initialLatex] 可选，用于编辑已有公式（Task 5 使用）。
  // TODO: Task 5 中替换为 MathFormulaPanel 调用
  static Future<String?> openEditor(
    BuildContext context, {
    required bool isDark,
    String? initialLatex,
  }) async {
    throw UnimplementedError('MathLiveEditorPage 已移除，待 Task 5 重构');
  }

  /// 将 [latex] 用 `\(` `\)` 界定符包裹后插入到 [controller] 的当前光标位置，
  /// 并把光标移到插入内容之后。
  ///
  /// 若 [latex] 为空字符串则不做任何操作。
  /// 若 [controller] 当前有选区，则光标定位到选区末尾后再插入
  /// （沿用 [ComposeContentController.insertionIndex] 的语义，
  /// 与 [ComposeContentController.insertPadded] 行为一致）。
  static void insertLatexAtCursor(ComposeContentController controller, String latex) {
    final String trimmed = latex.trim();
    if (trimmed.isEmpty) return;

    final String wrapped = '\\($trimmed\\)';
    final TextRange i = controller.insertionIndex();
    final TextEditingValue newValue = controller.value.replaced(i, wrapped);
    controller.value = newValue.copyWith(
      selection: TextSelection.collapsed(offset: i.start + wrapped.length),
    );
  }

  /// 检测 [controller] 当前光标位置是否落在 `\(...\)` 包裹的公式区域内。
  ///
  /// 光标必须处于 collapsed 状态（无选区），且 offset 严格大于公式区域 start、
  /// 严格小于 end（即光标落在 `\(` 之后、`\)` 之前的任意位置，包括 LaTeX
  /// 内容内部）。
  ///
  /// 返回值 [DetectedFormula] 包含公式在文本中的完整范围（含界定符）和
  /// LaTeX 内容（不含界定符）；若光标不在任何公式内则返回 null。
  ///
  /// 嵌套界定符场景（如 `\(\text{设 } x = 1\)`）按非贪婪匹配处理，
  /// 即匹配到第一个 `\)` 闭合，与 [convertLatexDelimitersToZulip] 的规则一致。
  static DetectedFormula? detectLatexAtCursor(ComposeContentController controller) {
    final TextRange selection = controller.selection;
    if (!selection.isValid || !selection.isCollapsed) return null;
    final int cursorOffset = selection.start;
    final String text = controller.text;

    final pattern = RegExp(r'\\\(([\s\S]*?)\\\)');
    for (final match in pattern.allMatches(text)) {
      final int start = match.start;
      final int end = match.end;
      if (cursorOffset > start && cursorOffset < end) {
        return DetectedFormula(
          range: TextRange(start: start, end: end),
          latex: match[1]!,
        );
      }
    }
    return null;
  }

  /// 用 [latex] 替换 [controller] 中 [range] 范围内的公式内容，
  /// 重新用 `\(` `\)` 包裹，并把光标移到替换内容之后。
  ///
  /// 用于编辑已有公式场景：先通过 [detectLatexAtCursor] 取得 [range]，
  /// 用户编辑确认后调用本方法替换原公式。
  /// 若 [latex] 为空字符串则不做任何操作（保留原公式不变）。
  static void replaceLatexRange(
    ComposeContentController controller,
    TextRange range,
    String latex,
  ) {
    final String trimmed = latex.trim();
    if (trimmed.isEmpty) return;

    final String wrapped = '\\($trimmed\\)';
    final TextEditingValue newValue = controller.value.replaced(range, wrapped);
    controller.value = newValue.copyWith(
      selection: TextSelection.collapsed(offset: range.start + wrapped.length),
    );
  }
}

/// [MathEditorService.detectLatexAtCursor] 的返回值。
class DetectedFormula {
  const DetectedFormula({required this.range, required this.latex});

  /// 公式在 TextField 文本中的完整范围（含 `\(` 和 `\)` 界定符）。
  final TextRange range;

  /// 公式的 LaTeX 内容（不含界定符）。
  final String latex;
}
