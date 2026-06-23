# Zulip 数学版

面向高中数学交流的 Android/iOS Zulip 客户端。

## 概述

本项目是 [Zulip Flutter 客户端](https://github.com/zulip/zulip-flutter) 的定制分支，为高中生增加了数学公式输入和渲染功能。

## 功能特性

### 数学公式渲染
- 使用 [flutter_math_fork](https://pub.dev/packages/flutter_math_fork) 纯 Dart KaTeX 渲染引擎
- 完整支持 KaTeX 语法，与 Web 端渲染一致
- 无外部字体依赖（SVG 自包含字形）

### 数学符号工具栏
- 6 个分类标签：常用、关系与集合、函数、希腊字母、公式模板、最近
- 一键快速输入符号（αβγ、±×÷、∫∑∂ 等）
- LaTeX 模板自动定位光标（如 `\frac{}{}` 光标自动定位到分子）
- 最近使用符号跨会话持久化

### LaTeX 界定符自动转换
- 发送消息时自动将标准 LaTeX 界定符转换为 Zulip 格式
- `$...$` / `\(...\)` → `$$...$$`（行内公式）
- `$$...$$` / `\[...\]` → `` ```math ``` `` 块（独立公式）
- 可在 设置 > 实验性功能 中关闭（默认开启）

### LaTeX 实时预览
- 光标位于公式界定符内时自动渲染预览
- 300ms 防抖，输入框失焦后自动消失
- 仅预览光标所在位置的公式

## 快速开始

开发环境搭建请参阅 [docs/setup.md](docs/setup.md)。

## 版本号规则

版本号格式：`30.0.272-math-vX.Y+Z`

- `30.0.272`：上游 Zulip 客户端基准版本
- `math-vX.Y`：数学功能版本
- `+Z`：构建号

详细版本历史请参阅 [CHANGELOG-MATH.md](CHANGELOG-MATH.md)。

## 文档

- [数学功能说明](docs/math-features.md) — 数学输入功能详细文档
- [更新日志](CHANGELOG-MATH.md) — 版本历史
- [环境搭建](docs/setup.md) — 开发环境配置
- [发布流程](docs/release.md) — 如何构建和发布

## 许可证

本项目继承上游 Zulip Flutter 客户端的许可证。
