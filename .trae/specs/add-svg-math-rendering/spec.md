# KaTeX 公式 SVG 渲染方案 Spec

## Why

zulip-flutter 当前采用"解析 KaTeX HTML span/CSS 树 → Flutter Widget 重建"的方式渲染数学公式，需要手动实现 40+ CSS 类的映射，维护成本极高，且 Android 上 KaTeX_Math 斜体字体存在 Flutter 引擎 bug（flutter#167474）。若客户端能将 TeX 源码转为 SVG 渲染，可彻底绕过 CSS 解析层，获得与 Web 端一致的渲染质量。

## What Changes

- 添加 `flutter_svg` 依赖，提供运行时 SVG 渲染能力
- 添加 `flutter_tex` 依赖，提供 TeX → SVG 本地转换能力（基于 MathJax）
- 新建 `SvgMathWidget` 组件，替代现有 `KatexWidget` 渲染数学公式
- 修改 `MathBlock` / `MathInline` 的渲染逻辑，使用 SVG 方案
- 简化 `lib/model/katex.dart`，仅保留 TeX 源码提取，移除 CSS 解析代码
- 简化 `MathNode`，移除 `nodes` 字段（不再需要 KaTeX 节点树）
- 移除 21 个 KaTeX 字体文件及 `pubspec.yaml` 中的字体声明
- 实现 TeX → SVG 结果缓存（LRU 缓存，以 TeX 源码为 key）
- 保留现有 `KatexWidget` 作为可选回退方案

## Impact

- Affected specs: 消息内容渲染系统、KaTeX 解析系统
- Affected code:
  - `lib/model/katex.dart` — 大幅简化，仅保留 TeX 源码提取
  - `lib/model/content.dart` — `MathNode.nodes` 字段可移除
  - `lib/widgets/katex.dart` — 替换为 SVG 渲染
  - `lib/widgets/content.dart` — `MathBlock` / `MathInline` 改用 SVG
  - `pubspec.yaml` — 添加 `flutter_svg`、`flutter_tex` 依赖，移除 KaTeX 字体声明
  - `assets/KaTeX/*.ttf` — 21 个字体文件可移除
  - `test/model/katex_test.dart` — 需要更新测试
  - `test/widgets/katex_test.dart` — 需要更新测试

## ADDED Requirements

### Requirement: SVG 运行时渲染能力

系统 SHALL 提供运行时 SVG 渲染能力，通过 `flutter_svg` 库解析 SVG XML 并渲染为 Flutter Widget。

#### Scenario: 从 SVG 字符串渲染
- **WHEN** 提供 SVG 字符串内容
- **THEN** 系统使用 `SvgPicture.string()` 渲染为 Flutter Widget

#### Scenario: 使用 raster 渲染策略
- **WHEN** 渲染不频繁变化的 SVG（如数学公式）
- **THEN** 系统使用 `RenderStrategy.raster` 策略，首次解析后光栅化缓存，后续帧零开销

### Requirement: TeX → SVG 本地转换

系统 SHALL 在客户端本地将 TeX 源码转换为 SVG，无需网络请求。

#### Scenario: 行内公式转换
- **WHEN** 收到行内数学公式的 TeX 源码（如 `E=mc^2`）
- **THEN** 系统通过 MathJax 引擎将 TeX 转为 SVG 字符串，使用 text 模式

#### Scenario: 块级公式转换
- **WHEN** 收到块级数学公式的 TeX 源码（如 `\int_0^1 x dx`）
- **THEN** 系统通过 MathJax 引擎将 TeX 转为 SVG 字符串，使用 display 模式

### Requirement: TeX → SVG 结果缓存

系统 SHALL 缓存 TeX → SVG 的转换结果，避免重复计算。

#### Scenario: 相同公式重复出现
- **WHEN** 同一 TeX 源码在多条消息中重复出现
- **THEN** 系统直接从缓存中获取 SVG 字符串，不再重新执行 TeX → SVG 转换

#### Scenario: 缓存容量限制
- **WHEN** 缓存条目数超过上限
- **THEN** 系统使用 LRU 策略淘汰最久未使用的缓存条目

### Requirement: SVG 数学公式渲染 Widget

系统 SHALL 提供 `SvgMathWidget` 组件，用于渲染数学公式的 SVG 输出。

#### Scenario: 正常渲染
- **WHEN** TeX 源码成功转换为 SVG
- **THEN** 系统使用 `SvgPicture.string()` + `RenderStrategy.raster` 渲染 SVG，并用 `RepaintBoundary` 隔离重绘

#### Scenario: 转换失败回退
- **WHEN** TeX → SVG 转换失败
- **THEN** 系统降级显示 TeX 源码纯文本

### Requirement: KaTeX HTML 解析简化

系统 SHALL 简化 KaTeX HTML 解析器，仅提取 TeX 源码，不再解析 `katex-html` span/CSS 树。

#### Scenario: 提取 TeX 源码
- **WHEN** 收到服务端输出的 KaTeX HTML
- **THEN** 系统仅从 `<annotation encoding="application/x-tex">` 中提取 TeX 源码

#### Scenario: 移除 CSS 解析
- **WHEN** SVG 方案完全生效后
- **THEN** `_KatexParser` 及其 800+ 行 CSS 解析代码、`KatexNode` / `KatexSpanNode` / `KatexStrutNode` 等节点类型、`KatexSpanStyles` 等样式类型 SHALL 被移除

## MODIFIED Requirements

### Requirement: MathBlock 渲染

`MathBlock` Widget SHALL 使用 SVG 方案渲染块级数学公式。

- **修改前**：解析 `katex-html` span/CSS 树 → `KatexWidget` 渲染
- **修改后**：提取 TeX 源码 → 本地 MathJax 生成 SVG → `SvgPicture.string()` 渲染
- 保留水平滚动支持（`SingleChildScrollViewWithScrollbar`）
- 保留居中布局（`Center`）
- 保留 LTR 方向（`Directionality`）

### Requirement: MathInline 渲染

`MathInline` SHALL 使用 SVG 方案渲染行内数学公式。

- **修改前**：`KatexWidget` 嵌入 `WidgetSpan`
- **修改后**：`SvgMathWidget` 嵌入 `WidgetSpan`
- 保留 `PlaceholderAlignment.baseline` + `TextBaseline.alphabetic` 对齐方式

### Requirement: MathNode 数据模型

`MathNode` SHALL 简化数据结构。

- **修改前**：包含 `texSource`、`nodes`（`List<KatexNode>?`）、`debugHardFailReason`、`debugSoftFailReason`
- **修改后**：仅保留 `texSource`，移除 `nodes`、`debugHardFailReason`、`debugSoftFailReason`

## REMOVED Requirements

### Requirement: KaTeX CSS 解析

**Reason**: SVG 方案不再需要解析 KaTeX HTML span/CSS 树，TeX 源码提取后直接通过 MathJax 生成 SVG

**Migration**: 以下代码/资源将被移除：
- `_KatexParser` 类及其全部方法（约 800 行）
- `KatexSpanNode`、`KatexStrutNode`、`KatexVlistNode`、`KatexNegativeMarginNode`、`KatexVlistRowNode` 节点类型
- `KatexSpanStyles`、`KatexSpanFontWeight`、`KatexSpanFontStyle`、`KatexSpanTextAlign`、`KatexSpanPosition`、`KatexSpanColor` 样式类型
- `KatexParserHardFailReason`、`KatexParserSoftFailReason`、`MathParserResult` 类
- `csslib` 依赖（仅用于 KaTeX CSS 解析）
- 21 个 KaTeX 字体文件（`assets/KaTeX/*.ttf`）
- `pubspec.yaml` 中 KaTeX 字体声明
- `KatexWidget` 及其内部组件（`_KatexNodeList`、`_KatexSpan`、`_KatexStrut`、`_KatexVlist`、`_KatexNegativeMargin`、`NegativeLeftOffset`、`RenderNegativePadding`）
