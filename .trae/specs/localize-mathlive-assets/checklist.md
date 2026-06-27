# Checklist

## 资源准备

- [ ] zulip-flutter/pubspec.yaml 包含 `flutter_mathlive_mixed` 的 path 依赖（`path: ../mathlive_editor_package/flutter_mathlive_mixed`）
- [ ] `flutter_mathlive_mixed/assets/mathlive/mathlive.min.js` 存在且为 0.110.0 版本
- [ ] `flutter_mathlive_mixed/assets/mathlive/mathlive-static.css` 存在且为 0.110.0 版本
- [ ] `flutter_mathlive_mixed/assets/mathlive/fonts/` 目录存在且包含 21 个 woff2 字体文件
- [ ] `flutter_mathlive_mixed/pubspec.yaml` 的 `flutter.assets` 显式声明 `assets/mathlive/fonts/`

## HTML 改造

- [ ] `mathlive_editor.html` 中无 jsdelivr CDN URL
- [ ] `mathlive_editor.html` 使用相对路径 `mathlive-static.css` 与 `mathlive.min.js`

## Dart 代码改造（移动端）

- [ ] `mathlive_editor_page.dart` 中无 `baseUrl: 'https://cdn.jsdelivr.net'`
- [ ] `mathlive_editor_page.dart` 中无 `rootBundle` 引用
- [ ] `mathlive_editor_page.dart` 的 `_bootstrapWebView` 调用 `loadFlutterAsset(kMathLiveEditorHtmlAsset)`
- [ ] `mathlive_embedded_editor.dart` 中无 `baseUrl: 'https://cdn.jsdelivr.net'`
- [ ] `mathlive_embedded_editor.dart` 中无 `rootBundle` 引用
- [ ] `mathlive_embedded_editor.dart` 的 `_bootstrap` 调用 `loadFlutterAsset(kMathLiveEditorHtmlAsset)`
- [ ] `mathlive_embedded_editor.dart` 的 import 为 `show Clipboard, ClipboardData;`

## Dart 代码改造（web 端）

- [ ] `mathlive_editor_web.dart` 中无 `0.101.2` 版本号
- [ ] `mathlive_editor_web.dart` 中 CDN URL 无 `/dist/` 段
- [ ] `mathlive_editor_web.dart` 的 CDN URL 指向 `mathlive@0.110.0/`

## 验证

- [ ] `flutter pub get` 成功（退出码 0）
- [ ] `flutter analyze` 无 error 级别问题
