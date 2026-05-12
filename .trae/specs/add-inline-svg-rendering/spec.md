# 内联 SVG 图形渲染 Spec

## Why

Zulip 服务端出于 XSS 安全考虑，不允许 `<svg>` 标签在消息 HTML 中渲染，SVG 代码以转义纯文本形式（`&lt;svg&gt;...&lt;/svg&gt;`）保留在消息中。客户端已引入 `flutter_svg`，可以识别消息文本中的 SVG 代码并用 `flutter_svg` 渲染为图形，提升用户体验。

## What Changes

- 在 HTML 解析层识别文本节点中的 `<svg...>...</svg>` 模式
- 新增 `InlineSvgNode` 节点类型，存储 SVG 代码字符串
- 新增 `InlineSvgWidget` 组件，使用 `SvgPicture.string()` 渲染 SVG
- SVG 尺寸策略：优先使用 SVG 自身尺寸，设置最大尺寸约束避免撑满屏幕

## Impact

- Affected code:
  - `lib/model/content.dart` — 新增 `InlineSvgNode`，修改文本解析逻辑
  - `lib/widgets/content.dart` — 新增 `InlineSvgWidget` 渲染
  - `test/model/content_test.dart` — 新增测试
  - `test/widgets/content_test.dart` — 新增测试

## ADDED Requirements

### Requirement: 识别文本中的 SVG 代码

系统 SHALL 在解析消息 HTML 时，检测文本节点中是否包含 `<svg` 开头、`</svg>` 结尾的 SVG 代码模式。

#### Scenario: 文本中包含完整 SVG 代码
- **WHEN** 消息文本节点包含 `<svg xmlns="http://www.w3.org/2000/svg">...</svg>`
- **THEN** 系统提取 SVG 代码字符串，创建 `InlineSvgNode`

#### Scenario: 文本中不包含 SVG 代码
- **WHEN** 消息文本节点是普通文本
- **THEN** 系统按现有逻辑创建 `TextNode`

#### Scenario: 文本中 SVG 代码不完整
- **WHEN** 文本中有 `<svg` 但没有对应的 `</svg>`
- **THEN** 系统按现有逻辑创建 `TextNode`，不尝试渲染 SVG

### Requirement: SVG 图形渲染 Widget

系统 SHALL 提供 `InlineSvgWidget` 组件，使用 `flutter_svg` 渲染 SVG 代码。

#### Scenario: 正常渲染
- **WHEN** SVG 代码有效且可解析
- **THEN** 系统使用 `SvgPicture.string()` 渲染

#### Scenario: SVG 解析失败
- **WHEN** SVG 代码无效或 `flutter_svg` 无法解析
- **THEN** 系统降级显示 SVG 源码纯文本

### Requirement: SVG 渲染尺寸策略

系统 SHALL 对 SVG 渲染设置尺寸约束，优先使用 SVG 自身尺寸，但不超过最大限制。

#### Scenario: SVG 有自身尺寸（width/height 属性）
- **WHEN** SVG 代码包含 `width="240" height="200"` 等尺寸属性
- **THEN** 系统优先使用 SVG 自身尺寸渲染，但不超过最大尺寸约束（高度 ≤ 10em，宽度 ≤ 屏幕宽度）

#### Scenario: SVG 仅有 viewBox 无 width/height
- **WHEN** SVG 代码包含 `viewBox` 但无 `width`/`height` 属性
- **THEN** 系统在最大尺寸约束内按 viewBox 比例渲染

#### Scenario: SVG 既无尺寸也无 viewBox
- **WHEN** SVG 代码无 `width`/`height`/`viewBox`
- **THEN** 系统使用默认尺寸约束渲染
