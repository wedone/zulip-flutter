# MathLive 内联面板重构（v2）Spec

## Why

v1 集成通过 `mathlive_studio` 中介包引入 MathLive，并以全屏 `MathLiveEditorPage` 方式打开编辑器。该方案存在三个问题：

1. 中介包环节多余，mathlive TS 源码修改后需要同步到包再同步到 zulip-flutter
2. 全屏编辑器体验割裂，用户需要在独立页面和聊天输入框之间切换
3. `mathlive_studio` 包使用 MathLive 0.110.0 官方构建，本地 mathlive 仓库已有定制（scrollable-keyboard UI）难以同步

本次重构去掉中介包，并将交互模式改为底部内联面板（类似"切换输入法"的体验）。

## What Changes

### 架构层
- 移除 `packages/mathlive_studio/` 中介包，将 Dart 胶水代码直接收入 `lib/mathlive/`
- MathLive JS/HTML/字体资源直接放在 `assets/mathlive/`
- `pubspec.yaml` 移除 `path: packages/mathlive_studio` 依赖，改为直接声明 `webview_flutter` 系列依赖和 assets

### 交互层
- **BREAKING** 移除全屏 `MathLiveEditorPage`（基于 Navigator.push 的独立页面）
- 新增 `MathFormulaPanel`：底部升起的内联公式编辑面板
- compose_box 中的 📐 按钮不再触发 Navigator.push，改为控制面板的显示/隐藏
- 📐 按钮保留原数学键盘图标，位置在「发送」按钮前
- 移除 `LatexPreviewArea`（自制键盘遗留，不再需要）

### 资源层
- `mathlive_editor.html` 基于 `/mnt/d/vc/mathlive/examples/scrollable-keyboard/index.html` 重写
  - 去除全屏样式
  - 嵌入自定义虚拟键盘布局（基本/符号/希腊 三 tab）
  - 固定行保留方向键、退格、完成按钮
- `mathlive.min.js` 替换为本地 mathlive 仓库的定制构建产物
- 添加同步脚本 `tools/sync_mathlive_assets.sh`，从本地 mathlive 仓库一键同步资源

### 交互细节
- 面板打开时机：点击 📐 按钮 / 双击 TextField 中 `\(...\)` 公式区域
- 面板关闭时机：点击「完成」/ 点击面板外部 / 再次点击 📐 按钮
- 面板升起时隐藏系统键盘，面板收起后恢复系统键盘
- 编辑完成时 LaTeX 自动用 `\(...\)` 包裹后插入 TextField 光标位置

## Impact

- **Affected specs**:
  - `integrate-wysiwyg-math-editor`（v1 方案，本次重构其成果）
  - `localize-mathlive-assets`（本地资源方案，本次扩展为直接集成）
  - `add-math-input-features`（旧自制键盘，已被 v1 移除）
- **Affected code**:
  - `packages/mathlive_studio/`（整个目录删除）
  - `lib/widgets/compose_box.dart`（集成内联面板）
  - `lib/widgets/visual_math_editor/math_editor_service.dart`（移除 Navigator.push 逻辑）
  - `lib/widgets/visual_math_editor/visual_math_button.dart`（按钮图标和位置）
  - `pubspec.yaml`（依赖调整）
  - 新增 `lib/widgets/math_formula_panel/`
  - 新增 `lib/mathlive/`（原包代码搬入）
  - 新增 `assets/mathlive/`（原包 assets 搬入）

## ADDED Requirements

### Requirement: 直接集成 MathLive（无中介包）

系统 SHALL 将 MathLive 的 Dart 胶水代码作为 zulip-flutter 主项目的一部分（`lib/mathlive/`），不通过任何 Flutter 包依赖引入。

#### Scenario: 编译时无中介包依赖
- **WHEN** 执行 `flutter pub get`
- **THEN** `pubspec.yaml` 不包含 `mathlive_studio` 或 `flutter_mathlive_mixed` 依赖
- **AND** `pubspec.lock` 中不存在这两个包

#### Scenario: mathlive 资源直接来自主项目 assets
- **WHEN** WebView 加载 MathLive 编辑器
- **THEN** JS/CSS/字体资源从 `assets/mathlive/` 加载
- **AND** 不再从 `packages/mathlive_studio/assets/` 加载

### Requirement: MathFormulaPanel 内联编辑面板

系统 SHALL 提供一个底部升起的内联公式编辑面板 `MathFormulaPanel`，替代全屏 `MathLiveEditorPage`。

#### Scenario: 用户点击 📐 按钮打开面板
- **WHEN** 用户在 compose_box 中点击 📐 按钮
- **THEN** 系统键盘收起
- **AND** `MathFormulaPanel` 从底部升起显示
- **AND** 面板内 `math-field` 自动获得焦点
- **AND** 面板内虚拟键盘显示（默认「基本」tab）

#### Scenario: 用户点击「完成」关闭面板
- **WHEN** 面板处于打开状态且用户点击「完成」按钮
- **THEN** 面板收起
- **AND** math-field 中的 LaTeX 用 `\(...\)` 包裹后插入到 TextField 当前光标位置
- **AND** 光标移动到插入内容之后
- **AND** 系统键盘恢复可用

#### Scenario: 用户点击面板外部关闭
- **WHEN** 面板处于打开状态且用户点击面板外部区域
- **THEN** 行为同点击「完成」（LaTeX 自动填入光标，面板收起）

#### Scenario: 用户再次点击 📐 按钮关闭面板
- **WHEN** 面板处于打开状态且用户再次点击 📐 按钮
- **THEN** 行为同点击「完成」

### Requirement: 双击编辑已有公式

系统 SHALL 支持用户双击 TextField 中 `\(...\)` 包裹的公式区域，打开面板并加载该公式。

#### Scenario: 双击公式进入编辑
- **WHEN** 用户双击 TextField 中 `\(...\)` 区域
- **THEN** 面板打开
- **AND** math-field 加载该公式的 LaTeX 内容（不含界定符）
- **AND** 用户编辑完成后，原公式区域被新 LaTeX（含 `\(...\)` 包裹）替换

### Requirement: 自定义虚拟键盘布局

`mathlive_editor.html` 中的虚拟键盘 SHALL 使用自定义布局，包含三个 tab：「基本」「符号」「希腊」。

#### Scenario: 切换 tab
- **WHEN** 用户点击 tab 标签
- **THEN** 键盘显示对应分类的按键
- **AND** 当前 tab 高亮

#### Scenario: 固定行始终可见
- **WHEN** 任意 tab 显示
- **THEN** 底部固定行（方向键、退格、运算符、完成按钮）始终可见
- **AND** 「完成」按钮位于固定行右下

### Requirement: mathlive 资源同步脚本

系统 SHALL 提供脚本 `tools/sync_mathlive_assets.sh`，从本地 mathlive 仓库一键同步构建产物到 zulip-flutter 的 assets 目录。

#### Scenario: 执行同步
- **WHEN** 开发者执行 `bash tools/sync_mathlive_assets.sh`
- **THEN** 脚本从 `/mnt/d/vc/mathlive/dist/` 复制 `mathlive.min.js` 和 `mathlive-static.css` 到 `assets/mathlive/`
- **AND** 脚本从 `/mnt/d/vc/mathlive/examples/scrollable-keyboard/index.html` 不复制（HTML 由 zulip-flutter 端维护定制版）
- **AND** 输出同步结果摘要

### Requirement: 📐 按钮保留原数学键盘图标

compose_box 中的 📐 按钮 SHALL 使用与原自制数学键盘相同的图标，位置位于「发送」按钮之前。

#### Scenario: 按钮图标和位置
- **WHEN** compose_box 渲染输入工具栏
- **THEN** 📐 按钮显示原数学键盘的图标（`Icons.functions` 或其他原用图标）
- **AND** 📐 按钮位于「发送」按钮之前

## MODIFIED Requirements

### Requirement: MathLive 编辑器入口

[原 v1 方案：通过 `MathLiveEditorPage.open()` 全屏打开]

[本次修改为：通过 `MathFormulaPanel` 内联面板打开，无 Navigator.push]

## REMOVED Requirements

### Requirement: MathLiveEditorPage 全屏编辑器

**Reason**: 全屏页面交互割裂，改为内联面板
**Migration**: compose_box 中所有 `MathLiveEditorPage.open()` 调用替换为 `MathFormulaPanel` 的显示控制

### Requirement: LatexPreviewArea 实时预览区域

**Reason**: 自制数学键盘遗留功能，MathLive 的 WYSIWYG 编辑已提供实时渲染
**Migration**: 直接删除相关代码和组件

### Requirement: mathlive_studio Flutter 包

**Reason**: 自用项目不需要中介包环节
**Migration**: 包代码搬到 `lib/mathlive/`，包 assets 搬到 `assets/mathlive/`，删除 `packages/mathlive_studio/` 目录
