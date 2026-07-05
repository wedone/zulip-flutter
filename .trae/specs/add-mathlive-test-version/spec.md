# MathLive 数学公式输入功能（测试版）Spec

## Why

当前 Zulip Flutter 项目仅有公式渲染（只读）能力，完全没有公式输入（写）能力。高中学学生讨论数学问题时无法在移动端高效输入 LaTeX 公式。需要一个数学专用的虚拟键盘 + 所见即所得的公式编辑器，编辑完成后一键插入到消息内容中。

测试版目标：以最小改动验证 MathLive 在 Flutter 中的可行性，直接使用 `mathlive_studio` 包，不做自定义修改，先跳过 LaTeX 格式转换。

## What Changes

- 在 `pubspec.yaml` 中添加 `mathlive_studio: ^0.1.2` 依赖
- 修改 `lib/widgets/compose_box.dart`，添加 [⌨️] 切换按钮和 MathLive 编辑面板
- 使用 `mathlive_studio` 包的 `MathLiveEmbeddedEditor` 作为面板嵌入 ComposeBox 下方
- 通过 `onLatexChanged` 回调实时同步 LaTeX，关闭面板时以 `$$...$$` 格式插入到内容输入框光标位置
- 系统键盘与数学面板互斥切换
- **暂不实现** LaTeX 格式转换（`$$...$$` → ```` ```math ... ``` ````）
- **暂不实现** 行间公式插入，仅支持行内公式 `$$...$$`

## Impact

- Affected specs: 无（新功能）
- Affected code:
  - `pubspec.yaml`（添加依赖）
  - `lib/widgets/compose_box.dart`（添加按钮、面板、切换逻辑、插入逻辑）
- 不影响现有的公式渲染能力（`lib/widgets/math_widget.dart` 等）
- 不影响现有的消息发送流程（测试版不做格式转换）

## ADDED Requirements

### Requirement: MathLive 数学公式编辑面板

系统 SHALL 在 ComposeBox 操作按钮行添加一个 [⌨️] 切换按钮，点击后显示/隐藏 MathLive 编辑面板。

#### Scenario: 打开数学面板
- **WHEN** 用户点击 ComposeBox 操作按钮行的 [⌨️] 按钮
- **THEN** 系统键盘收起（`unfocus()` + `TextInput.hide()`）
- **AND** MathLive 编辑面板在 ComposeBox 下方显示
- **AND** [⌨️] 按钮变为高亮/选中态

#### Scenario: 关闭数学面板并插入公式
- **WHEN** 用户在 `<math-field>` 中编辑公式后，再次点击 [⌨️] 按钮
- **AND** 当前 LaTeX 内容非空
- **THEN** 将 LaTeX 包装为 `$$...$$` 格式
- **AND** 通过 `ComposeContentController.insertionIndex()` 获取光标位置
- **AND** 通过 `value.replaced()` 插入到光标位置
- **AND** MathLive 编辑面板隐藏
- **AND** [⌨️] 按钮恢复正常态
- **AND** 清空内部 LaTeX 状态

#### Scenario: 关闭数学面板但公式为空
- **WHEN** 用户点击 [⌨️] 按钮关闭面板
- **AND** 当前 LaTeX 内容为空（或仅空白字符）
- **THEN** 不插入任何内容
- **AND** MathLive 编辑面板隐藏

### Requirement: 系统键盘与数学面板互斥

系统 SHALL 确保系统键盘与 MathLive 数学面板互斥显示。

#### Scenario: 数学面板打开时点击内容输入框
- **WHEN** 数学面板处于显示状态
- **AND** 用户点击内容输入框（`_ContentInput`）
- **THEN** 数学面板关闭
- **AND** 系统键盘弹出

#### Scenario: 打开数学面板时收起系统键盘
- **WHEN** 用户点击 [⌨️] 按钮打开数学面板
- **THEN** 调用 `FocusScope.of(context).unfocus()`
- **AND** 调用 `SystemChannels.textInput.invokeMethod('TextInput.hide')`

### Requirement: LaTeX 实时同步

系统 SHALL 通过 `MathLiveEmbeddedEditor` 的 `onLatexChanged` 回调实时接收 LaTeX 内容。

#### Scenario: 用户在 math-field 中编辑
- **WHEN** 用户在 `<math-field>` 中通过虚拟键盘编辑公式
- **THEN** `onLatexChanged` 回调被触发（带 debounce）
- **AND** ComposeBox 状态持有最新的 LaTeX 字符串

### Requirement: 仅支持行内公式插入

测试版 SHALL 仅支持行内公式 `$$...$$` 格式插入，不支持行间公式。

#### Scenario: 插入行内公式
- **WHEN** 关闭数学面板时
- **AND** LaTeX 内容为 `x = \frac{-b \pm \sqrt{b^2-4ac}}{2a}`
- **THEN** 插入到内容输入框的文本为 `$$x = \frac{-b \pm \sqrt{b^2-4ac}}{2a}$$`

## SKIPPED Requirements（测试版暂不实现）

### Requirement: LaTeX 格式转换（发送时）

**状态**：测试版跳过，留到后续版本实现。

**原计划**：发送消息时将 `$$...$$` 转为 ```` ```math ... ``` ```` 格式以适配 Zulip 服务器。

**测试版行为**：发送时保持 `$$...$$` 格式不变。

### Requirement: 行间公式插入

**状态**：测试版跳过，留到后续版本实现。

**原计划**：通过 Shift + [return] 插入 ```` ```math ... ``` ```` 格式。

**测试版行为**：仅支持行内公式 `$$...$$`。

### Requirement: 暗色模式适配

**状态**：测试版阶段三（可选）。

**原计划**：`MathLiveEmbeddedEditor` 的 `isDark` 参数与 Zulip 主题同步。

### Requirement: 边界场景完善

**状态**：测试版阶段三（可选）。

**原计划**：处理编辑消息模式、切换话题、页面失去焦点等边界场景。
