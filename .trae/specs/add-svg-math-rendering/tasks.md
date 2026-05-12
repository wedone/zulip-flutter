# Tasks

* [x] Task 1: 添加 flutter_svg 和 flutter_tex 依赖
  * [x] SubTask 1.1: 在 pubspec.yaml 中添加 `flutter_svg: ^2.2.3` 和 `flutter_tex: ^5.2.7` 依赖
  * [x] SubTask 1.2: 运行 `flutter pub get` 验证依赖兼容性
  * [x] SubTask 1.3: 确认项目可正常编译

* [x] Task 2: 创建 TeX → SVG 转换服务
  * [x] SubTask 2.1: 使用 flutter_tex 内置的 TeXRenderingServer 和缓存（无需自建）
  * [x] SubTask 2.2: 在 main.dart 中初始化 TeXRenderingServer

* [x] Task 3: 创建 SvgMathWidget 组件
  * [x] SubTask 3.1: 创建 `lib/widgets/svg_math.dart`，封装 Math2SVG
  * [x] SubTask 3.2: 实现 TeX → SVG 转换 + flutter_svg 渲染流程
  * [x] SubTask 3.3: Math2SVG 内置 RepaintBoundary
  * [x] SubTask 3.4: 实现转换失败时的 TeX 源码纯文本回退
  * [x] SubTask 3.5: 为 SvgMathWidget 编写 Widget 测试

* [x] Task 4: 修改 MathBlock 和 MathInline 使用 SVG 渲染
  * [x] SubTask 4.1: 修改 `lib/widgets/content.dart` 中 `MathBlock`，使用 `SvgMathWidget`
  * [x] SubTask 4.2: 修改 `lib/widgets/content.dart` 中 `MathInline`，使用 `SvgMathWidget`
  * [x] SubTask 4.3: 确保行内公式在文本流中的基线对齐正确
  * [x] SubTask 4.4: 确保块级公式的居中、LTR 方向、水平滚动功能保留
  * [x] SubTask 4.5: 更新 `test/widgets/content_test.dart` 中的相关测试

* [x] Task 5: 简化 KaTeX 解析器
  * [x] SubTask 5.1: 修改 `parseMath` 函数，仅保留 TeX 源码提取逻辑
  * [x] SubTask 5.2: 移除 `_KatexParser` 类及其全部方法
  * [x] SubTask 5.3: 移除 `KatexParserHardFailReason`、`KatexParserSoftFailReason`、`MathParserResult` 类
  * [x] SubTask 5.4: `parseMath` 返回值简化为 `String?`
  * [x] SubTask 5.5: 更新 `test/model/katex_test.dart`

* [x] Task 6: 简化 MathNode 数据模型
  * [x] SubTask 6.1: 修改 `MathNode` 类，移除 `nodes`、`debugHardFailReason`、`debugSoftFailReason` 字段
  * [x] SubTask 6.2: 更新 `MathBlockNode` 和 `MathInlineNode` 构造函数
  * [x] SubTask 6.3: 更新 `content.dart` 中 `parseInlineMath` 和 `parseMathBlocks` 函数
  * [x] SubTask 6.4: 更新 `test/model/content_test.dart` 中的相关测试

* [x] Task 7: 移除 KaTeX 节点类型和样式类型
  * [x] SubTask 7.1: 从 `lib/model/content.dart` 移除 `KatexNode`、`KatexSpanNode` 等
  * [x] SubTask 7.2: 从 `lib/model/katex.dart` 移除 `KatexSpanStyles` 等
  * [x] SubTask 7.3: 移除 `csslib` 依赖
  * [x] SubTask 7.4: 更新所有受影响的 import 语句

* [x] Task 8: 移除旧 KatexWidget 渲染代码
  * [x] SubTask 8.1: 清空 `lib/widgets/katex.dart`
  * [x] SubTask 8.2: 移除 `NegativeLeftOffset`、`RenderNegativePadding`
  * [x] SubTask 8.3: 移除 `mkBaseKatexTextStyle` 函数
  * [x] SubTask 8.4: 更新 `test/widgets/katex_test.dart`

* [x] Task 9: 移除 KaTeX 字体文件和声明
  * [x] SubTask 9.1: 删除 `assets/KaTeX/*.ttf`（20 个字体文件）
  * [x] SubTask 9.2: 从 `pubspec.yaml` 移除 KaTeX 字体声明
  * [x] SubTask 9.3: 移除 `assets/KaTeX/LICENSE` 引用
  * [x] SubTask 9.4: 更新 `lib/licenses.dart` 中的字体许可证信息
  * [x] SubTask 9.5: 更新 `test/widgets/katex_test.dart`

* [x] Task 10: 端到端验证与性能测试
  * [x] SubTask 10.1: flutter analyze 通过（lib/ 和 test/ 无错误）
  * [x] SubTask 10.2: 所有修改文件 GetDiagnostics 无错误
  * [x] SubTask 10.3: 更新 `tools/content/unimplemented_katex_test.dart`
  * [x] SubTask 10.4: Android/iOS 平台配置已更新

# Task Dependencies
* All tasks completed sequentially as planned
