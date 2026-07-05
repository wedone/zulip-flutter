# Tasks

## 阶段一：依赖引入

- [x] Task 1: 添加 mathlive_studio 依赖到 pubspec.yaml
  - [x] SubTask 1.1: 在 `pubspec.yaml` 的 `dependencies` 部分添加 `mathlive_studio: ^0.1.2`
  - [x] SubTask 1.2: 执行 `flutter pub get` 确认依赖解析成功
  - [x] SubTask 1.3: 确认项目可正常编译（`flutter analyze` 无新增错误）

## 阶段二：ComposeBox 集成

- [x] Task 2: 在 `_ComposeBoxState` 中添加数学面板状态和切换逻辑
  - [x] SubTask 2.1: 在 `lib/widgets/compose_box.dart` 顶部添加 `import 'package:mathlive_studio/mathlive_studio.dart';`
  - [x] SubTask 2.2: 在 `_ComposeBoxState` 中添加状态字段 `bool _mathKeyboardVisible = false;` 和 `String _latestLatex = '';`
  - [x] SubTask 2.3: 实现 `_toggleMathKeyboard()` 方法：打开时调用 `FocusScope.of(context).unfocus()` + `SystemChannels.textInput.invokeMethod('TextInput.hide')`；关闭时若 LaTeX 非空则调用 `_insertFormula(_latestLatex)`，然后清空 `_latestLatex`，最后 `setState` 切换 `_mathKeyboardVisible`
  - [x] SubTask 2.4: 实现 `_insertFormula(String latex)` 方法：通过 `controller.content.insertionIndex()` 获取光标位置，调用 `controller.content.value = controller.content.value.replaced(i, '\$\$$latex\$\$')` 插入 `$$...$$` 格式（注：用 `\$` 转义避免 Dart 字符串插值歧义）

- [x] Task 3: 在操作按钮行添加 [⌨️] 切换按钮
  - [x] SubTask 3.1: 在 `_ComposeBoxBody.build` 中（约第 1492 行），向 `composeButtons` 列表添加 `IconButton(icon: Icon(Icons.keyboard), isSelected: ..., onPressed: ...)`
  - [x] SubTask 3.2: 确保按钮使用项目现有的 `IconButton` 主题（`iconButtonThemeData`）

- [x] Task 4: 在 ComposeBox 下方条件渲染 MathLive 面板
  - [x] SubTask 4.1: 在 `_ComposeBoxBody` 的 `Column` children 中，于按钮行 `SizedBox` 之后添加条件渲染：`if (inherited.mathKeyboardVisible) MathLiveEmbeddedEditor(isDark: ..., onLatexChanged: inherited.onLatexChanged)`
  - [x] SubTask 4.2: `isDark` 通过 `Theme.of(context).brightness == Brightness.dark` 获取

- [x] Task 5: 实现系统键盘与数学面板互斥
  - [x] SubTask 5.1: 在 `_ComposeBoxState._setNewController` 中给 `controller.contentFocusNode` 添加监听器 `_onContentFocusChanged`，获得焦点且面板可见时关闭面板（不插入空公式）
  - [x] SubTask 5.2: 验证打开数学面板时系统键盘确实收起（通过 `FocusScope.unfocus()` + `SystemChannels.textInput.invokeMethod('TextInput.hide')`）

## 阶段三：验证（测试版核心目标）

- [x] Task 6: 编译与基础验证
  - [x] SubTask 6.1: 执行 `flutter analyze` 确认无新增错误（结果：No issues found!）
  - [ ] SubTask 6.2: 执行 `flutter run` 启动应用，确认应用可正常启动（需用户手动测试）
  - [ ] SubTask 6.3: 在会话页面验证 ComposeBox 显示正常，新增的 [⌨️] 按钮可见（需用户手动测试）

- [ ] Task 7: 功能验证（需手动测试）
  - [ ] SubTask 7.1: 点击 [⌨️] 按钮，验证 MathLive 面板显示且系统键盘收起
  - [ ] SubTask 7.2: 在 `<math-field>` 中编辑公式（如 `\frac{1}{2}`），验证虚拟键盘工作正常
  - [ ] SubTask 7.3: 再次点击 [⌨️] 按钮，验证公式以 `$$...$$` 格式插入到内容输入框
  - [ ] SubTask 7.4: 验证公式为空时关闭面板不会插入空 `$$$$`
  - [ ] SubTask 7.5: 验证点击内容输入框时数学面板自动关闭

# Task Dependencies

- Task 2 依赖 Task 1（需要 mathlive_studio 包可用才能 import）
- Task 3 依赖 Task 2（需要 `_toggleMathKeyboard` 方法）
- Task 4 依赖 Task 2（需要 `_latestLatex` 状态）
- Task 5 依赖 Task 2、Task 4
- Task 6 依赖 Task 1-5
- Task 7 依赖 Task 6
