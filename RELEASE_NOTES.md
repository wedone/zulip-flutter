# 版本发布指引

本文档记录发布新版本时需要更新的文件和内容，供 AI 或人工参考。

## 版本号规则

格式：`30.0.272-math-vX.Y+Z`

- `30.0.272`：上游 Zulip 客户端基准版本
- `math-vX.Y`：数学功能版本（X=大版本，Y=小版本）
- `+Z`：构建号（每次打包递增）

**版本号递增规则：**
- `Y` 递增：新增功能、优化、bug 修复
- `X` 递增：重大变更、不兼容更新
- `Z` 递增：仅重新构建，功能无变更

---

## 版本发布时需更新的文件

### 1. `pubspec.yaml`

更新 `version:` 字段：

```yaml
version: 30.0.272-math-v2.1+1
```

构建号 `+Z` 从 1 开始，每次重新构建 APK 时递增。

### 2. `CHANGELOG-MATH.md`

在文件顶部（`## math 版更新日志` 下方）添加新版本条目：

```markdown
## math-v2.1（YYYY-MM-DD）

### 新增
- 新增...

### 改进
- 优化...

### 修复
- 修复...
```

格式要求：
- 标题：`## math-vX.Y（YYYY-MM-DD）`（使用中文括号）
- 内容按功能分类，使用 `###` 三级标题
- 条目使用 `- ` 列表格式

### 3. `docs/ver/vX.Y.md`

创建新文件，写入本次版本的发布说明（将用于 GitHub Releases）：

```markdown
### 新增
- 新增...

### 改进
- 优化...
```

内容要求：
- 纯 markdown 格式，不包含 `#` 级标题
- 面向用户，描述新增功能和改进
- 不包含技术细节（如 commit hash、内部重构等）

### 4. `docs/release.md`（如需）

如果发布流程本身有变更，更新此文档。

---

## 版本发布完整流程

1. **更新版本号**：编辑 `pubspec.yaml` 的 `version:` 字段
2. **更新 CHANGELOG**：在 `CHANGELOG-MATH.md` 顶部添加新版本条目
3. **创建发布说明**：新建 `docs/ver/vX.Y.md` 文件
4. **提交并推送**：`git add && git commit && git push`
5. **触发构建**：GitHub Actions → "构建稳定版客户端" → Run workflow
6. **检查结果**：构建成功后，自动在 GitHub Releases 创建 release

---

## 示例：从 v2.0 到 v2.1

**变更内容**：数学工具栏新增换行按钮

**更新的文件：**

1. `pubspec.yaml`：`version: 30.0.272-math-v2.1+1`
2. `CHANGELOG-MATH.md`：添加 `## math-v2.1（2026-06-24）` 条目
3. `docs/ver/v2.1.md`：新建文件，写入更新说明
