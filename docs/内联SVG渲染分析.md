# 内联 SVG 渲染分析

## 需求

用户在消息中直接输入 `<svg>...</svg>` 原文（非代码块包裹），客户端将其渲染为图形。
其他人发来的 `<svg>...</svg>` 消息，客户端同样渲染为图形。

## 消息传输链路

### 发送方输入

客户端不做任何转义，直接将原始文本发给服务器。

### 服务端处理

Zulip 服务端**禁用了 Python-Markdown 的 HTML 处理器**（标记为 insecure），不渲染任何原始 HTML 标签：

- `html_block` 预处理器 → 已禁用
- `html` 行内处理器 → 已禁用
- `<svg>` 标签被当作普通文本，由 ElementTree 序列化时自动转义

用户输入 `<svg width="240">...</svg>` → 服务端输出 HTML：

```html
<p>&lt;svg width=&quot;240&quot;&gt;...&lt;/svg&gt;</p>
```

### 客户端接收

`package:html` 的 `HtmlParser` 自动反转义 HTML 实体：

```
API 返回: <p>&lt;svg width=&quot;240&quot;&gt;...&lt;/svg&gt;</p>
    ↓ HtmlParser 解析
DOM 树: <p> → dom.Text(.text = '<svg width="240">...</svg>')
    ↓ parseInlineContentList 中 _svgPattern.allMatches
匹配成功 → 分割为 TextNode + InlineSvgNode + TextNode
    ↓ InlineSvgWidget
SvgPicture.string(svgSource, errorBuilder: 降级为纯文本) → 渲染图形
```

## 当前实现状态

### 已完成

| 功能 | 文件 | 说明 |
|------|------|------|
| SVG 正则检测 | `lib/model/content.dart` | `_svgPattern = RegExp(r'<svg\b[^>]*>.*?</svg>', dotAll: true)` |
| InlineSvgNode | `lib/model/content.dart` | 存储 SVG 源码字符串 |
| 文本节点 SVG 识别与分割 | `lib/model/content.dart` | `parseInlineContentList` 中用 `allMatches` 分割文本为 TextNode + InlineSvgNode + TextNode |
| InlineSvgWidget | `lib/widgets/content.dart` | 使用 `SvgPicture.string()` 渲染，含 `errorBuilder` 降级 |
| 尺寸约束 | `lib/widgets/content.dart` | `maxHeight: fontSize * 10`（10em）、`maxWidth: screenWidth` |
| Widget 集成 | `lib/widgets/content.dart` | `InlineSvgNode` case 返回 `WidgetSpan` |
| SVG 解析失败降级 | `lib/widgets/content.dart` | `errorBuilder` 回调降级为 `Text(svgSource)` 纯文本 |

### 已修复的 Bug

#### Bug 1（已修复）：SVG 前后有其他文字时，整个文本被当作 SVG 源码

**修复方式**：将 SVG 检测逻辑从 `parseInlineContent` 移至 `parseInlineContentList`，使用 `_svgPattern.allMatches` 遍历所有匹配，将文本分割为 `TextNode + InlineSvgNode + TextNode` 序列。

例如消息 `看这个图 <svg>...</svg> 怎么样` 会被解析为：
- `TextNode("看这个图 ")`
- `InlineSvgNode(svgSource: "<svg>...</svg>")`
- `TextNode(" 怎么样")`

#### Bug 2（已修复）：SVG 解析失败时无降级处理

**修复方式**：在 `SvgPicture.string()` 中添加 `errorBuilder` 参数，当 SVG 解析失败时降级显示 SVG 源码纯文本。

```dart
SvgPicture.string(
  node.svgSource,
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) =>
    Text(node.svgSource, style: ambientTextStyle),
)
```

`errorBuilder` 是 flutter_svg 2.0.17+ 提供的 API，项目使用 2.0.33，可直接使用。

### 测试缺失

- `test/model/content_test.dart` — 无 `InlineSvgNode` 相关测试
- `test/widgets/content_test.dart` — 无 `InlineSvgWidget` 相关测试

## Outbox 阶段（本地回显）说明

客户端使用 Outbox 机制做乐观更新：

1. 用户点击发送 → 输入框立即清空
2. 创建 `OutboxMessage`（状态 hidden），500ms 内不可见
3. 500ms 后服务器还没响应 → 状态变为 waiting，消息显示为**纯 Markdown 文本**
4. 服务器 `MessageEvent` 到达 → OutboxMessage 被删除，替换为正式消息（含 `rendered_content` HTML）

**关键点**：Outbox 阶段不做任何格式渲染，`<svg>...</svg>` 显示为纯文本。这是因为客户端没有 Markdown 渲染器，所有格式渲染依赖服务器的 `rendered_content`。经确认，未连接服务器时发送按钮不可用，因此 Outbox 阶段的纯文本显示不构成实际问题。

## 安全性

- 服务端禁用 HTML 渲染，SVG 标签被转义为文本，不存在 XSS 风险
- 客户端信任服务端已净化内容，直接用 `flutter_svg` 渲染
- `flutter_svg` 不支持 JavaScript 执行，SVG 中的 `<script>` 等标签被忽略
- SVG 文件上传被服务端禁止（`image/svg+xml` 不在 `INLINE_MIME_TYPES` 中）

## 与 KaTeX 渲染的对比

| 方面 | KaTeX/LaTeX | SVG |
|------|-------------|-----|
| 服务端输出 | `<span class="katex">` HTML | `&lt;svg&gt;...&lt;/svg&gt;` 转义文本 |
| 客户端解析 | `parseMath` 提取 TeX 源码 | `_svgPattern` 提取 SVG 代码 |
| 客户端渲染 | `flutter_math_fork` 渲染 TeX | `flutter_svg` 渲染 SVG |
| Outbox 阶段 | 显示原始 LaTeX 文本 | 显示原始 SVG 文本 |
