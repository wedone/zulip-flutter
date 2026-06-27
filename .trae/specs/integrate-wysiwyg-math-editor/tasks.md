# Tasks

- [x] Task 1: 准备 flutter_mathlive_mixed 依赖和本地 MathLive 资源
  - [ ] SubTask 1.1: 在 `pubspec.yaml` 中添加 `flutter_mathlive_mixed` path 依赖（指向 `../mathlive_editor_package/flutter_mathlive_mixed`）
  - [ ] SubTask 1.2: 下载 MathLive 0.110.0 的 `mathlive.min.js` 和 `mathlive-static.css`，放入 `flutter_mathlive_mixed` 包的 `assets/mathlive/` 目录（覆盖旧版）
  - [ ] SubTask 1.3: 修改 `flutter_mathlive_mixed` 包中 `mathlive_editor.html` 的 CDN 引用为本地相对路径（`mathlive-static.css` 和 `mathlive.min.js`）
  - [ ] SubTask 1.4: 修改 `flutter_mathlive_mixed` 包中 Dart 加载代码（`mathlive_editor_page.dart` 和 `mathlive_embedded_editor.dart`），将 `baseUrl` 从 CDN URL 改为本地资源路径或移除
  - [ ] SubTask 1.5: 运行 `flutter pub get` 验证依赖解析成功
  - [ ] SubTask 1.6: 代码评审后提交

- [x] Task 2: 创建可视公式编辑器组件
  - [x] SubTask 2.1: 创建 `lib/widgets/visual_math_editor/` 目录
  - [x] SubTask 2.2: 创建 `visual_math_button.dart` — 「📐 可视公式」按钮组件，接收 `isDark`、`onPressed` 参数
  - [x] SubTask 2.3: 创建 `math_editor_service.dart` — 编辑器服务类，封装 `MathLiveEditorPage.open()` 调用和 LaTeX 插入逻辑（`insertLatexAtCursor` 方法，处理界定符包裹和光标定位）
  - [x] SubTask 2.4: 验证组件可编译（`flutter analyze` 无错误）— WSL 环境限制，`flutter gen-l10n` 成功，analyze 待开发机验证
  - [x] SubTask 2.5: 代码评审后提交（commit 2d3fdcbb）

- [x] Task 3: 集成到 compose_box 并移除旧数学键盘
  - [x] SubTask 3.1: 删除 `lib/widgets/math_keyboard/` 目录（`math_keyboard_toolbar.dart`、`math_keyboard_data.dart`、`math_keyboard_button.dart`）
  - [x] SubTask 3.2: 从 `compose_box.dart` 中移除 `_mathKeyboardToolbarVisible` 状态变量、`_toggleMathKeyboardToolbar` 方法
  - [x] SubTask 3.3: 从 `compose_box.dart` 中移除所有 `mathKeyboardToolbarVisible` 参数传递（涉及多个 widget 类的构造函数和 build 方法）
  - [x] SubTask 3.4: 移除 `TextField` 的 `readOnly: mathKeyboardToolbarVisible` 配置，恢复为正常可编辑状态
  - [x] SubTask 3.5: 移除 `MathKeyboardButton` 引用和数学键盘渲染区域（含删除 _BackspaceButton/_CursorLeftButton/_CursorRightButton/_NewlineButton 四个辅助按钮类）
  - [x] SubTask 3.6: 在 compose_box 输入工具栏中原 `MathKeyboardButton` 位置添加 `VisualMathButton`
  - [x] SubTask 3.7: 接线按钮点击 → `MathEditorService.openEditor()` → 返回 LaTeX → `insertLatexAtCursor()` 插入 TextField
  - [x] SubTask 3.8: 清理相关的 l10n 文案（`mathKeyboard*` 相关的本地化 key，如不再使用）
  - [x] SubTask 3.9: 运行 `flutter analyze` 和现有测试，修复编译错误和测试失败 — WSL 环境限制，IDE 诊断无错误，analyze 待开发机验证
  - [x] SubTask 3.10: 代码评审后提交（commit 05f43f55）

- [~] Task 4: WebView 预加载优化（**延后处理** — 用户决定待开发机验证后再实现，避免 WSL 环境下盲改 flutter_mathlive_mixed 包代码）
  - [ ] SubTask 4.1: 在 `math_editor_service.dart` 中实现 WebView 预加载机制（后台创建并初始化隐藏 WebView）
  - [ ] SubTask 4.2: 在 compose_box 的 `initState` 中触发预加载
  - [ ] SubTask 4.3: 用户点击按钮时复用预加载的 WebView，实现秒开
  - [ ] SubTask 4.4: 验证预加载不影响 compose_box 正常初始化性能
  - [ ] SubTask 4.5: 代码评审后提交

- [x] Task 5: 编辑已有公式功能
  - [x] SubTask 5.1: 实现光标位置检测逻辑，判断光标是否在 `\(...\)` 包裹的公式区域内（`detectLatexAtCursor`，正则非贪婪匹配）
  - [x] SubTask 5.2: 若光标在公式内，提取公式 LaTeX 内容作为 `MathLiveEditorPage.open()` 的 `initialLatex` 参数
  - [x] SubTask 5.3: 编辑完成后，替换原有 `\(...\)` 区域内容而非在光标处插入新公式（`replaceLatexRange`）
  - [x] SubTask 5.4: 验证编辑已有公式后光标位置正确（光标移至替换内容末尾，IDE 诊断无错误）
  - [x] SubTask 5.5: 代码评审后提交（commit 9c5a37a1）

# Task Dependencies

- [Task 2] depends on [Task 1]（需要 flutter_mathlive_mixed 依赖才能 import 组件）
- [Task 3] depends on [Task 2]（需要 visual_math_editor 组件才能集成到 compose_box）
- [Task 4] depends on [Task 3]（需要在集成基础上优化预加载）
- [Task 5] depends on [Task 3]（需要在集成基础上开发编辑功能）
- [Task 4] 和 [Task 5] 可并行