# Tasks

每个大 Task 完成后进行一次 commit。Commit message 使用中文，遵循 conventional commits 风格。

- [x] Task 1: 文件重组 — 移除 mathlive_studio 中介包，将代码收入主项目（commit: 7d24f77）
  - [ ] SubTask 1.1: 将 `packages/mathlive_studio/lib/` 整体搬到 `lib/mathlive/`（保留 `mathlive_studio.dart` 文件名不改，避免大面积 import 修改）
  - [ ] SubTask 1.2: 将 `packages/mathlive_studio/assets/mathlive/` 整体搬到 `assets/mathlive/`（包含 mathlive.min.js、mathlive-static.css、mathlive_editor.html、fonts/、sounds/）
  - [ ] SubTask 1.3: 删除 `packages/mathlive_studio/` 整个目录
  - [ ] SubTask 1.4: 更新主 `pubspec.yaml`：
    - 移除 `mathlive_studio: path: packages/mathlive_studio` 依赖
    - 添加 `webview_flutter: ^4.10.0`、`webview_flutter_android: ^4.3.2`、`webview_flutter_web: ^0.2.3+2` 直接依赖
    - 在 `flutter.assets` 中添加 `assets/mathlive/`
  - [ ] SubTask 1.5: 更新 Android asset 路径（`mathlive_embedded_editor.dart` 中的 `_mathliveBaseUrl`）
    - 原：`file:///android_asset/flutter_assets/packages/mathlive_studio/assets/mathlive/`
    - 新：`file:///android_asset/flutter_assets/assets/mathlive/`
  - [ ] SubTask 1.6: 更新 `lib/widgets/visual_math_editor/math_editor_service.dart` 的 import 路径
    - 原：`import 'package:mathlive_studio/mathlive_studio.dart';`
    - 新：`import '../../mathlive/mathlive_studio.dart';`
  - [ ] SubTask 1.7: 执行 `flutter pub get` 和 `flutter analyze`，确保编译通过
  - [ ] SubTask 1.8: **Commit** — `refactor(mathlive): 移除 mathlive_studio 中介包，代码收入主项目`

- [x] Task 2: 同步本地定制 mathlive 资源（commit: 95a6b20）
  - [ ] SubTask 2.1: 创建 `tools/sync_mathlive_assets.sh` 脚本
    - 从 `/mnt/d/vc/mathlive/dist/mathlive.min.js` 复制到 `assets/mathlive/mathlive.min.js`
    - 从 `/mnt/d/vc/mathlive/dist/mathlive-static.css` 复制到 `assets/mathlive/mathlive-static.css`
    - 输出同步结果摘要（文件大小、版本号）
  - [ ] SubTask 2.2: 执行脚本，实际同步资源到 `assets/mathlive/`
  - [ ] SubTask 2.3: 验证应用启动正常，MathLive 编辑器能加载
  - [ ] SubTask 2.4: **Commit** — `chore(mathlive): 添加资源同步脚本，更新为本地定制构建`

- [x] Task 3: 重写 mathlive_editor.html 为 scrollable-keyboard 布局（commit: d5a7b35）
  - [ ] SubTask 3.1: 基于 `/mnt/d/vc/mathlive/examples/scrollable-keyboard/index.html` 重写 `assets/mathlive/mathlive_editor.html`：
    - 保留 JS Bridge 通信逻辑（`mlMixedPostToHost`、`mlMixedExportLatex`、`mlMixedSetLatex`、`mlMixedSetTheme` 等）
    - 去除全屏样式，改为高度自适应
    - 嵌入自定义虚拟键盘布局（基本/符号/希腊 三 tab）
    - 固定行保留方向键、退格、运算符、完成按钮
    - 「完成」按钮触发 `mlMixedExportLatex()` 并通过 JS Bridge 通知 Flutter 端关闭面板
  - [ ] SubTask 3.2: 移除原 `mathlive_editor.html` 中的全屏 toolbar（⋯ 菜单按钮、⌨ 虚拟键盘开关），由新布局替代
  - [ ] SubTask 3.3: 验证 HTML 在 WebView 中正确加载，键盘 tab 切换正常
  - [ ] SubTask 3.4: **Commit** — `feat(mathlive): 重写编辑器 HTML 为 scrollable-keyboard 布局`

- [x] Task 4: 实现 MathFormulaPanel 内联面板组件（commit: 0321189）
  - [ ] SubTask 4.1: 创建 `lib/widgets/math_formula_panel/math_formula_panel.dart`
    - 基于 `MathLiveEmbeddedEditor` 改造
    - 移除固定高度约束，自适应内容（math-field + 虚拟键盘）
    - 通过 `ValueListenable<bool>` 或 controller 控制显示/隐藏
    - 接收 `initialLatex`、`isDark`、`onLatexConfirmed`、`onClose` 等参数
  - [ ] SubTask 4.2: 实现面板升降动画（类似键盘升起的 SlideTransition）
  - [ ] SubTask 4.3: 实现系统键盘抑制逻辑：面板打开时 unfocus TextField，面板关闭时恢复 focus
  - [ ] SubTask 4.4: 实现点击面板外部关闭（GestureDetector + onTap）
  - [ ] SubTask 4.5: 删除 `MathLiveEditorPage`（全屏页面），相关代码彻底移除
  - [ ] SubTask 4.6: 验证面板可正常打开、编辑、关闭
  - [ ] SubTask 4.7: **Commit** — `feat(mathlive): 实现 MathFormulaPanel 内联编辑面板`

- [x] Task 5: 集成 MathFormulaPanel 到 compose_box（commit: c47ea4e6）
  - [ ] SubTask 5.1: 修改 `lib/widgets/visual_math_editor/visual_math_button.dart`：
    - 按钮图标改为原数学键盘图标（查 git history 确认具体图标）
    - 按钮位置：发送按钮前
  - [ ] SubTask 5.2: 修改 `lib/widgets/compose_box.dart`：
    - 集成 `MathFormulaPanel`，根据按钮状态控制显示/隐藏
    - 📐 按钮点击不再触发 `Navigator.push`，改为 toggle 面板
    - `onLatexConfirmed` 回调中调用 `MathEditorService.insertLatexAtCursor`
  - [ ] SubTask 5.3: 简化 `lib/widgets/visual_math_editor/math_editor_service.dart`：
    - 移除 `openEditor` 方法（不再需要 Navigator.push）
    - 保留 `insertLatexAtCursor`、`detectLatexAtCursor`、`replaceLatexRange` 工具方法
  - [ ] SubTask 5.4: 移除 `LatexPreviewArea` 相关代码（如果还存在）
  - [ ] SubTask 5.5: 验证完整流程：点击 📐 → 面板升起 → 编辑 → 完成 → LaTeX 插入 TextField
  - [ ] SubTask 5.6: **Commit** — `feat(compose_box): 集成 MathFormulaPanel 内联面板，移除全屏编辑器和预览区`

- [x] Task 6: 双击编辑已有公式 + 打磨（commit: 8d8cea8）
  - [ ] SubTask 6.1: 实现 TextField 双击 `\(...\)` 区域检测，调用 `MathEditorService.detectLatexAtCursor`
  - [ ] SubTask 6.2: 双击时打开面板，加载检测到的 LaTeX，编辑完成后调用 `replaceLatexRange` 替换原公式
  - [ ] SubTask 6.3: 调整面板高度与系统键盘一致（约 280-320px，跟随 `MediaQuery.viewInsets`）
  - [ ] SubTask 6.4: 面板打开时输入框滚动到可见位置
  - [ ] SubTask 6.5: 性能优化：ComposeBox 初始化时预加载 WebView 实例（可选，若加载速度可接受则跳过）
  - [ ] SubTask 6.6: 全面回归测试：新建公式、编辑公式、连续编辑多个公式、面板开/关、系统键盘切换
  - [ ] SubTask 6.7: **Commit** — `feat(mathlive): 支持双击编辑公式，优化面板交互体验`

# Task Dependencies

- Task 2 依赖 Task 1（资源目录已搬到 `assets/mathlive/` 才能同步）
- Task 3 依赖 Task 1（HTML 文件位置已搬迁）
- Task 4 依赖 Task 1（Dart 代码已搬到 `lib/mathlive/`）和 Task 3（HTML 已重写）
- Task 5 依赖 Task 4（MathFormulaPanel 已实现）
- Task 6 依赖 Task 5（compose_box 已集成面板）

# Parallel Opportunities

- Task 2 与 Task 3 在 Task 1 完成后可并行（一个改 JS 资源，一个改 HTML）
- Task 4 的子任务 4.1-4.4 可在 Task 3 完成后并行实施
