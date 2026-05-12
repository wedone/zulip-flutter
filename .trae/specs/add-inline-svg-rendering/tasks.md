# Tasks

- [ ] Task 1: 新增 InlineSvgNode 数据模型
  - [ ] SubTask 1.1: 在 `lib/model/content.dart` 中新增 `InlineSvgNode` 类，包含 `svgSource` 字段
  - [ ] SubTask 1.2: 修改文本节点解析逻辑，检测 `<svg` ... `</svg>` 模式

- [ ] Task 2: 新增 InlineSvgWidget 渲染组件
  - [ ] SubTask 2.1: 创建 `InlineSvgWidget`，使用 `SvgPicture.string()` 渲染
  - [ ] SubTask 2.2: 限定 SVG 渲染尺寸（最大高度 10em，与行内图片一致）
  - [ ] SubTask 2.3: 实现 SVG 解析失败时的纯文本回退

- [ ] Task 3: 集成到内容渲染系统
  - [ ] SubTask 3.1: 在 `InlineContent` 中添加 `InlineSvgNode` 的渲染分支
  - [ ] SubTask 3.2: 在 `BlockContentList` 中添加 `InlineSvgNode` 的渲染分支（如需要）

- [ ] Task 4: 测试
  - [ ] SubTask 4.1: 在 `test/model/content_test.dart` 添加 SVG 解析测试
  - [ ] SubTask 4.2: 在 `test/widgets/content_test.dart` 添加 SVG 渲染测试

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 2]
- [Task 4] depends on [Task 3]
