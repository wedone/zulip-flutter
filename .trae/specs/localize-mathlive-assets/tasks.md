# Tasks

## 已完成（前序会话已执行）

- [x] Task 1: 在 zulip-flutter pubspec.yaml 添加 flutter_mathlive_mixed path 依赖
  - 在 `flutter_math_fork` 与 `flutter_svg` 之间插入：
    ```yaml
    flutter_mathlive_mixed:
      path: ../mathlive_editor_package/flutter_mathlive_mixed
    ```
  - 验证：`/mnt/d/vc/zulip-flutter/pubspec.yaml` 第 43-44 行存在该依赖
- [x] Task 2: 下载 MathLive 0.110.0 的 mathlive.min.js 与 mathlive-static.css
  - 来源：`https://cdn.jsdelivr.net/npm/mathlive@0.110.0/mathlive.min.js` 与 `.../mathlive-static.css`（注意 0.110.0 文件在包根目录而非 `/dist/`）
  - 目标：`/mnt/d/vc/mathlive_editor_package/flutter_mathlive_mixed/assets/mathlive/mathlive.min.js`（843724 字节）与 `mathlive-static.css`（13154 字节，含 21 处 `url(fonts/...)` 引用）
  - 验证：文件存在且版本为 0.110.0
- [x] Task 3: 修改 mathlive_editor.html 将 CDN 引用改为本地相对路径
  - 第 6-8 行改为：
    ```html
    <!-- Local relative paths (inlined into HTML at runtime for WebView; web loads MathLive separately) -->
    <link rel="stylesheet" href="mathlive-static.css" />
    <script src="mathlive.min.js"></script>
    ```
  - 验证：HTML 中无 jsdelivr CDN URL

## 待完成

- [ ] Task 4: 修改 mathlive_editor_page.dart 的 _bootstrapWebView
  - 将第 143-163 行的 `loadHtmlString(html, baseUrl: CDN)` 改为 `loadFlutterAsset(kMathLiveEditorHtmlAsset)`
  - 移除 `patchMathLiveEditorHtml` 与 `rootBundle` 的使用（loadFlutterAsset 直接加载未 patch 的 HTML，占位符自洽）
  - 修改第 6 行 import：从 `import 'package:flutter/services.dart' show rootBundle;` 改为移除该行（不再使用 rootBundle）
  - 保留 try/catch 错误处理逻辑
  - 验证：文件中无 `baseUrl: 'https://cdn.jsdelivr.net'`，无 `rootBundle` 引用
- [ ] Task 5: 修改 mathlive_embedded_editor.dart 的 _bootstrap
  - 将第 143-163 行的 `loadHtmlString(html, baseUrl: CDN)` 改为 `loadFlutterAsset(kMathLiveEditorHtmlAsset)`
  - 移除 `patchMathLiveEditorHtml` 与 `rootBundle` 的使用
  - 修改第 7 行 import：从 `import 'package:flutter/services.dart' show Clipboard, ClipboardData, rootBundle;` 改为 `import 'package:flutter/services.dart' show Clipboard, ClipboardData;`
  - 保留 try/catch 错误处理逻辑
  - 验证：文件中无 `baseUrl: 'https://cdn.jsdelivr.net'`，无 `rootBundle` 引用
- [ ] Task 6: 修改 mathlive_editor_web.dart 的 CDN 版本号
  - 第 98-99 行：`href='https://cdn.jsdelivr.net/npm/mathlive@0.101.2/dist/mathlive-static.css'` → `href='https://cdn.jsdelivr.net/npm/mathlive@0.110.0/mathlive-static.css'`
  - 第 111 行：`src = 'https://cdn.jsdelivr.net/npm/mathlive@0.101.2/dist/mathlive.min.js'` → `src = 'https://cdn.jsdelivr.net/npm/mathlive@0.110.0/mathlive.min.js'`
  - 注意：去掉 `/dist/` 段（0.110.0 文件在包根目录）
  - 验证：文件中无 `0.101.2`，无 `/dist/` 段
- [ ] Task 7: 修改 flutter_mathlive_mixed pubspec.yaml 添加 fonts 资源声明
  - 在 `flutter.assets` 下追加 `assets/mathlive/fonts/`（Flutter 资源声明不递归子目录，需单独声明）
  - 最终内容：
    ```yaml
    flutter:
      assets:
        - assets/mathlive/
        - assets/mathlive/fonts/
    ```
  - 验证：pubspec.yaml 包含 `assets/mathlive/fonts/`
- [ ] Task 8: 下载 21 个 woff2 字体文件到 assets/mathlive/fonts/
  - 来源：`https://cdn.jsdelivr.net/npm/mathlive@0.110.0/fonts/`（每个字体文件单独下载）
  - 字体清单（21 个 woff2）：KaTeX_AMS, KaTeX_Caligraphic, KaTeX_Fraktur, KaTeX_Main, KaTeX_Math, KaTeX_SansSerif, KaTeX_Script, KaTeX_Size1, KaTeX_Size2, KaTeX_Size3, KaTeX_Size4, KaTeX_Typewriter, MathLive_Main, etc.（以实际 CDN 目录为准）
  - 目标目录：`/mnt/d/vc/mathlive_editor_package/flutter_mathlive_mixed/assets/mathlive/fonts/`
  - 验证：目录存在且包含 21 个 .woff2 文件
- [ ] Task 9: 运行 flutter pub get 验证依赖解析
  - 命令：`flutter pub get`（在 `/mnt/d/vc/zulip-flutter` 目录）
  - 若 flutter 工具因 flutter.version.json 问题失败，回退为 `dart pub get`（需先手动写入 `bin/cache/flutter.version.json`）
  - 验证：命令退出码 0，输出 "Got dependencies!" 或类似成功信息
- [ ] Task 10: 运行 flutter analyze 检查编译错误
  - 命令：`flutter analyze`（在 `/mnt/d/vc/zulip-flutter` 目录）
  - 验证：无 error 级别问题（warning/info 可接受）

# Task Dependencies

- Task 4, 5, 6, 7 可并行（互不依赖）
- Task 8 独立（仅下载文件，不依赖代码改动）
- Task 9 依赖 Task 1（path 依赖声明）与 Task 7（fonts 资源声明）
- Task 10 依赖 Task 4, 5, 6（代码改动完成）与 Task 9（依赖解析成功）
