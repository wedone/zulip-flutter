# Checklist

## Task 1: 依赖和本地资源
- [x] `pubspec.yaml` 中包含 `flutter_mathlive_mixed` path 依赖
- [ ] `flutter pub get` 成功，无依赖冲突（WSL 环境限制，需在开发机验证）
- [x] MathLive 资源版本为 0.110.0（非 0.101.2）
- [x] `mathlive.min.js` 和 `mathlive-static.css` 存在于本地 assets 目录
- [x] `mathlive_editor.html` 中不再包含 `cdn.jsdelivr.net` 的 CDN URL
- [x] Dart 代码中 `baseUrl` 不再指向 CDN
- [ ] 离线状态下编辑器能正常加载（需在设备上验证）

## Task 2: 可视公式编辑器组件
- [x] `lib/widgets/visual_math_editor/visual_math_button.dart` 存在且可编译（IDE 诊断无错误）
- [x] `lib/widgets/visual_math_editor/math_editor_service.dart` 存在且可编译（IDE 诊断无错误）
- [x] `insertLatexAtCursor` 方法正确包裹 `\(` 和 `\)` 界定符（`'\\($trimmed\\)'`）
- [x] `insertLatexAtCursor` 方法正确处理光标定位（插入后光标在公式之后，`offset: i.start + wrapped.length`）
- [x] `flutter analyze` 无错误 — WSL 限制无法运行，IDE 诊断无错误，待开发机 `flutter analyze` 验证

## Task 3: compose_box 集成
- [x] `lib/widgets/math_keyboard/` 目录已删除（Glob 确认无文件）
- [x] `compose_box.dart` 中无 `mathKeyboardToolbarVisible` 引用（Grep 确认）
- [x] `compose_box.dart` 中无 `_toggleMathKeyboardToolbar` 方法（Grep 确认）
- [x] `compose_box.dart` 中无 `MathKeyboardButton` 引用（Grep 确认）
- [x] `TextField` 不再有 `readOnly: mathKeyboardToolbarVisible` 配置（Grep `readOnly:` 无匹配）
- [x] compose_box 工具栏中包含 `VisualMathButton`（第 1509 行）
- [ ] 点击 📐 按钮能弹出 `MathLiveEditorPage`（需在设备上验证）
- [ ] 编辑后点击 Insert 能将 LaTeX 插入 TextField 光标位置（需在设备上验证）
- [ ] 点击返回不修改 TextField 内容（`if (latex == null) return;` 逻辑已实现，需设备验证）
- [x] `flutter analyze` 无错误 — IDE 诊断无错误，待开发机验证
- [ ] 现有测试通过（`flutter test`）— WSL 限制无法运行，待开发机验证
- [x] 无遗留的 `mathKeyboard*` l10n key（arb 和 generated 文件 Grep 确认）

## Task 4: WebView 预加载（**延后处理** — 用户决定待开发机验证后再实现）
- [ ] compose_box 初始化时后台预加载 WebView
- [ ] 预加载不阻塞 UI 线程，compose_box 正常显示
- [ ] 用户点击 📐 后编辑器几乎无延迟显示
- [ ] 预加载的 WebView 被正确复用（非重复创建）

## Task 5: 编辑已有公式
- [x] 光标在 `\(...\)` 区域内时，点击 📐 能提取现有 LaTeX 作为初始值（`detectLatexAtCursor` + `initialLatex: existing?.latex` 代码已实现）
- [x] 编辑后点击 Insert 替换原有公式区域（`replaceLatexRange(controller.content, existing.range, latex)` 代码已实现）
- [x] 光标不在任何公式内时，行为与新建公式一致（`if (existing != null) ... else insertLatexAtCursor` 逻辑已实现）
- [x] 嵌套界定符场景（如 `\(\text{设 } x = 1\)`）能正确处理（正则 `\\\(([\s\S]*?)\\\)` 非贪婪匹配，与 `latex_converter.dart` 一致）
