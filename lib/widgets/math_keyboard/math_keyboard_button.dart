import 'package:flutter/material.dart';

import '../../generated/l10n/zulip_localizations.dart';
import '../color.dart';
import '../theme.dart';

/// A button to toggle the math keyboard toolbar open/closed.
///
/// Follows the same style as the existing compose box icon buttons.
class MathKeyboardButton extends StatelessWidget {
  const MathKeyboardButton({
    super.key,
    required this.isActive,
    required this.onPressed,
    required this.enabled,
  });

  /// Whether the math symbols toolbar is currently visible.
  final bool isActive;

  /// Called when the button is pressed.
  final VoidCallback onPressed;

  /// Whether the button is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final zulipLocalizations = ZulipLocalizations.of(context);

    return SizedBox(
      width: 44,
      child: IconButton(
        icon: Icon(
          Icons.keyboard,
          color: isActive
            ? designVariables.icon
            : designVariables.foreground.withFadedAlpha(0.5),
        ),
        tooltip: zulipLocalizations.mathKeyboardButtonTooltip,
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}
