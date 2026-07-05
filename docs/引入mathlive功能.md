# 引入 MathLive 数学公式输入功能

> 在 Zulip Flutter 会话界面的 ComposeBox 中集成 MathLive 数学公式编辑器与虚拟键盘，使用户能够在移动端高效输入数学公式，并一键插入到消息内容中。

## 1. 需求：用户要什么

高中学生在 Zulip 上讨论数学问题时，需要在消息中输入数学公式。当前移动端的系统键盘无法满足以下需求：

| 需求 | 具体描述 |
|------|---------|
| **特殊符号输入** | 积分号 ∫、求和号 ∑、希腊字母 αβγ、集合符号 ∈⊆∪ 等，系统键盘上难以输入 |
| **结构化公式编辑** | 分数 `\frac{}{}`、根号 `\sqrt{}`、上下标 `^{}_`、矩阵等嵌套结构，纯文本输入极其低效 |
| **所见即所得** | LaTeX 源码与渲染结果之间缺乏即时反馈，输入错误难以发现 |

**核心需求**：一个数学专用的虚拟键盘 + 所见即所得的公式编辑器，编辑完成后一键插入到消息内容中。

## 2. 现状：客户原来有什么

### 2.1 已有的数学相关功能（代码验证）

通过实际代码验证，当前 Zulip Flutter 项目具备以下数学相关能力：

| 能力 | 实际位置 | 现状 |
|------|---------|------|
| 消息中的公式渲染 | `lib/widgets/math_widget.dart` | ✅ 已落地。使用 `flutter_math_fork ^0.7.4`，`Math.tex()` 渲染 TeX 源码，支持 `displayMode` 行内/行间，有 `onErrorFallback` |
| KaTeX HTML → TeX 提取 | `lib/model/katex.dart` | ✅ 已落地。`parseMath()` 从服务器返回的 KaTeX HTML 中提取 `<annotation encoding="application/x-tex">` |
| 内容模型中的公式节点 | `lib/model/content.dart` | ✅ 已落地。`MathNode` sealed class，持有 `texSource` 字段，分为 `BlockMathNode` 和 `InlineMathNode` |
| 消息列表中的公式显示 | `lib/widgets/content.dart` | ✅ 已落地。行间用 `SingleChildScrollView` + `MathWidget(displayMode: true)`，行内用 `WidgetSpan` + `MathWidget(displayMode: false)` |
| **公式输入能力** | — | ❌ **不存在**。没有数学键盘、没有公式编辑器 |
| **LaTeX 格式转换** | `lib/model/latex_converter.dart` | ❌ **不存在**。发送时 `$$...$$` → ` ```math...``` ` 的转换未实现 |

**关键结论**：项目仅有**公式渲染（只读）能力**，完全没有**公式输入（写）能力**。

### 2.2 已有的 ComposeBox 结构（代码验证）

实际代码中 ComposeBox 的结构如下（`lib/widgets/compose_box.dart`，约 2400 行）：

```
ComposeBox (StatefulWidget)
  └─ _ComposeBoxState
       └─ _ComposeBoxContainer
            └─ _ComposeBoxBody (abstract)
                 ├─ topicInput (仅 _StreamComposeBoxBody)
                 ├─ contentInput (_ContentInput → TextField)
                 └─ 按钮行: [_AttachFileButton] [_AttachMediaButton] [_AttachFromCameraButton]  [←space→]  [_SendButton]
```

**关键观察**：
- `_ContentInput` 是标准的 Flutter `TextField`，由 `ComposeContentController` 管理
- `ComposeContentController.insertionIndex()` 提供光标位置——这是公式插入的接入点
- `ComposeContentController.insertPadded()` 可在光标位置插入文本——这是引用回复等已有功能的插入方式
- 操作按钮行是 `Row`，左对齐为 `composeButtons` 列表，右对齐为 `sendButton`——新按钮加在 `composeButtons` 中即可

### 2.3 可利用的外部资源

| 资源 | 路径 | 说明 |
|------|------|------|
| **MathLive 库**（用户修改版） | `D:\vc\mathlive` | Web Components 数学编辑器，已按个人需求修改 |
| **指定的 VK + math-field 模板** | `D:\vc\mathlive\examples\scrollable-keyboard\index.html` | 用户明确指定使用此文件中的 VirtualKeyboard 布局和 math-field 配置 |
| mathlive_studio Flutter 包 | `D:\vc\mathlive_editor_package\flutter_mathlive_mixed` | 已有的 Flutter 封装，但因 MathLive 已做个人修改且指定了特定模板，**不能直接使用** |

### 2.4 MathLive 的技术约束

MathLive 是一个 **Web Components 库**（`<math-field>` 自定义元素），**无法直接在 Flutter 原生组件中使用**，必须通过 WebView 桥接。

## 3. 方案：怎么实现用户需求

### 3.1 引入方式

由于 MathLive 已做个人修改，且明确指定使用 `D:\vc\mathlive\examples\scrollable-keyboard\index.html` 中的 VirtualKeyboard 和 math-field，**不能直接使用 `mathlive_studio` 包**，需要自建 WebView 封装。

引入步骤：

1. **复制 MathLive 构建产物**：将 `D:\vc\mathlive\dist\` 下的必要资源复制到 `D:\vc\zulip-flutter\assets\mathlive\`
2. **基于 scrollable-keyboard 创建 HTML 模板**：以 `scrollable-keyboard/index.html` 为蓝本，创建适配 Zulip 场景的 WebView HTML
3. **自建 WebView Widget 封装**：参考 `mathlive_studio` 的 `MathLiveEmbeddedEditor` 实现，创建 `MathLivePanel` Widget

> `mathlive_studio` 包虽不能直接使用，但其源码可作为重要参考——尤其是 WebView 初始化、JS Channel 通信、主题切换、平台适配等基础设施的实现。

**需要复制的资源**：

| 源文件 | 目标 | 说明 |
|--------|------|------|
| `D:\vc\mathlive\dist\mathlive.mjs` | `assets/mathlive/mathlive.mjs` | MathLive 核心 JS（已含个人修改） |
| `D:\vc\mathlive\dist\mathlive-static.css` | `assets/mathlive/mathlive-static.css` | MathLive 静态样式 |
| `D:\vc\mathlive\dist\fonts\*.woff2` | `assets/mathlive/fonts\*.woff2` | 数学字体（KaTeX 字体的 woff2 版本） |

### 3.2 指定的 scrollable-keyboard 方案

用户指定的 `scrollable-keyboard/index.html` 方案的核心特征：

- **`mathVirtualKeyboardPolicy = 'manual'`**：不自动弹出，由外部控制
- **`mathVirtualKeyboard.show()`**：永远显示虚拟键盘
- **6 行 rows + fixedRows 布局**：针对高中数学场景定制的按键布局
- **隐藏原生 toggles**：通过 CSS `math-field::part(menu-toggle) { display: none }` 隐藏内置按钮
- **自定义插入按键**：fixedRows 中 `[return]` 按键执行 `performWithFeedback(commit)` 命令

```
scrollable-keyboard 布局概览：
┌─────────────────────────────────────────────┐
│ math-field (公式编辑区，无边框，所见即所得)    │
├─────────────────────────────────────────────┤
│ VirtualKeyboard                              │
│ ┌─ Layout Toolbar ────────────────────────┐ │
│ │ [常用] [numeric] [symbols] [alphabetic] [greek] │
│ ├─ rows (6行，可滚动) ────────────────────┤ │
│ │ 行1: 0-4 | A-E (变体:α-ε)              │ │
│ │ 行2: 5-9 | F-J (变体:ζ-θ)              │ │
│ │ 行3: .()<> | K-O (变体:Δ-ε)             │ │
│ │ 行4: ′ ÷ ² √ → | P-T (变体:η-τ)       │ │
│ │ 行5: | ∥ ∠ △ ∵ | U-Z                   │ │
│ │ 行6: ∈ ∋ ∪ ⇒ ⇐ | sin cos tan log max  │ │
│ ├─ fixedRows (固定操作行) ────────────────┤ │
│ │ [+][-][*][/][=] │ [⇧][⌫][←][→][return] │ │
│ └──────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

### 3.3 界面布局方案

#### 原 ComposeBox（代码验证）

```
┌─────────────────────────────────────────────┐
│ _ComposeBoxBody                              │
│ ├─ topicInput (仅 _StreamComposeBoxBody)     │
│ ├─ contentInput (_ContentInput → TextField)  │
│ └─ 按钮行: [📎][📷][📸]    [➤]              │
└─────────────────────────────────────────────┘
```

#### 新增 MathLive 后的布局

```
不变部分省略
├─────────────────────────────────────────────┤
│ _ComposeBoxBody                              │
│ ├─ topicInput (仅 Stream)                    │
│ ├─ contentInput (系统键盘)                   │
│ └─ 按钮行: [📎][📷][📸][⌨️]    [➤]          │
├─────────────────────────────────────────────┤
│ MathLive 编辑面板 (条件显示)                  │
│ └─ 基于 scrollable-keyboard 的 WebView       │
│     ├─ <math-field> 公式编辑区               │
│     └─ VirtualKeyboard 虚拟键盘              │
└─────────────────────────────────────────────┘
```

> **方案选择理由**：`<math-field>` + VirtualKeyboard 作为独立面板显示/隐藏，放在 ComposeBox 下方。内容输入框保持原有行为（系统键盘输入文字），数学编辑面板作为独立区域出现，两者互不干扰。

#### 布局状态切换

```
┌─ 系统键盘模式（默认）────────────────────────────────┐
│  ┌─ ComposeBox ────────────────────────────────────┐ │
│  │  contentInput (TextField) ◀── 系统键盘聚焦      │ │
│  │  [📎][📷][📸][⌨️]                    [➤]        │ │
│  └──────────────────────────────────────────────────┘ │
│  ┌─ 系统键盘 ──────────────────────────────────────┐ │
│  └──────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────┘

┌─ 数学键盘模式 ────────────────────────────────────────┐
│  ┌─ ComposeBox ────────────────────────────────────┐ │
│  │  contentInput (TextField) ◀── 可接收公式插入     │ │
│  │  [📎][📷][📸][⌨️✓]                   [➤]        │ │
│  └──────────────────────────────────────────────────┘ │
│  ┌─ MathLive 编辑面板 (WebView) ────────────────────┐ │
│  │  ┌─ <math-field> ─────────────────────────────┐ │ │
│  │  │  x = (-b ± √(b²-4ac)) / 2a                │ │ │
│  │  └────────────────────────────────────────────┘ │ │
│  │  ┌─ VirtualKeyboard (scrollable-keyboard) ────┐ │ │
│  │  │  [常用][123][Σ][abc][αβγ]                  │ │ │
│  │  │  ...6行 rows...                             │ │ │
│  │  │  [+][-][*][/][=] │ [⇧][⌫][←][→][return]   │ │ │
│  │  └────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────┘
```

### 3.4 公式插入方案

scrollable-keyboard 中的 `[return]` 按键执行 `performWithFeedback(commit)` 命令。需要自定义此命令，使其将 LaTeX 传回 Flutter 层：

**插入流程**：

1. 用户在 `<math-field>` 中编辑公式
2. 点击 fixedRows 中的 `[return]` 按键
3. JS 层执行自定义命令，通过 `JavascriptChannel` 将 `mf.getValue('latex')` 传给 Flutter
4. Flutter 层将 LaTeX 包装为 `$$...$$`（行内）或 `` ```math ... ``` ``（行间）
5. 通过 `ComposeContentController.insertionIndex()` + `value.replaced()` 插入到光标位置
6. 清空 `<math-field>`

**行内 vs 行间**：在 HTML 模板中，`[return]` 按键的 `shift` 变体可切换为行间插入（参考 scrollable-keyboard 中已有的 shift 机制）。默认 `[return]` 插入行内公式（`$$...$$`），Shift + `[return]` 插入行间公式（`` ```math ... ``` ``）。

### 3.5 数据流

```
用户在 <math-field> 中编辑公式
       ↓
点击 fixedRows 中的 [return] 按键
       ↓
JS 自定义命令: mf.getValue('latex')
       ↓
InsertChannel.postMessage('$$' + latex + '$$')  // 或 ```math\n...\n```
       ↓
Flutter JavascriptChannel 接收
       ↓
ComposeContentController.insertionIndex() 获取光标位置
       ↓
controller.value = controller.value.replaced(insertionIndex, wrappedLatex)
       ↓
清空 <math-field>，用户继续编辑或发送
```

### 3.6 发送时的格式转换

Zulip 服务器使用非标准的 LaTeX 分隔符，发送消息时需将 ComposeBox 中的用户输入格式转换：

| 用户输入格式（ComposeBox 中显示） | Zulip 服务器格式 | 说明 |
|-------------|----------------|------|
| `$$...$$` | ```` ```math ... ``` ```` | 行内公式 |
| `` ```math ... ``` `` | ```` ```math ... ``` ```` | 行间公式 |

> **说明**：行内公式在 ComposeBox 中用 `$$...$$` 表示（与标准 LaTeX 行间公式符号相同，但 Zulip 将其视为行内），行间公式用 `` ```math ... ``` `` 表示（Zulip 的 fenced code block 语法）。发送时两者都转为 `` ```math ... ``` `` 格式，区别在于行内公式在消息中与文字同行显示，行间公式独占一行。因此 **`$$...$$` 格式无需转换**，只需确保 `` ```math ... ``` `` 格式正确即可。
>
> **需要新建** `lib/model/latex_converter.dart`，处理发送时的格式确认和 ZWSP（零宽空格）插入以绕过服务器 `\B` 正则限制。

## 4. 关键代码

### 4.1 WebView HTML 模板（基于 scrollable-keyboard 适配）

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
  <style>
    /* 参考 scrollable-keyboard/index.html 的样式，适配 WebView 场景 */
    html, body { margin: 0; height: 100%; overflow: hidden; }
    .editor-area { flex: 1; display: flex; flex-direction: column; justify-content: flex-end; }
    math-field { font-size: 22px; width: 100%; border: none; outline: none; padding: 8px 12px; }
    math-field::part(menu-toggle) { display: none; }
    math-field::part(virtual-keyboard-toggle) { display: none; }
  </style>
</head>
<body>
  <div class="editor-area">
    <math-field id="mf" math-virtual-keyboard-policy="manual"></math-field>
  </div>
  <script type="module">
    import './mathlive.mjs';

    const mf = document.getElementById('mf');
    mathVirtualKeyboard.show();

    // ★ 键盘布局：直接来自 scrollable-keyboard/index.html
    mathVirtualKeyboard.layouts = [
      { label: '常用', layers: [{ rows: [ /* ...6行... */ ], fixedRows: [ /* ...操作行... */ ] }] },
      'numeric', 'symbols', 'alphabetic', 'greek'
    ];

    // ★ 注册插入命令（替换 scrollable-keyboard 中的 performWithFeedback(commit)）
    // 默认 [return] → 行内公式 $$...$$
    // Shift + [return] → 行间公式 ```math ... ```
    let isShift = false;
    mf.addEventListener('commit', () => {
      const latex = mf.getValue('latex');
      if (latex) {
        if (isShift) {
          InsertChannel.postMessage('```math\n' + latex + '\n```');
        } else {
          InsertChannel.postMessage('$$' + latex + '$$');
        }
        mf.setValue('');
      }
    });
    // 监听 shift 状态（参考 scrollable-keyboard 中 VirtualKeyboard 的 shift 机制）
    mathVirtualKeyboard.addEventListener('shift-change', (ev) => {
      isShift = ev.shift;
    });
  </script>
</body>
</html>
```

### 4.2 Flutter WebView 封装

```dart
// lib/widgets/math_live_panel.dart
// 参考 mathlive_studio 的 MathLiveEmbeddedEditor 实现

class MathLivePanel extends StatefulWidget {
  const MathLivePanel({super.key, required this.isDark, required this.onFormulaInserted});
  final bool isDark;
  final ValueChanged<String> onFormulaInserted;

  @override
  State<MathLivePanel> createState() => _MathLivePanelState();
}

class _MathLivePanelState extends State<MathLivePanel> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('InsertChannel', onMessageReceived: (msg) {
        widget.onFormulaInserted(msg.message);
      })
      ..loadFlutterAsset('assets/mathlive/mathlive_editor.html');
    // 参考 mathlive_studio 的平台适配逻辑
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: WebViewWidget(controller: _controller),
    );
  }
}
```

### 4.3 ComposeBox 集成

```dart
// lib/widgets/compose_box.dart 中的改动点

// 1. 新增状态
ValueNotifier<bool> mathKeyboardVisible = ValueNotifier(false);

// 2. 切换逻辑
void toggleMathKeyboard() {
  final newValue = !mathKeyboardVisible.value;
  if (newValue) {
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
  mathKeyboardVisible.value = newValue;
}

// 3. 公式插入回调（利用已有的 insertionIndex() + replaced()）
void onFormulaInserted(String latex) {
  final controller = this.controller;
  final i = controller.content.insertionIndex();
  controller.content.value = controller.content.value.replaced(i, latex);
}

// 4. 在 composeButtons 列表中添加按钮（约第 1492 行）
composeButtons.add(IconButton(
  icon: Icon(Icons.keyboard),
  isSelected: mathKeyboardVisible.value,
  onPressed: toggleMathKeyboard,
));

// 5. 在 _ComposeBoxContainer 的 Column children 中条件渲染面板
ValueListenableBuilder<bool>(
  valueListenable: mathKeyboardVisible,
  builder: (_, visible, __) => visible
    ? MathLivePanel(isDark: isDark, onFormulaInserted: onFormulaInserted)
    : const SizedBox.shrink(),
),
```

### 4.4 LaTeX 格式转换（发送时）

```dart
// lib/model/latex_converter.dart（新建）

/// 将 ComposeBox 中的 LaTeX 公式标记转换为 Zulip 服务器格式
///
/// Zulip 的非标准界定符：
///   行内公式：$$...$$（在 Zulip 中渲染为行内）
///   行间公式：```math ... ```（fenced code block 语法）
///
/// 发送时 $$...$$ 需转为 ```math ... ```，因为 Zulip 服务器
/// 用 ```math 格式来识别和渲染所有数学公式。
String convertLatexForSending(String content) {
  // $$...$$ → ```math\n...\n```（行内公式）
  content = content.replaceAllMapped(
    RegExp(r'\$\$(.*?)\$\$', dotAll: true),
    (m) => '```math\n${m.group(1)!}\n```',
  );
  // ```math ... ``` 格式无需转换，已经是 Zulip 服务器格式
  return content;
}
```

## 5. 需要修改的文件清单

| 文件 | 改动 | 说明 |
|------|------|------|
| `assets/mathlive/mathlive.mjs` | **从 D:\vc\mathlive\dist 复制** | MathLive 核心 JS（含个人修改） |
| `assets/mathlive/mathlive-static.css` | **从 D:\vc\mathlive\dist 复制** | MathLive 静态样式 |
| `assets/mathlive/fonts/*.woff2` | **从 D:\vc\mathlive\dist\fonts 复制** | 数学字体 |
| `assets/mathlive/mathlive_editor.html` | **新建** | 基于 scrollable-keyboard 适配的 WebView HTML 模板 |
| `pubspec.yaml` | 添加 `webview_flutter` 依赖 + assets 声明 | WebView 组件和资源声明 |
| `lib/widgets/math_live_panel.dart` | **新建** | MathLive WebView 面板 Widget（参考 mathlive_studio 实现） |
| `lib/widgets/compose_box.dart` | 添加 [⌨️] 按钮 + MathLive 面板 | 在操作按钮行新增切换按钮，下方条件渲染面板 |
| `lib/model/latex_converter.dart` | **新建** | 发送时 LaTeX 格式转换 + ZWSP 插入 |

## 6. 约束与风险

| 约束/风险 | 影响 | 应对策略 |
|-----------|------|---------|
| MathLive 是 Web Components，需 WebView 桥接 | 增加实现复杂度 | 参考 `mathlive_studio` 的 `MathLiveEmbeddedEditor` 实现，复用其平台适配逻辑 |
| MathLive 已做个人修改 | 不能用 `mathlive_studio` 包 | 将 `D:\vc\mathlive\dist` 资源复制到项目 assets，基于 scrollable-keyboard 自建 HTML |
| WebView 与 Flutter 通信有延迟 | 公式插入延迟 < 50ms | `JavascriptChannel.postMessage` 机制延迟可接受 |
| WebView 在 iOS/Android 行为差异 | 需双平台测试 | 参考 `mathlive_studio` 的 `_tunePlatform()` 和 Android 适配代码 |
| MathLive JS + 字体约 2MB | 增加应用安装包大小 | 仅复制必要文件：`mathlive.mjs`、`mathlive-static.css`、`fonts/*.woff2` |
| 系统键盘与虚拟键盘互斥 | 需精确控制显示/隐藏 | 切换时先 `unfocus()` + `TextInput.hide()`，再显示 WebView 面板 |
| `compose_box.dart` 对上游的侵入性 | 需控制改动范围 | 新增代码集中在 `composeButtons` 列表和 `_ComposeBoxContainer` 的 Column，减少合并冲突 |
| 本地 assets 需要正确配置 baseUrl | WebView 加载本地 HTML 需正确设置 | 参考 `mathlive_studio` 的 `loadHtmlString` + `baseUrl` 方案 |

## 7. 交互流程

### 7.1 正常使用流程

```
1. 用户在 ComposeBox 的内容输入框中打字（系统键盘）

2. 用户需要输入数学公式

3. 点击 [⌨️] 按钮（Icons.keyboard）

   → 系统键盘收起

   → MathLive 编辑面板从底部滑入

   → [⌨️] 按钮变为高亮/选中态

4. 用户在 <math-field> 中通过虚拟键盘编辑公式

   → 实时看到渲染后的公式

5. 点击 fixedRows 中的 [return] 按键（替换原回车键位置）

   → 以行内公式格式 $$...$$ 插入到内容输入框的光标位置

   → <math-field> 清空，可继续编辑下一个公式

6. （可选）需要行间公式时，先按 [⇧] 再按 [return] 按键

   → 以行间公式格式 ```math ... ``` 插入

7. 用户可继续在 <math-field> 中编辑更多公式并插入

8. 再次点击 [⌨️] 关闭数学面板

   → MathLive 编辑面板滑出

   → [⌨️] 按钮恢复正常态

9. 用户点击 [发送] 发送消息

   → 发送时 latex_converter 将 $$...$$ 转为 ```math ... ```

   → 行间公式 ```math ... ``` 格式无需转换
```

### 7.2 边界场景

| 场景 | 处理方式 |
|------|---------|
| 数学面板打开时点击内容输入框 | 关闭数学面板，弹出系统键盘 |
| 数学面板打开时点击发送 | 正常发送，数学面板状态不变 |
| 数学面板打开时切换话题 | 保持数学面板状态 |
| 数学面板打开时进入编辑消息模式 | 关闭数学面板，进入编辑模式 |
| 数学面板打开时页面失去焦点 | 数学面板保持但暂停交互 |
| 插入公式时内容输入框为空 | 直接在开头插入 |
| 插入公式时光标在已有文字中间 | 在光标位置插入，前后不加额外空格（`$$` 已自然分隔） |

## 8. 实现路线

### 阶段一：基础设施搭建

> 目标：让 MathLive 能在 Flutter 中跑起来

- [ ] 将 `D:\vc\mathlive\dist` 必要资源复制到 `assets/mathlive/`（`mathlive.mjs`、`mathlive-static.css`、`fonts/*.woff2`）
- [ ] 在 `pubspec.yaml` 中添加 `webview_flutter` 依赖和 assets 声明
- [ ] 基于 `scrollable-keyboard/index.html` 创建适配 WebView 的 HTML 模板（`assets/mathlive/mathlive_editor.html`），包含完整的 6 行 rows + fixedRows 键盘布局
- [ ] 实现 `MathLivePanel` Widget（WebView 封装，参考 `mathlive_studio` 的 `MathLiveEmbeddedEditor`），包含 JS Channel 通信和平台适配

### 阶段二：ComposeBox 集成

> 目标：在 ComposeBox 中可切换系统键盘/数学键盘，并插入公式

- [ ] 在 ComposeBox 操作按钮行添加 [⌨️] 切换按钮（使用 `Icons.keyboard` 图标）
- [ ] 实现系统键盘与数学面板的互斥切换逻辑（`unfocus()` + `TextInput.hide()` → 显示 WebView 面板）
- [ ] 实现行内公式插入（`[return]` → `$$...$$` → `ComposeContentController.insertPadded()`）
- [ ] 实现行间公式插入（`[⇧]` + `[return]` → `` ```math ... ``` `` → 插入）
- [ ] 点击内容输入框时自动关闭数学面板并弹出系统键盘

### 阶段三：格式转换与发送

> 目标：消息发送时自动将 `$$...$$` 转为 Zulip 服务器格式

- [ ] 实现 `latex_converter.dart`（`$$...$$` → `` ```math ... ``` `` 转换 + ZWSP 插入）
- [ ] 在消息发送流程中集成格式转换（compose 发送前拦截，调用 `convertLatexForSending`）
- [ ] 处理边界情况：嵌套公式、公式中含 `$` 符号等

### 阶段四：体验优化

> 目标：打磨交互体验

- [ ] WebView 预加载，减少首次打开延迟
- [ ] 暗色模式适配（MathLive 主题与 Zulip 暗色模式同步）
- [ ] 公式插入动画反馈
- [ ] 边界场景完善（编辑消息模式、切换话题、页面失去焦点等）
- [ ] 双平台测试与适配（iOS/Android WebView 差异处理）

## 9. 参考资料

- [MathLive 官方文档](https://cortexjs.io/mathlive/)
- [MathLive VirtualKeyboard API](https://cortexjs.io/mathlive/virtual-keyboard/)
- [scrollable-keyboard 示例](file:///D:/vc/mathlive/examples/scrollable-keyboard/index.html)（**指定的 VK + math-field 模板**）
- [mathlive_studio 包源码](file:///D:/vc/mathlive_editor_package/flutter_mathlive_mixed/)（参考实现，非直接使用）
- [MathLive 库源码](file:///D:/vc/mathlive/)
- [Zulip Markdown 格式文档](https://zulip.com/help/format-your-message-using-markdown)

---

*文档版本：v5.0 · 更新时间：2026-07-03*
