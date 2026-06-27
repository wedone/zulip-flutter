# MathLive 本地化资源接入 Spec

## Why（动机）

`flutter_mathlive_mixed` 包当前在移动端 WebView 中通过 `loadHtmlString` + jsdelivr CDN（`mathlive@0.101.2/dist/`）作为 `baseUrl` 来加载 MathLive 的 JS/CSS/字体。这导致：

1. 编辑器必须联网才能启动，弱网或离线场景下无法使用；
2. 首次加载需要从海外 CDN 拉取资源，延迟高且不稳定（用户在中国）；
3. 旧版 0.101.2 已过时，且 0.110.0 的 dist 目录结构发生变化（文件从 `/dist/` 移到包根目录），CDN baseUrl 方案需随之调整。

将 MathLive 资源（JS/CSS/字体）打包进 Flutter assets 并通过 `loadFlutterAsset` 本地加载，可消除对 CDN 的依赖，提升启动速度与可用性。

## What Changes（变更内容）

- 在 zulip-flutter 的 `pubspec.yaml` 中添加 `flutter_mathlive_mixed` 的 path 依赖（`path: ../mathlive_editor_package/flutter_mathlive_mixed`）。
- 下载 MathLive 0.110.0 的 `mathlive.min.js` 与 `mathlive-static.css` 到 `flutter_mathlive_mixed/assets/mathlive/`，覆盖旧版 0.101.2。
- 下载 MathLive 0.110.0 的 21 个 woff2 字体文件与（可选）`mathlive-fonts.css` 到 `flutter_mathlive_mixed/assets/mathlive/fonts/`，启用本地字体加载。
- 修改 `flutter_mathlive_mixed/pubspec.yaml` 的 `flutter.assets`，显式声明 `assets/mathlive/fonts/`（Flutter 资源声明不递归子目录）。
- 修改 `assets/mathlive/mathlive_editor.html`，将 CDN 引用改为本地相对路径 `mathlive-static.css` / `mathlive.min.js`。
- 修改 `lib/src/editor/mathlive_editor_page.dart` 的 `_bootstrapWebView`：将 `loadHtmlString(html, baseUrl: CDN)` 改为 `loadFlutterAsset(kMathLiveEditorHtmlAsset)`，并移除不再使用的 `rootBundle` import。
- 修改 `lib/src/editor/mathlive_embedded_editor.dart` 的 `_bootstrap`：同样改为 `loadFlutterAsset`，并将 import 收窄为 `show Clipboard, ClipboardData;`。
- 修改 `lib/src/editor/mathlive_editor_web.dart` 的 `_ensureMathLiveCdnLoaded`：CDN URL 版本号从 `0.101.2/dist/` 升级为 `0.110.0/`（web 端仍走 CDN，但需同步版本）。
- 运行 `flutter pub get` 验证依赖解析成功。
- 运行 `flutter analyze` 检查无编译错误。

## Impact（影响范围）

- 受影响包：`flutter_mathlive_mixed`（位于 `/mnt/d/vc/mathlive_editor_package/flutter_mathlive_mixed`）。
- 受影响文件：
  - `zulip-flutter/pubspec.yaml`（添加 path 依赖）
  - `flutter_mathlive_mixed/pubspec.yaml`（assets 声明）
  - `flutter_mathlive_mixed/assets/mathlive/mathlive.min.js`（0.110.0）
  - `flutter_mathlive_mixed/assets/mathlive/mathlive-static.css`（0.110.0）
  - `flutter_mathlive_mixed/assets/mathlive/fonts/*.woff2`（新增 21 个字体）
  - `flutter_mathlive_mixed/assets/mathlive/mathlive_editor.html`（CDN → 本地相对路径）
  - `flutter_mathlive_mixed/lib/src/editor/mathlive_editor_page.dart`（baseUrl → loadFlutterAsset）
  - `flutter_mathlive_mixed/lib/src/editor/mathlive_embedded_editor.dart`（baseUrl → loadFlutterAsset）
  - `flutter_mathlive_mixed/lib/src/editor/mathlive_editor_web.dart`（CDN 版本号升级）
- 受影响能力：移动端（Android/iOS）MathLive 编辑器启动流程；web 端仅同步版本号，加载策略不变。
- **BREAKING**：无（对外 API 不变，仅内部资源加载方式改变）。

## ADDED Requirements（新增需求）

### Requirement: MathLive 本地资源打包

系统 SHALL 将 MathLive 0.110.0 的 JS、CSS 与 woff2 字体文件打包进 `flutter_mathlive_mixed` 包的 assets 目录，使移动端 WebView 可在不访问网络的情况下加载编辑器。

#### Scenario: 移动端离线启动编辑器
- **WHEN** 用户在无网络环境下打开 MathLive 编辑器（`MathLiveEditorPage` 或 `MathLiveEmbeddedEditor`）
- **THEN** 编辑器成功加载并可用，不出现网络资源错误

#### Scenario: 字体本地解析
- **WHEN** MathLive JS 初始化并请求 `./fonts/*.woff2`
- **THEN** 字体从 Flutter assets 中本地加载，字形正确显示

### Requirement: loadFlutterAsset 加载 HTML

系统 SHALL 在移动端通过 `WebViewController.loadFlutterAsset` 加载 `mathlive_editor.html`，使 HTML 中的相对路径（`mathlive-static.css`、`mathlive.min.js`、`fonts/`）解析到 Flutter assets 而非 CDN。

#### Scenario: 替换 baseUrl 方案
- **WHEN** `_bootstrapWebView` / `_bootstrap` 执行
- **THEN** 调用 `loadFlutterAsset(kMathLiveEditorHtmlAsset)`，不再传 `baseUrl` 指向 jsdelivr CDN

## MODIFIED Requirements（修改需求）

### Requirement: web 端 CDN 版本同步

`mathlive_editor_web.dart` 的 `_ensureMathLiveCdnLoaded` 中注入的 CSS/JS CDN URL SHALL 指向 MathLive 0.110.0 包根目录（`https://cdn.jsdelivr.net/npm/mathlive@0.110.0/mathlive-static.css` 与 `mathlive.min.js`），不再使用 `0.101.2/dist/` 路径。

#### Scenario: web 端加载新版 MathLive
- **WHEN** web 端首次初始化 MathLive CDN
- **THEN** 注入的 `<link>` 与 `<script>` URL 指向 `mathlive@0.110.0/`（无 `/dist/` 段）

## REMOVED Requirements（移除需求）

### Requirement: 移动端 CDN baseUrl 加载

**Reason**：移动端不再依赖 CDN，改用本地 assets 加载，原 `loadHtmlString(html, baseUrl: 'https://cdn.jsdelivr.net/npm/mathlive@0.101.2/dist/')` 方案废弃。
**Migration**：所有移动端 bootstrap 逻辑统一改为 `loadFlutterAsset`；web 端不受影响（web 端独立走 CDN 注入）。
