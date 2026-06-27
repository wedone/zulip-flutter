# Tasks

## Task 1: LaTeX 界定符自动转换核心逻辑
- [x] Task 1.1: 创建 `lib/model/latex_converter.dart`，实现 `convertLatexDelimitersToZulip(String input)` 函数
  - 处理 `\[...\]` → `` ```math\n...\n``` ``
  - 处理 `\(...\)` → `$$...$$`
  - 处理 `$$...$$`（含换行）→ `` ```math\n...\n``` ``
  - 处理 `$...$` → `$$...$$`
  - 保护代码块中的内容不转换
  - 保护已有 `` ```math ``` `` 块不重复转换
  - 处理转义 `\$` 不作为界定符
- [x] Task 1.2: 为转换函数编写单元测试 `test/model/latex_converter_test.dart`

## Task 2: 自动转换设置开关
- [x] Task 2.1: 在 `lib/model/settings.dart` 的 `BoolGlobalSetting` 枚举中添加 `autoConvertLatexDelimiters` 设置项（默认值 `true`）
- [x] Task 2.2: 在 `lib/widgets/settings.dart` 的实验性功能页面中显示该开关
- [x] Task 2.3: 添加本地化字符串到 `assets/l10n/app_en.arb` 及其他语言文件

## Task 3: 发送时集成自动转换
- [x] Task 3.1: 修改 `lib/widgets/compose_box.dart` 中 `_SendButtonState._send()` 方法，在 `store.sendMessage` 调用前根据设置开关决定是否对 `content` 调用 `convertLatexDelimitersToZulip`
- [x] Task 3.2: 确认编辑消息流程（`_EditMessageComposeBoxBody` 的保存逻辑）不经过转换
- [x] Task 3.3: 为发送时转换编写 widget 测试

## Task 4: 代码评审与提交（LaTeX 转换功能）
- [x] Task 4.1: 评审 LaTeX 转换功能的所有代码
- [ ] Task 4.2: 提交 LaTeX 转换功能

## Task 5: 数学符号数据定义
- [x] Task 5.1: 创建 `lib/widgets/math_symbols/math_symbols_data.dart`，定义符号和模板数据结构
  - `MathSymbolItem` sealed class（UnicodeSymbol / LatexSnippet / LatexWrapper）
  - 各分类的符号列表数据
  - 常用函数列表（sin, cos, tan, log, ln, lim 等）
  - 公式模板列表（\frac{}{}, \sqrt{}, \sum_{}^{} 等）

## Task 6: 最近使用符号持久化
- [x] Task 6.1: 创建 `lib/model/math_symbols_history.dart`，实现基于 SharedPreferences 的最近使用记录
  - `recordSymbol(String symbol)` 方法
  - `getRecentSymbols()` 方法
  - 最多记录20个，显示10个，去重

## Task 7: 数学符号工具栏 UI
- [x] Task 7.1: 创建 `lib/widgets/math_symbols/math_symbols_toolbar.dart`，实现工具栏主组件
  - 分类标签栏（常用/希腊/运算/关系/集合/模板）
  - 符号网格展示
  - 最近使用区域
  - 点击符号插入到输入框光标位置
  - 工具栏保持打开状态
- [x] Task 7.2: 创建 `lib/widgets/math_symbols/math_symbols_button.dart`，实现触发按钮
  - 点击展开/收起工具栏
  - 与现有附件按钮风格一致
- [x] Task 7.3: 修改 `lib/widgets/compose_box.dart`，在 `_ComposeBoxBody` 的按钮行添加数学符号按钮，在输入框上方添加工具栏区域
- [x] Task 7.4: 添加本地化字符串

## Task 8: 代码评审与提交（数学符号工具栏）
- [x] Task 8.1: 评审数学符号工具栏的所有代码
- [ ] Task 8.2: 提交数学符号工具栏功能

## Task 9: 版本号更新
- [x] Task 9.1: 更新 `pubspec.yaml` 中版本号 `30.0.272-for-math.1+1` → `30.0.272-for-math.2+1`
- [x] Task 9.2: 更新 `RELEASE_NOTES.md` 中版本号 `v30.0.272-for-math.1` → `v30.0.272-for-math.2`
- [x] Task 9.3: 更新 `README.md` 中版本号 `v30.0.272-for-math.1` → `v30.0.272-for-math.2`
- [x] Task 9.4: 更新 `.github/workflows/build-stable-release.yml` 中默认版本号

# Task Dependencies
- [Task 2] depends on [Task 1] (设置开关需要先有转换逻辑)
- [Task 3] depends on [Task 1] and [Task 2] (发送集成需要转换逻辑和设置开关)
- [Task 4] depends on [Task 1], [Task 2], [Task 3] (评审和提交在功能完成后)
- [Task 5], [Task 6] 可并行（数据定义和持久化互不依赖）
- [Task 7] depends on [Task 5] and [Task 6] (UI 需要数据和持久化)
- [Task 8] depends on [Task 5], [Task 6], [Task 7]
- [Task 9] depends on [Task 4] and [Task 8] (版本号在所有功能完成后更新)
