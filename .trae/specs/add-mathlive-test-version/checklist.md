# Checklist

## 阶段一：依赖引入

- [x] `pubspec.yaml` 中已添加 `mathlive_studio: ^0.1.2` 依赖
- [x] `flutter pub get` 执行成功，无依赖冲突
- [x] `flutter analyze` 无新增错误（与引入前相比）

## 阶段二：ComposeBox 集成

- [x] `lib/widgets/compose_box.dart` 顶部已添加 `import 'package:mathlive_studio/mathlive_studio.dart';`（行 9）
- [x] `_ComposeBoxState` 中已添加 `_mathKeyboardVisible` 和 `_latestLatex` 状态字段（行 2081-2082）
- [x] `_toggleMathKeyboard()` 方法已实现（行 2088-2103），包含：
  - [x] 打开时调用 `FocusScope.of(context).unfocus()`
  - [x] 打开时调用 `SystemChannels.textInput.invokeMethod('TextInput.hide')`
  - [x] 关闭时若 `_latestLatex.trim().isNotEmpty` 则调用 `_insertFormula`
  - [x] 关闭时清空 `_latestLatex`
  - [x] `setState` 切换 `_mathKeyboardVisible`
- [x] `_insertFormula(String latex)` 方法已实现（行 2105-2109），使用 `insertionIndex()` + `value.replaced()` 插入 `$$...$$` 格式
- [x] `composeButtons` 列表中已添加 [⌨️] IconButton（行 1498-1502），绑定 `inherited.toggleMathKeyboard` 和 `inherited.mathKeyboardVisible` 状态
- [x] `_ComposeBoxBody` 的 `Column` children 中已条件渲染 `MathLiveEmbeddedEditor`（行 1529-1533）
- [x] `MathLiveEmbeddedEditor` 的 `onLatexChanged` 回调正确更新 `_latestLatex`（通过 `inherited.onLatexChanged` → `_ComposeBoxState.onLatexChanged`）
- [x] `MathLiveEmbeddedEditor` 的 `isDark` 参数正确传递暗色模式状态（`Theme.of(context).brightness == Brightness.dark`）
- [x] `_ContentInput` 聚焦时若数学面板已打开，会自动关闭数学面板（通过 `_onContentFocusChanged` 监听 `controller.contentFocusNode`）

## 阶段三：验证

- [x] `flutter analyze` 通过，无新增错误（No issues found!）
- [ ] 应用可正常启动，无崩溃（需用户手动测试）
- [ ] ComposeBox 显示正常，新增的 [⌨️] 按钮可见（需用户手动测试）
- [ ] 点击 [⌨️] 按钮后 MathLive 面板显示，系统键盘收起（需用户手动测试）
- [ ] 在 `<math-field>` 中可编辑公式，虚拟键盘工作正常（需用户手动测试）
- [ ] 关闭面板时公式以 `$$...$$` 格式正确插入到内容输入框光标位置（需用户手动测试）
- [ ] 公式为空时关闭面板不会插入空 `$$$$`（需用户手动测试）
- [ ] 点击内容输入框时数学面板自动关闭，系统键盘弹出（需用户手动测试）

## 测试版范围确认

- [x] **未实现** LaTeX 格式转换（`latex_converter.dart` 未创建）
- [x] **未实现** 行间公式插入（仅 `$$...$$` 行内公式）
- [x] **未实现** 自定义 HTML 模板（直接使用 mathlive_studio 默认 HTML）
- [x] **未实现** 复制 MathLive 资源到 assets（使用 CDN 加载）
