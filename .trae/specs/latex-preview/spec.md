# LaTeX 预览功能 Spec

## 功能目标

在消息编辑框中，当光标位于 LaTeX 公式界定符内时，在输入框和按钮行之间显示公式渲染预览，帮助用户在发送前确认公式输入是否正确。

## 设计原则

- **最小资源开销**：仅预览光标所在公式，失焦后销毁预览
- **简洁触发**：检测到成对界定符才显示，未完成公式不预览
- **复用现有组件**：使用已有的 `MathWidget` 渲染

## 预览显示条件

**全部满足才显示预览区**：

1. 输入框有焦点
2. 光标所在位置前后存在最近的一对完整界定符
3. 界定符类型：`$...$`、`$$...$$`、`\(...\)`、`\[...\]`

**不满足任一条件** → 预览区不显示（Widget 销毁，零渲染开销）

## 预览位置

```
[ 输入框 ]
[ LaTeX 预览区域 ]  ← 仅当条件满足时显示
[ 数学符号工具栏 ]  ← 如果展开
[ 📎 📷 Σ ] [ 发送 ]
```

位于输入框和按钮行之间，在数学符号工具栏上方（如果工具栏展开）。

## 界定符检测逻辑

### 检测函数

```dart
/// 在 [text] 中查找包含 [cursorPosition] 的最近一对 LaTeX 界定符。
///
/// 返回公式内容（不含界定符），如果没有找到返回 null。
///
/// 检测顺序（优先匹配更长的界定符）：
/// 1. $$...$$（含换行）
/// 2. \[...\]
/// 3. \(...\)
/// 4. $...$
String? findLatexAtCursor(String text, int cursorPosition);
```

### 检测规则

按界定符长度从长到短匹配，避免 `$$` 被误识别为两个 `$`：

1. **`$$...$$`**：从光标位置向前找最近的 `$$`，向后找最近的 `$$`，且内容含换行
2. **`\[...\]`**：从光标位置向前找最近的 `\[`，向后找最近的 `\]`
3. **`\(...\)`**：从光标位置向前找最近的 `\(`，向后找最近的 `\)`
4. **`$...$`**：从光标位置向前找最近的独立 `$`（非 `$$` 的一部分），向后找最近的独立 `$`

### 不检测的界定符

- `` ```math...``` ``（Zulip 格式，用户不会手动输入）
- 代码块内的界定符（简化处理，不考虑此边界情况）

## 预览渲染

- 使用已有的 `MathWidget` 组件
- `displayMode`：根据界定符类型决定
  - `$...$` 和 `\(...\)` → `displayMode: false`（行内）
  - `$$...$$` 和 `\[...\]` → `displayMode: true`（独立）
- 渲染失败时：不显示预览区（与"没有公式"行为一致）
- 不经过 LaTeX 自动转换，直接用原始内容渲染

## 防抖

- 文本变化后延迟 300ms 再更新预览，避免打字过程中频繁重渲染
- 使用 `Timer` 实现

## 代码结构

### 新增文件

| 文件 | 说明 |
|------|------|
| `lib/model/latex_preview.dart` | 界定符检测逻辑 `findLatexAtCursor()` |
| `lib/widgets/latex_preview.dart` | 预览区域 Widget |
| `test/model/latex_preview_test.dart` | 检测逻辑单元测试 |

### 修改文件

| 文件 | 说明 |
|------|------|
| `lib/widgets/compose_box.dart` | 在 `_ComposeBoxBody.build()` 中集成预览区域 |

### 关键实现

#### `lib/model/latex_preview.dart`

```dart
/// 在 [text] 中查找包含 [cursorPosition] 的最近一对 LaTeX 界定符。
///
/// 返回 `(String content, bool displayMode)`，如果没有找到返回 null。
/// - content：公式内容（不含界定符）
/// - displayMode：是否为独立公式
(String, bool)? findLatexAtCursor(String text, int cursorPosition);
```

#### `lib/widgets/latex_preview.dart`

```dart
class LatexPreviewArea extends StatefulWidget {
  const LatexPreviewArea({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<LatexPreviewArea> createState() => _LatexPreviewAreaState();
}

class _LatexPreviewAreaState extends State<LatexPreviewArea> {
  String? _previewContent;
  bool _displayMode = false;
  Timer? _debounceTimer;

  void _updatePreview() {
    // 300ms 防抖
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!widget.focusNode.hasFocus) {
        setState(() { _previewContent = null; });
        return;
      }
      final result = findLatexAtCursor(
        widget.controller.text,
        widget.controller.selection.baseOffset,
      );
      setState(() {
        if (result != null) {
          _previewContent = result.$1;
          _displayMode = result.$2;
        } else {
          _previewContent = null;
        }
      });
    });
  }

  // ... listener 注册/注销，build 方法
}
```

#### `compose_box.dart` 集成位置

在 `_ComposeBoxBody.build()` 中，输入框和工具栏之间插入：

```dart
Column(children: [
  // 输入框
  Padding(..., child: Column(children: [
    ?topicInput,
    buildContentInput(),
  ])),
  // LaTeX 预览
  LatexPreviewArea(
    controller: controller.content,
    focusNode: controller.contentFocusNode,
  ),
  // 数学符号工具栏
  if (mathSymbolsToolbarVisible)
    Padding(..., child: MathSymbolsToolbar(...)),
  // 按钮行
  SizedBox(...),
])
```

## 测试计划

### 单元测试（`test/model/latex_preview_test.dart`）

- `$x^2$` 光标在中间 → 返回 `("x^2", false)`
- `$$\nE=mc^2\n$$` 光标在中间 → 返回 `("E=mc^2", true)`
- `\(\alpha\)` 光标在中间 → 返回 `("\\alpha", false)`
- `\[\beta\]` 光标在中间 → 返回 `("\\beta", true)`
- `$x^2` 缺右界定符 → 返回 null
- 光标在界定符外 → 返回 null
- 多公式时返回光标所在的那个
- `$$x$$` 光标在中间 → 返回 `("x", true)`（`$$` 优先于 `$`）
- 空内容 → 返回 null

### Windows 测试命令

```powershell
# 单元测试
D:\vc\flutter\bin\flutter.bat test test/model/latex_preview_test.dart

# 静态分析
D:\vc\flutter\bin\flutter.bat analyze

# 构建 APK
D:\vc\flutter\bin\flutter.bat build apk
```

## 版本更新

版本号从 `30.0.272-for-math.2` 更新为 `30.0.272-for-math.3`。

更新文件：
- `pubspec.yaml`
- `RELEASE_NOTES.md`
- `README.md`
- `.github/workflows/build-stable-release.yml`
