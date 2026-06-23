import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'binding.dart';

/// GitHub 仓库所有者
const _githubOwner = 'wedone';

/// GitHub 仓库名称
const _githubRepo = 'zulip-flutter';

/// 上次更新检查时间的 SharedPreferences key
const _lastCheckTimeKey = 'last_update_check_time';

/// 自动检查更新的间隔（24小时）
const _autoCheckInterval = Duration(hours: 24);

/// GitHub Releases API 地址
Uri get _releasesApiUrl =>
    Uri.parse('https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest');

/// 应用更新信息
class AppUpdateInfo {
  /// 新版本号，如 "30.0.272-math-v2.0"
  final String version;

  /// APK 下载链接
  final String downloadUrl;

  /// 更新说明
  final String releaseNotes;

  /// GitHub Release 页面链接
  final String htmlUrl;

  const AppUpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.htmlUrl,
  });
}

/// GitHub Release API 返回的数据
class GitHubReleaseInfo {
  /// tag 名称，如 "v30.0.272-math-v2.0"
  final String tagName;

  /// Release body（更新说明）
  final String body;

  /// GitHub Release 页面链接
  final String htmlUrl;

  /// 附件列表
  final List<GitHubReleaseAsset> assets;

  const GitHubReleaseInfo({
    required this.tagName,
    required this.body,
    required this.htmlUrl,
    required this.assets,
  });

  /// 从 JSON 解析 GitHubReleaseInfo
  factory GitHubReleaseInfo.fromJson(Map<String, dynamic> json) {
    final assetsJson = json['assets'] as List<dynamic>? ?? [];
    return GitHubReleaseInfo(
      tagName: json['tag_name'] as String? ?? '',
      body: json['body'] as String? ?? '',
      htmlUrl: json['html_url'] as String? ?? '',
      assets: assetsJson
          .map((a) => GitHubReleaseAsset.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// GitHub Release 附件信息
class GitHubReleaseAsset {
  /// 文件名
  final String name;

  /// 下载链接
  final String browserDownloadUrl;

  const GitHubReleaseAsset({
    required this.name,
    required this.browserDownloadUrl,
  });

  factory GitHubReleaseAsset.fromJson(Map<String, dynamic> json) {
    return GitHubReleaseAsset(
      name: json['name'] as String? ?? '',
      browserDownloadUrl: json['browser_download_url'] as String? ?? '',
    );
  }
}

/// 检查应用更新
///
/// 请求 GitHub Releases API 获取最新版本信息，
/// 与当前应用版本对比，如果有新版本则返回 [AppUpdateInfo]，否则返回 null。
/// 网络请求失败时静默返回 null。
Future<AppUpdateInfo?> checkForUpdate() async {
  try {
    final response = await http.get(_releasesApiUrl, headers: {
      'Accept': 'application/vnd.github+json',
    });

    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final release = GitHubReleaseInfo.fromJson(json);

    // 从 tag 名称中提取版本号（去掉前缀 "v"）
    final remoteVersion = release.tagName.replaceFirst(RegExp(r'^v'), '');
    if (remoteVersion.isEmpty) return null;

    // 从 assets 中查找 APK 文件
    final apkAsset = release.assets
        .where((asset) => asset.name.endsWith('.apk'))
        .firstOrNull;
    if (apkAsset == null) return null;

    // 获取当前版本号
    final packageInfo = ZulipBinding.instance.syncPackageInfo;
    if (packageInfo == null) return null;

    // 去掉构建号后比较版本（如 "30.0.272-math-v1.4+1" → "30.0.272-math-v1.4"）
    final currentVersion = packageInfo.version;

    // 比较版本号，远程版本更新时返回更新信息
    if (compareMathVersions(remoteVersion, currentVersion) > 0) {
      return AppUpdateInfo(
        version: remoteVersion,
        downloadUrl: apkAsset.browserDownloadUrl,
        releaseNotes: release.body,
        htmlUrl: release.htmlUrl,
      );
    }

    return null;
  } catch (_) {
    // 网络请求或解析失败时静默返回 null
    return null;
  }
}

/// 比较两个 math 版本号
///
/// 解析 `30.0.272-math-vX.Y` 格式，提取 math 版本部分（X.Y）进行比较：
/// - 先比较 X（大版本），X 大则版本更新
/// - X 相同时比较 Y（小版本）
/// - 如果版本号不包含 `-math-v` 前缀，则按普通语义化版本比较
///
/// 返回值：>0 表示 [version1] 更新，<0 表示 [version2] 更新，0 表示相等
int compareMathVersions(String version1, String version2) {
  final math1 = _extractMathVersion(version1);
  final math2 = _extractMathVersion(version2);

  // 两个版本都包含 math 前缀时，比较 math 版本号
  if (math1 != null && math2 != null) {
    return _compareVersionParts(math1, math2);
  }

  // 两个版本都不包含 math 前缀时，按普通语义化版本比较
  if (math1 == null && math2 == null) {
    return _compareVersionParts(version1, version2);
  }

  // 一个包含 math 前缀一个不包含，视为不兼容，无法比较
  // 包含 math 的视为更新（因为 math 版本是上游的扩展）
  if (math1 != null) return 1;
  return -1;
}

/// 从版本号字符串中提取 math 版本部分
///
/// 例如 "30.0.272-math-v1.4+1" 提取出 "1.4"
/// 如果不包含 "-math-v" 前缀则返回 null
String? _extractMathVersion(String version) {
  // 先去掉构建号（+Z 部分）
  final withoutBuild = version.split('+').first;

  final match = RegExp(r'-math-v(.+)$').firstMatch(withoutBuild);
  if (match == null) return null;
  return match.group(1);
}

/// 比较两个由点号分隔的版本号字符串
///
/// 例如 "1.4" 和 "2.0" → 返回 -1（后者更新）
/// "2.1" 和 "2.0" → 返回 1（前者更新）
int _compareVersionParts(String v1, String v2) {
  final parts1 = v1.split('.');
  final parts2 = v2.split('.');

  final maxLen = parts1.length > parts2.length ? parts1.length : parts2.length;
  for (var i = 0; i < maxLen; i++) {
    final p1 = i < parts1.length ? int.tryParse(parts1[i]) ?? 0 : 0;
    final p2 = i < parts2.length ? int.tryParse(parts2[i]) ?? 0 : 0;
    if (p1 != p2) return p1.compareTo(p2);
  }
  return 0;
}

/// 判断是否应该自动检查更新
///
/// 使用 SharedPreferences 记录上次检查时间，
/// 24小时内只自动检查一次。
Future<bool> shouldAutoCheckForUpdate() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckMillis = prefs.getInt(_lastCheckTimeKey);
    if (lastCheckMillis == null) return true;

    final lastCheck = DateTime.fromMillisecondsSinceEpoch(lastCheckMillis);
    final now = DateTime.now();
    return now.difference(lastCheck) >= _autoCheckInterval;
  } catch (_) {
    // 读取失败时允许检查
    return true;
  }
}

/// 记录更新检查时间
///
/// 在成功执行更新检查后调用，记录当前时间到 SharedPreferences。
Future<void> recordUpdateCheckTime() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastCheckTimeKey, DateTime.now().millisecondsSinceEpoch);
  } catch (_) {
    // 写入失败时静默忽略
  }
}
