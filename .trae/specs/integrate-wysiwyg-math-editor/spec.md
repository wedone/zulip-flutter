# 所见即所得（WYSIWYG）公式编辑集成 Spec

## Why

zulip-flutter 当前的数学公式输入依赖 fork 自定义的数学键盘工具栏，用户只能输入 LaTeX 代码无法实时看到渲染效果。引入 MathLive WYSIWYG 编辑器可以让用户在可视化界面中编辑公式（编辑即预览），完成后自动生成 LaTeX 代码插入到输入框，降低使用门槛并提升体验。

## What Changes

* **BREAKING**：移除 fork 自定义的数学键盘工具栏（`lib/widgets/math_keyboard/` 目录及 `compose_box.dart` 中所有 `mathKeyboardToolbarVisible` 相关逻辑）

* 新增 `flutter_mathlive_mixed` 依赖（path dependency），引入 MathLive WYSIWYG 编辑器

* 本地打包 MathLive 0.110.0 资源（JS/CSS），替换 CDN 加载（解决国内网络延迟和安全问题）

* 升级 MathLive 从 0.101.2 → 0.110.0（XSS 安全修复）

* 在 `compose_box` 输入工具栏中新增「📐 可视公式」按钮，替代原数学键盘按钮

* 实现「点击按钮 → 弹窗 WYSIWYG 编辑 → Insert → LaTeX 插入 TextField 光标位置」完整流程

* WebView 预加载优化（第二阶段）

* 编辑已有公式功能（第三阶段）

## Impact

* Affected code:

  * `lib/widgets/compose_box.dart` — 移除数学键盘状态，新增可视公式按钮

  * `lib/widgets/math_keyboard/` — 整个目录删除

  * `lib/widgets/visual_math_editor/` — 新增目录

  * `pubspec.yaml` — 新增 `flutter_mathlive_mixed` 依赖

  * `flutter_mathlive_mixed` 包（本地 path dependency）— 修改 HTML 资源引用为本地路径

* 保留不变：

  * `lib/model/latex_converter.dart` — LaTeX 界定符转换逻辑

  * `lib/widgets/latex_preview.dart` — flutter\_math\_fork 预览渲染

  * TextField 纯文本输入和发送流程

## ADDED Requirements

### Requirement: WYSIWYG 公式编辑器

系统应提供所见即所得的数学公式编辑功能，用户在可视化界面中编辑公式时实时看到渲染效果。

#### Scenario: 打开编辑器

* **WHEN** 用户在 compose\_box 中点击「📐 可视公式」按钮

* **THEN** 全屏弹出 `MathLiveEditorPage`，包含 `<math-field>` 编辑区域和 `<math-virtual-keyboard>` 虚拟键盘

* **AND** 虚拟键盘替代系统键盘，用户无需切换系统输入法

#### Scenario: 编辑并插入公式

* **WHEN** 用户在 WYSIWYG 编辑器中完成公式编辑并点击「Insert」

* **THEN** 编辑器返回 LaTeX 代码（如 `A = \pi r^2`）

* **AND** 该 LaTeX 代码被 `\(` 和 `\)` 界定符包裹后插入到 TextField 的当前光标位置

* **AND** 光标移动到插入内容之后

#### Scenario: 取消编辑

* **WHEN** 用户点击返回按钮而非 Insert

* **THEN** 编辑器关闭，返回 `null`，TextField 内容不变

### Requirement: 本地 MathLive 资源加载

系统应从本地 assets 加载 MathLive JS/CSS 资源，不依赖 CDN。

#### Scenario: 离线加载

* **WHEN** 设备无网络连接时打开编辑器

* **THEN** MathLive 编辑器仍能正常加载和使用（JS/CSS 从本地读取）

### Requirement: WebView 预加载

系统应在 compose\_box 初始化时后台预加载 MathLive WebView，用户点击按钮时实现秒开。

#### Scenario: 预加载后打开

* **WHEN** compose\_box 初始化完成且用户随后点击「📐 可视公式」

* **THEN** 编辑器利用预加载的 WebView 几乎无延迟地显示

### Requirement: 编辑已有公式

系统应支持用户编辑 TextField 中已存在的 LaTeX 公式。

#### Scenario: 光标在公式内时打开编辑器

* **WHEN** 用户将光标定位在 `\(...\)` 包裹的公式区域内并点击「📐」

* **THEN** 编辑器以该公式的 LaTeX 内容作为初始值打开

* **AND** 用户编辑后点击 Insert，原有公式被替换为新内容

## REMOVED Requirements

### Requirement: Flutter 原生数学键盘工具栏

**Reason**: 用 MathLive virtual keyboard 完全替换，减少维护成本，实现 WYSIWYG 编辑
**Migration**:

* 删除 `lib/widgets/math_keyboard/` 目录（3 个文件）

* 移除 `compose_box.dart` 中 `mathKeyboardToolbarVisible` 状态、`_toggleMathKeyboardToolbar` 方法、`MathKeyboardButton` 引用、`readOnly: mathKeyboardToolbarVisible` 配置

* 原「数学键盘」按钮位置由「📐 可视公式」按钮替代

* 「最近使用」功能不迁移（不需要）

