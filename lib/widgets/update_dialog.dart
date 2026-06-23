import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n/zulip_localizations.dart';
import '../model/app_update.dart';

/// 应用内升级提示对话框
///
/// 当检测到新版本时显示，提供"稍后提醒"和"立即更新"两个选项。
class UpdateAvailableDialog extends StatelessWidget {
  const UpdateAvailableDialog({super.key, required this.updateInfo});

  /// 更新信息
  final AppUpdateInfo updateInfo;

  /// 显示升级提示对话框
  static void show(BuildContext context, {required AppUpdateInfo updateInfo}) {
    showDialog(
      context: context,
      builder: (context) => UpdateAvailableDialog(updateInfo: updateInfo),
    );
  }

  /// 打开下载链接
  Future<void> _launchUpdateUrl() async {
    final url = updateInfo.downloadUrl.isNotEmpty
        ? updateInfo.downloadUrl
        : updateInfo.htmlUrl;
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    return AlertDialog.adaptive(
      title: Text(zulipLocalizations.updateAvailableTitle),
      content: _adaptiveContent(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(zulipLocalizations.updateAvailableNewVersion(updateInfo.version)),
            if (updateInfo.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(zulipLocalizations.updateAvailableReleaseNotes),
              const SizedBox(height: 4),
              Text(updateInfo.releaseNotes),
            ],
          ],
        ),
      ),
      actions: [
        _adaptiveAction(
          onPressed: () => Navigator.pop(context),
          isDefaultAction: false,
          text: zulipLocalizations.remindLater,
        ),
        _adaptiveAction(
          onPressed: () {
            _launchUpdateUrl();
            Navigator.pop(context);
          },
          isDefaultAction: true,
          text: zulipLocalizations.updateNow,
        ),
      ],
    );
  }
}

/// 平台适配的操作按钮
///
/// 在 Android/Linux/Windows 上使用 Material TextButton，
/// 在 iOS/macOS 上使用 CupertinoDialogAction。
Widget _adaptiveAction({
  required VoidCallback onPressed,
  required bool isDefaultAction,
  bool isDestructiveAction = false,
  required String text,
}) {
  // 忽略 isDefaultAction 和 isDestructiveAction，
  // 因为 Material Design 没有对应的样式规范。
  return TextButton(
    onPressed: onPressed,
    child: Text(text, textAlign: TextAlign.end),
  );
}

/// 平台适配的对话框内容
///
/// 在 Android/Linux/Windows 上用 SingleChildScrollView 包裹以支持长文本滚动，
/// 在 iOS/macOS 上 CupertinoAlertDialog 已内置滚动支持。
Widget? _adaptiveContent(Widget? content) {
  if (content == null) return null;
  return SingleChildScrollView(child: content);
}

/// 显示"已是最新版本"的 SnackBar
void showUpToDateSnackBar(BuildContext context) {
  final zulipLocalizations = ZulipLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(zulipLocalizations.upToDate)),
  );
}
