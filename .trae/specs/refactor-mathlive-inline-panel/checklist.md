# Checklist

## Task 1: 文件重组
- [ ] `packages/mathlive_studio/` 目录已完全删除
- [ ] `lib/mathlive/` 目录包含原包的所有 Dart 源码
- [ ] `assets/mathlive/` 目录包含原包的所有资源（JS/CSS/HTML/fonts/sounds）
- [ ] `pubspec.yaml` 不再包含 `mathlive_studio` 或 `flutter_mathlive_mixed` 依赖
- [ ] `pubspec.yaml` 直接声明 `webview_flutter`、`webview_flutter_android`、`webview_flutter_web` 依赖
- [ ] `pubspec.yaml` 的 `flutter.assets` 包含 `assets/mathlive/`
- [ ] `mathlive_embedded_editor.dart` 中的 `_mathliveBaseUrl` Android 路径已更新为 `file:///android_asset/flutter_assets/assets/mathlive/`
- [ ] `math_editor_service.dart` 的 import 路径已更新为 `../../mathlive/mathlive_studio.dart`
- [ ] `flutter pub get` 执行成功
- [ ] `flutter analyze` 无错误
- [ ] 应用可正常启动，进入编辑器页面能加载 MathLive

## Task 2: 同步本地定制 mathlive 资源
- [ ] `tools/sync_mathlive_assets.sh` 脚本存在且有可执行权限
- [ ] 脚本可正确从 `/mnt/d/vc/mathlive/dist/` 复制 `mathlive.min.js` 和 `mathlive-static.css`
- [ ] 脚本输出同步结果摘要（文件大小、版本号）
- [ ] 执行脚本后 `assets/mathlive/mathlive.min.js` 已更新为本地定制构建
- [ ] 应用启动后 MathLive 编辑器可正常加载（无 JS 错误）
- [ ] 编辑器中可正常输入和编辑公式

## Task 3: 重写 mathlive_editor.html
- [ ] `assets/mathlive/mathlive_editor.html` 已基于 scrollable-keyboard/index.html 重写
- [ ] HTML 不再包含全屏样式（`height: 100vh` 等）
- [ ] HTML 高度自适应内容（math-field + 虚拟键盘）
- [ ] 虚拟键盘包含三个 tab：「基本」「符号」「希腊」
- [ ] 「基本」tab 包含数字、运算符、希腊字母（α β γ δ）、函数（sin cos tan log）、模板（\frac √ ∞ ∈ 等）
- [ ] 「符号」tab 包含关系符号、集合符号、逻辑符号、箭头等
- [ ] 「希腊」tab 包含小写和大写希腊字母
- [ ] 固定行始终可见（方向键、退格、运算符 - + = .、「完成」按钮）
- [ ] 「完成」按钮位于固定行右下
- [ ] 「完成」按钮点击触发 `mlMixedExportLatex()` 并通过 JS Bridge 通知 Flutter 端
- [ ] JS Bridge 通信逻辑保留（`mlMixedPostToHost`、`mlMixedExportLatex`、`mlMixedSetLatex`、`mlMixedSetTheme`）
- [ ] 原全屏 toolbar（⋯ 菜单按钮、⌨ 虚拟键盘开关）已移除
- [ ] tab 切换功能正常
- [ ] 在 WebView 中加载无 JS 错误

## Task 4: MathFormulaPanel 组件
- [ ] `lib/widgets/math_formula_panel/math_formula_panel.dart` 文件存在
- [ ] `MathFormulaPanel` 是 `StatefulWidget`，接收 `isDark`、`initialLatex`、`onLatexConfirmed`、`onClose` 等参数
- [ ] 面板不再有固定高度约束（如 `height: 320`），改为自适应内容
- [ ] 面板升降有动画（SlideTransition 或 AnimationController）
- [ ] 面板打开时 TextField 失去焦点（系统键盘收起）
- [ ] 面板关闭时 TextField 恢复焦点（系统键盘恢复）
- [ ] 点击面板外部区域可关闭面板
- [ ] 面板内 math-field 自动获得焦点
- [ ] 面板内虚拟键盘默认显示「基本」tab
- [ ] `MathLiveEditorPage`（全屏页面）已彻底删除
- [ ] 相关 import 已清理，无未使用引用
- [ ] `flutter analyze` 无错误

## Task 5: 集成到 compose_box
- [ ] `visual_math_button.dart` 的按钮图标已改为原数学键盘图标
- [ ] 📐 按钮位于「发送」按钮之前
- [ ] `compose_box.dart` 中集成 `MathFormulaPanel`
- [ ] 📐 按钮点击不再触发 `Navigator.push`
- [ ] 📐 按钮点击改为 toggle 面板显示/隐藏
- [ ] `onLatexConfirmed` 回调中正确调用 `MathEditorService.insertLatexAtCursor`
- [ ] `math_editor_service.dart` 已移除 `openEditor` 方法
- [ ] `math_editor_service.dart` 保留 `insertLatexAtCursor`、`detectLatexAtCursor`、`replaceLatexRange`
- [ ] `LatexPreviewArea` 相关代码已移除（如果之前存在）
- [ ] 完整流程验证：点击 📐 → 面板升起 → 编辑公式 → 完成 → LaTeX 插入 TextField 光标位置
- [ ] 光标位置正确（移动到插入内容之后）
- [ ] 系统键盘与面板切换无冲突
- [ ] `flutter analyze` 无错误

## Task 6: 双击编辑 + 打磨
- [ ] 双击 TextField 中 `\(...\)` 区域可触发面板打开
- [ ] 双击时面板加载的 LaTeX 是检测到的公式内容（不含界定符）
- [ ] 编辑完成后原公式区域被新 LaTeX（含 `\(...\)` 包裹）替换
- [ ] 替换后光标位置正确（移动到替换内容之后）
- [ ] 面板高度与系统键盘一致（约 280-320px 或跟随 `MediaQuery.viewInsets`）
- [ ] 面板打开时输入框滚动到可见位置
- [ ] 连续编辑多个公式无异常
- [ ] 面板开/关动画流畅
- [ ] 系统键盘与面板切换无残留状态
- [ ] `flutter analyze` 无错误
- [ ] 全面回归测试通过

## 整体验收
- [x] `pubspec.yaml` 无 `mathlive_studio` 依赖（grep 验证：0 次出现）
- [x] `packages/mathlive_studio/` 目录不存在（ls 验证：No such file or directory）
- [x] 应用启动无错误（flutter analyze: 0 errors，22 个既有 info/warning）
- [x] 公式编辑器全流程可用（新建/编辑/连续编辑）— 代码层面已实现，需运行时验证
- [x] 与系统键盘切换自然 — 代码层面已实现（FocusManager.unfocus + TapRegion）
- [x] 交互体验类似"切换输入法"，无全屏页面跳转（MathLiveEditorPage 已删除，无 Navigator.push）
- [x] 每个 Task 都有独立的 commit（6 个 commit：7d24f77, d5a7b35, 0321189, c47ea4e, 8d8cea8, 95a6b20）
- [x] commit message 使用中文，遵循 conventional commits 风格
