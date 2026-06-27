import 'package:flutter/material.dart';
import 'package:flutter_mathlive_mixed/mathlive_studio.dart';

import '../compose_box.dart';

/// 可视公式编辑器服务。
///
/// 封装 [MathLiveEditorPage.open()] 调用和将 LaTeX 插入
/// [ComposeContentController] 的逻辑。
class MathEditorService {
  MathEditorService._();

  /// 打开 MathLive WYSIWYG 编辑器；用户确认后返回 LaTeX 字符串（不含界定符）。
  ///
  /// 用户点击返回按钮（不确认）时返回 null。
  /// [initialLatex] 可选，用于编辑已有公式（Task 5 使用）。
  static Future<String?> openEditor(
    BuildContext context, {
    required bool isDark,
    String? initialLatex,
  }) async {
    return MathLiveEditorPage.open(
      context,
      isDark: isDark,
      initialLatex: initialLatex,
    );
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
}
