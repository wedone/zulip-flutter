# SVG 运行时渲染能力调研

## 1. 背景

zulip-flutter 当前没有 SVG 运行时渲染能力。项目中的 SVG 文件（`assets/icons/*.svg`）仅在构建时通过 `tools/icons/build-icon-font.js` 转换为 TTF 字体图标（`ZulipIcons.ttf`），运行时通过 `IconData` + `Icon` 组件以字体方式使用，并非 SVG 渲染。

需要 SVG 运行时渲染的两个场景：

1. **KaTeX 数学公式**：当前采用"服务端输出 KaTeX HTML → 客户端解析 HTML span/CSS → Flutter Widget 重建"的架构，需要手动实现 KaTeX CSS 的完整子集，维护成本极高，且 Android 上 KaTeX_Math 斜体字体有 Flutter 引擎 bug（[flutter#167474](https://github.com/flutter/flutter/issues/167474)）。若客户端能将 TeX 源码转为 SVG 渲染，可彻底绕过 CSS 解析层，获得与 Web 端一致的渲染质量。
2. **几何图形**：高中及更广泛数学领域的几何图形（三角形、圆、函数图像、坐标系等），天然适合用 SVG 矢量格式表达。

**约束条件**：服务端不改变，继续输出 KaTeX HTML。

---

## 2. 当前项目 SVG 使用现状

### 2.1 SVG 仅作为构建时资源

```
assets/icons/*.svg  →  build-icon-font.js  →  ZulipIcons.ttf  →  IconData + Icon
```

- 约 60 个 SVG 图标文件，通过 `@vusion/webfonts-generator` 转换为 TTF 字体
- 运行时通过 `ZulipIcons` 类以 `IconData` 方式使用，不涉及 SVG 解析渲染
- 详见 `lib/widgets/icons.dart` 和 `tools/icons/build-icon-font.js`

### 2.2 网络图片不支持 SVG

- 所有网络图片（头像、realm icon、消息内图片等）通过 `Image.network` / `RealmContentNetworkImage` 渲染
- `pubspec.yaml` 中没有 `flutter_svg` 或任何 SVG 渲染库依赖
- 代码中没有 `SvgPicture`、`flutter_svg` 等导入
- Android 原生层也没有 SVG 相关代码

### 2.3 Zulip 服务端禁止 SVG 内容

Zulip 服务端出于 XSS 安全考虑，在 `zerver/lib/mime_types.py` 中明确禁止 `image/svg+xml`：

```python
INLINE_MIME_TYPES = [
    ...
    # To avoid cross-site scripting attacks, DO NOT add types such
    # as application/xhtml+xml, application/x-shockwave-flash,
    # image/svg+xml, text/html, or text/xml.
]
```

自定义 emoji 上传时也会校验 content_type 必须同时属于 `THUMBNAIL_ACCEPT_IMAGE_TYPES` 和 `INLINE_MIME_TYPES`，SVG 会被拒绝。

---

## 3. 服务端输出的 KaTeX HTML 结构

服务端不改变，继续输出 KaTeX HTML。客户端收到的消息 HTML 中，数学公式的结构如下：

### 3.1 行内公式

用户输入 `$$E=mc^2$$`，服务端输出：

```html
<span class="katex">
  <span class="katex-mathml">
    <math xmlns="http://www.w3.org/1998/Math/MathML">
      <semantics>
        <mrow>...</mrow>
        <annotation encoding="application/x-tex">E=mc^2</annotation>
      </semantics>
    </math>
  </span>
  <span class="katex-html" aria-hidden="true">
    <span class="base">
      <span class="strut" style="height:0.4306em;"></span>
      <span class="mord mathnormal">E</span>
      <span class="mspace" style="margin-right:0.2778em;"></span>
      <span class="mrel">=</span>
      ...
    </span>
  </span>
</span>
```

### 3.2 块级公式

用户输入 ` ```math\n\int_0^1 x dx\n``` `，服务端输出：

```html
<p><span class="katex-display"><span class="katex">
  <span class="katex-mathml">...</span>
  <span class="katex-html" aria-hidden="true">...</span>
</span></span></p>
```

### 3.3 关键信息

| 部分 | 内容 | 用途 |
|------|------|------|
| `<span class="katex">` / `<span class="katex-display">` | 公式标识 | 客户端识别公式位置 |
| `<annotation encoding="application/x-tex">` | **原始 TeX 源码** | 客户端可提取，用于本地生成 SVG |
| `<span class="katex-html">` | KaTeX 渲染的 HTML span 树 | 当前 `katex.dart` 解析的部分，SVG 方案中不再需要 |

**核心发现**：服务端输出的 KaTeX HTML 中已包含完整的 TeX 源码（`<annotation encoding="application/x-tex">`），客户端可以直接提取，无需服务端任何改动。

---

## 4. 方案：客户端本地 TeX → SVG 渲染

### 4.1 架构

```
服务端输出 KaTeX HTML（不变）
  → 客户端提取 <annotation> 中的 TeX 源码
  → 客户端本地 MathJax 将 TeX 转为 SVG
  → flutter_svg 渲染 SVG
```

### 4.2 与当前架构对比

| | 当前架构 | SVG 方案 |
|---|---------|---------|
| 服务端输出 | KaTeX HTML | KaTeX HTML（不变） |
| 客户端解析 | 解析 `katex-html` span/CSS 树 | 仅提取 `<annotation>` 中的 TeX 源码 |
| 客户端渲染 | 手动实现 CSS → Flutter Widget 映射 | MathJax 生成 SVG → flutter_svg 渲染 |
| CSS 依赖 | 需手动实现 40+ CSS 类 | 无 CSS 依赖 |
| 字体依赖 | 21 个 KaTeX TTF 字体文件 | 无字体依赖（SVG 自包含字形路径） |
| Android 字体 bug | 受 [flutter#167474](https://github.com/flutter/flutter/issues/167474) 影响 | 不受影响 |
| 维护成本 | 高（跟随 KaTeX CSS 更新） | 低（MathJax SVG 输出稳定） |
| 渲染质量 | 受 CSS 覆盖率限制 | 与 Web 端一致 |

### 4.3 客户端本地 TeX → SVG 的实现方式

需要在客户端集成 MathJax 引擎，将 TeX 源码转为 SVG。可选方案：

| 方案 | 说明 | 优劣 |
|------|------|------|
| `flutter_tex` 包 | 内置 MathJax，提供 `Math2SVG` 组件，纯 Flutter 渲染（无 WebView） | 开箱即用，但包体积增加约 3-5MB |
| 自行集成 MathJax | 将 MathJax JS 文件打包为 asset，通过 `flutter_js` 或 `webview` 执行 | 灵活可控，但集成工作量大 |
| 预编译 MathJax | 将 MathJax 编译为 WASM 或提前加载到 isolate | 性能最优，但工程复杂度高 |

**推荐 `flutter_tex`**：最成熟的开箱即用方案，内部使用 MathJax 生成 SVG 并用纯 Flutter 渲染，无需 WebView。

---

## 5. flutter_svg 库分析

### 5.1 基本信息

| 项目 | 值 |
|------|-----|
| 包名 | `flutter_svg` |
| 版本 | 2.2.3 |
| 维护者 | flutter.dev (Google 官方) |
| pub.dev likes | 5.8k |
| 平台 | Android, iOS, Linux, macOS, Web, Windows |
| 许可证 | BSD-3-Clause |

### 5.2 核心能力

- 运行时解析 SVG XML 并渲染为 Flutter Widget
- 支持从多种来源加载 SVG：
  - `SvgPicture.asset()` — 本地资源文件
  - `SvgPicture.network()` — 网络 URL
  - `SvgPicture.string()` — SVG 字符串（**最适合动态内容**）
  - `SvgPicture.memory()` — 字节数据
- 支持 SVG 核心特性：`<path>`、`<circle>`、`<rect>`、`<line>`、`<polygon>`、`<polyline>`、`<text>`、`<defs>` + `<use>`、`<g>`、`<clipPath>`、`<mask>`、渐变等
- 支持颜色过滤（`colorFilter`）和自定义颜色映射（`colorMapper`）

### 5.3 渲染策略（v2.2+ 新增）

flutter_svg v2.2 引入了渲染策略设置：

| 策略 | 说明 | 适用场景 |
|------|------|---------|
| `picture`（默认） | SVG 解析为 `Picture`，Canvas 矢量绘制 | 需要无损缩放的场景 |
| `raster` | SVG 光栅化为 `Image`，后续帧 `drawImage` | 不频繁变化的 SVG，性能更优 |

对于数学公式和几何图形，`raster` 策略更合适：首次解析后光栅化缓存，后续帧零开销。

### 5.4 性能特征

- **首次渲染**：需要解析 SVG XML → 构建 Drawable 树 → Canvas 绘制，有运行时开销
- **后续渲染**：`picture` 模式下 `Picture` 可缓存复用；`raster` 模式下光栅化后性能极佳
- **复杂 SVG**：路径节点多、图层叠加多的 SVG 解析和光栅化耗时更长
- **优化手段**：
  - `precachePicture()` 预加载
  - `RepaintBoundary` 隔离重绘
  - `raster` 渲染策略
  - 自定义 LRU 缓存避免重复解析

### 5.5 针对目标场景的 SVG 特性覆盖

| SVG 特性 | 数学公式需要 | 几何图形需要 | flutter_svg 支持 |
|----------|-------------|-------------|-----------------|
| `<path>` 贝塞尔曲线 | ✅ 字形路径 | ✅ 曲线 | ✅ |
| `<defs>` + `<use>` 引用 | ✅ 字形复用 | — | ✅ |
| `<line>` | — | ✅ 坐标轴 | ✅ |
| `<circle>` | — | ✅ 圆 | ✅ |
| `<rect>` | — | ✅ 矩形 | ✅ |
| `<polygon>` | — | ✅ 多边形 | ✅ |
| `<text>` | — | ✅ 标注 | ✅ |
| `<g>` 分组 | ✅ | ✅ | ✅ |
| `stroke` / `fill` | ✅ | ✅ | ✅ |
| `stroke-dasharray` | — | ✅ 虚线 | ✅ |
| `transform` | ✅ | ✅ | ✅ |
| `viewBox` | ✅ | ✅ | ✅ |
| 滤镜 (`<filter>`) | ❌ | ❌ | ⚠️ 部分支持 |
| 动画 (`<animate>`) | ❌ | ❌ | ❌ |
| CSS `<style>` | ❌ | ❌ | ⚠️ 有限支持 |

数学公式和几何图形所需的 SVG 特性，flutter_svg **完全覆盖**。

---

## 6. 实施方案

### 6.1 添加依赖

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  flutter_svg: ^2.2.3
  flutter_tex: ^5.2.5   # TeX → SVG 本地渲染
```

### 6.2 KaTeX 公式 SVG 渲染

服务端不变，客户端从 KaTeX HTML 中提取 TeX 源码，本地生成 SVG 并渲染：

```dart
import 'package:flutter_svg/flutter_svg.dart';

Widget buildMathBlock(String texSource, {bool displayMode = true}) {
  // 方式一：使用 flutter_tex 的 Math2SVG 组件
  // Math2SVG 内部调用 MathJax 生成 SVG，再用 flutter_svg 渲染
  return Math2SVG(
    math: texSource,
    mathStyle: displayMode ? MathStyle.display : MathStyle.text,
  );

  // 方式二：如果自行管理 TeX → SVG 转换
  // final svgString = await texToSvg(texSource, displayMode: displayMode);
  // return SvgPicture.string(
  //   svgString,
  //   renderStrategy: RenderStrategy.raster,
  //   fit: BoxFit.contain,
  // );
}
```

### 6.3 几何图形 SVG 渲染

几何图形 SVG 可来自服务端生成或客户端根据参数动态构建：

```dart
Widget buildGeometryFigure(String svgString) {
  return SvgPicture.string(
    svgString,
    renderStrategy: RenderStrategy.raster,
    fit: BoxFit.contain,
  );
}
```

### 6.4 katex.dart 简化

采用 SVG 方案后，`katex.dart` 中的 CSS 解析代码可以大幅简化：

| 代码 | 变更 |
|------|------|
| `_KatexParser` 及其 800+ 行 CSS 解析代码 | 可移除 |
| `KatexNode` / `KatexSpanNode` / `KatexStrutNode` 等 | 可移除 |
| `KatexSpanStyles` / `fontSizeEm` / `verticalAlignEm` 等 | 可移除 |
| TeX 源码提取逻辑（`<annotation>` 解析） | 保留 |
| `MathNode` 的 `texSource` 字段 | 保留 |
| `MathNode` 的 `nodes` 字段 | 可移除 |

### 6.5 性能优化建议

1. **使用 `raster` 渲染策略**：数学公式和几何图形一旦渲染完成不再变化，光栅化后缓存可大幅提升滚动性能
2. **SVG 缓存层**：同一公式可能在多条消息中重复出现，建立 LRU 缓存避免重复解析
3. **`precachePicture()` 预加载**：在消息列表加载时预缓存即将可见的 SVG
4. **`RepaintBoundary` 隔离**：防止 SVG 重绘波及父 Widget
5. **TeX → SVG 结果缓存**：同一 TeX 源码的 SVG 输出只需生成一次，以 TeX 源码为 key 缓存 SVG 字符串

### 6.6 回退策略

- SVG 渲染失败时，降级显示 TeX 源码（当前方案中不支持的 CSS 类也是这个回退行为）
- 可保留现有 `KatexWidget` 作为可选回退，但长期目标是完全移除

### 6.7 安全考量

- SVG 内容由客户端本地 MathJax 生成，不接受外部 SVG 输入，无 XSS 风险
- `flutter_svg` 不执行 SVG 中的 JavaScript（本身就不支持）
- 几何图形 SVG 如果来自服务端，需确保来源可信

---

## 7. 关键文件索引

### 客户端（zulip-flutter）

| 文件 | 作用 | SVG 方案中的变更 |
|------|------|-----------------|
| `lib/model/katex.dart` | KaTeX HTML 解析器核心 | 大幅简化，仅保留 TeX 源码提取 |
| `lib/model/content.dart` | 消息内容模型 | `MathNode.nodes` 可移除 |
| `lib/widgets/katex.dart` | KaTeX Flutter Widget 渲染 | 替换为 SVG 渲染 |
| `lib/widgets/content.dart` | 消息内容渲染总入口 | `MathBlock` / `MathInline` 改用 SVG |
| `assets/KaTeX/*.ttf` | 21 个 KaTeX 字体文件 | SVG 方案中不再需要 |

### 服务端（zulip）— 不改变

| 文件 | 作用 |
|------|------|
| `web/server/katex_server.ts` | KaTeX 渲染服务（继续输出 HTML） |
| `zerver/lib/tex.py` | 服务端 KaTeX 渲染调用层 |
| `zerver/lib/mime_types.py` | MIME 类型白名单（禁止 SVG） |
