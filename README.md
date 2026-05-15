# math-fork 分支功能说明

## 版本信息
- **分支**: math-fork
- **分叉点**: a48fad26820e76b89ced28ef8d3b0e36ec0dc680
- **当前版本**: v30.0.272-for-math.1
- **发布日期**: 2026-05-15

---

## 功能概述

本版本主要带来一项核心功能增强：

### 1. 数学公式渲染优化（核心功能 ✅ 已完成）

**官方原版方案**:
- 架构：解析 `katex-html` span/CSS 树，手动实现 CSS → Flutter Widget 映射
- 代码量：~1200 行 KaTeX HTML/CSS 解析代码
- 字体：依赖 21 个 KaTeX TTF 字体文件
- Bug：受 [flutter#167474](https://github.com/flutter/flutter/issues/167474) 影响（Android KaTeX_Math 斜体）
- 问题：只支持部分 KaTeX CSS 特性，维护成本高

**解决方案**: 使用 [flutter_math_fork](https://pub.dev/packages/flutter_math_fork) 纯 Dart KaTeX 渲染器

**优势对比**:
| 特性 | 官方原版 | 新方案 |
|------|---------|--------|
| 架构 | 解析 span/CSS 树 → Widget | TeX → flutter_math_fork → Canvas |
| KaTeX 语法支持 | 部分（CSS 覆盖率限制） | 完整 |
| 渲染一致性 | 与 Web 端有差异 | 与 Web 端一致 |
| 字体依赖 | 21 个 TTF 文件 | 无（SVG 自包含字形） |
| Android Bug | 受 flutter#167474 影响 | 不受影响 |
| 维护成本 | 高（跟随 KaTeX CSS 更新） | 低 |

**技术变更**:
- 移除 ~1200 行 KaTeX HTML/CSS 解析代码
- 新增 `MathWidget` 封装 flutter_math_fork 的 `Math.tex()`
- 移除 `csslib` 依赖和 21 个 KaTeX 字体资源
- 添加 `flutter_math_fork` 依赖

**已知问题**:
- ⚠️ 公式字体在移动端显示偏细，待后续优化

---

### 2. 内联 SVG 图形渲染（❌ 未完成）

**功能描述**: 支持在聊天消息中直接显示内联 SVG 图形

**当前状态**: 代码框架已预留，但测试显示 SVG 仍显示为原文代码而非渲染图案

**待修复问题**:
- [ ] SVG 解析/渲染逻辑 bug
- [ ] 编写单元测试
- [ ] 编写 Widget 测试


---

## 依赖变更

### 新增依赖
- `flutter_math_fork: ^0.7.2` - 纯 Dart KaTeX 渲染器

### 移除依赖
- `csslib: ^0.17.2` - CSS 解析（不再需要）

---

## 测试状态

- ✅ 单元测试通过
- ✅ Widget 测试通过
- ✅ CI 检查通过

---

## 兼容性说明

- ✅ 兼容现有消息格式
- ✅ 向后兼容不含数学公式的消息

---

## 发布检查清单

- [x] 数学公式渲染测试
- [ ] 与官方功能对比验证
- [ ] APK 构建测试
- [ ] 内联 SVG 渲染修复（待后续版本）
