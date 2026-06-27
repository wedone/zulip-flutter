import 'package:flutter/material.dart';

import '../../generated/l10n/zulip_localizations.dart';
import '../color.dart';
import '../theme.dart';

/// 可视公式编辑按钮，点击后打开 MathLive WYSIWYG 编辑器弹窗。
///
/// 样式与 compose_box 中其他图标按钮一致。
class VisualMathButton extends StatelessWidget {
  const VisualMathButton({
    super.key,
    required this.onPressed,
    required this.enabled,
  });

  /// 按钮点击回调。
  final VoidCallback onPressed;

  /// 按钮是否可用。
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final zulipLocalizations = ZulipLocalizations.of(context);

    return SizedBox(
      width: 44,
      child: IconButton(
        icon: Icon(
          Icons.functions,
          color: designVariables.foreground.withFadedAlpha(0.5),
        ),
        tooltip: zulipLocalizations.visualMathButtonTooltip,
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}
