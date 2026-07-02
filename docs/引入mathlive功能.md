# 引入 MathLive 数学公式输入功能

> 在 Zulip Flutter 会话界面的 ComposeBox 中集成 MathLive 的 `<math-field>` 编辑器与 VirtualKeyboard，使用户能够在移动端高效输入数学公式，并实时预览、一键插入到消息内容中。

## 1. 需求背景

### 1.1 痛点

高中学生在 Zulip 上讨论数学问题时，经常需要输入数学公式。当前移动端的系统键盘无法满足以下需求：

- **特殊符号缺失**：积分号 ∫、求和号 ∑、希腊字母 αβγ、集合符号 ∈⊆∪ 等在系统键盘上难以输入
- **结构化公式难以编辑**：分数 `\frac{}{}`、根号 `\sqrt{}`、上下标 `^{}_`、矩阵等嵌套结构，纯文本输入极其低效
- **无法所见即所得**：LaTeX 源码与渲染结果之间缺乏即时反馈，输入错误难以发现

### 1.2 现有数学增强（已完成）

项目已实现以下数学相关功能，新需求应与之协同：

| 功能 | 实现位置 | 说明 |
|------|----------|------|
| 消息中的公式渲染 | `lib/widgets/math_widget.dart` | 使用 `flutter_math_fork ^0.7.4`，纯 Dart KaTeX 渲染 |
| KaTeX HTML 解析 | `lib/model/katex.dart` | 从服务器渲染的 KaTeX HTML 提取 TeX 源码 |
| 消息列表中的公式显示 | `lib/widgets/content.dart` | 通过 `MathWidget` 渲染行内/行间公式 |

> **注意**：当前项目中 `lib/widgets/math_keyboard/` 和 `lib/model/latex_converter.dart` 等模块尚未实际落地（目录/文件不存在），本需求将直接引入 MathLive 作为数学输入的完整方案。

### 1.3 目标

在 ComposeBox 中增加"数学键盘"输入模式，使用户可以：

1. 切换到 MathLive 虚拟键盘，通过点击/长按输入数学符号和结构
2. 在 `<math-field>` 中所见即所得地编辑公式
3. 一键将编辑好的 LaTeX 公式插入到消息内容输入框中

## 2. 界面布局设计

### 2.1 原 Zulip 会话界面

```
┌─────────────────────────────────────────────┐
│  _MessageListAppBar                         │
│  ├─ 标题: 频道名 / 话题 / DM名 / 搜索框    │
│  └─ 操作按钮: 搜索 / 话题列表               │
├─────────────────────────────────────────────┤
│                                             │
│  Column(                                    │
│    Expanded(                                │
│      MessageList                            │
│        └─ 双 Sliver 滚动架构                │
│    ),                                       │
│    ComposeBox (条件渲染)                     │
│  )                                          │
│                                             │
├─────────────────────────────────────────────┤
│  ComposeBox                                 │
│  ├─ 话题输入框 (仅 ChannelNarrow)            │
│  ├─ 内容输入框 (_ContentInput, TextField)    │
│  └─ 操作按钮行: [附件] [图片] [相机] [发送]  │
└─────────────────────────────────────────────┘
```

### 2.2 新增 MathLive 后的布局（推荐方案）

```
其他不变
├─────────────────────────────────────────────┤
│  ComposeBox                                 │
│  ├─ 话题输入框 (仅 ChannelNarrow)            │
│  ├─ 内容输入框 (系统键盘)                    │
│  └─ 操作按钮行: [附件] [图片] [相机][🔢] [发送] │
├─────────────────────────────────────────────┤
│  MathLive 编辑面板 (条件显示)                │
│  ├─ <math-field> 公式编辑区                 │
│  │   └─ 所见即所得数学公式编辑              │
│  └─ VirtualKeyboard 虚拟键盘               │
│      ├─ Layout Toolbar: [常用][123][Σ][abc][αβγ] │
│      ├─ rows (可滚动符号区)                 │
│      └─ fixedRows (固定操作行: [+][-][*][/][=]│[⇧][⌫][←][→][return]) │
└─────────────────────────────────────────────┘
```
**采用 🔢 是方便描述，实际应用请使用 icon keyboard 图标**
> **方案选择理由**：`<math-field>` 和 VirtualKeyboard 作为一体显示/隐藏，放在 ComposeBox 下方。这样内容输入框保持原有行为（系统键盘输入文字），数学编辑面板作为独立区域出现，两者互不干扰。详见 [3.2 方案对比](#32-方案对比)。

### 2.3 布局状态切换

```
┌─ 系统键盘模式（默认）────────────────────────────────┐
│                                                       │
│  ┌─ MessageList ────────────────────────────────────┐ │
│  │  消息列表（系统键盘弹起时正常滚动）              │ │
│  └──────────────────────────────────────────────────┘ │
│  ┌─ ComposeBox ────────────────────────────────────┐ │
│  │  话题输入框                                      │ │
│  │  内容输入框 ◀── 系统键盘聚焦                     │ │
│  │  [附件][图片][相机][🔢] [发送]                   │ │
│  └──────────────────────────────────────────────────┘ │
│  ┌─ 系统键盘 ──────────────────────────────────────┐ │
│  └──────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────┘

┌─ 数学键盘模式 ────────────────────────────────────────┐
│                                                       │
│  ┌─ MessageList ────────────────────────────────────┐ │
│  │  消息列表（虚拟键盘弹起时正常滚动）              │ │
│  └──────────────────────────────────────────────────┘ │
│  ┌─ ComposeBox ────────────────────────────────────┐ │
│  │  话题输入框                                      │ │
│  │  内容输入框 ◀── 可接收公式插入                   │ │
│  │  [附件][图片][相机][🔢✓] [发送]                  │ │
│  └──────────────────────────────────────────────────┘ │
│  ┌─ MathLive 编辑面板 ─────────────────────────────┐ │
│  │  ┌─ <math-field> ─────────────────────────────┐ │ │
│  │  │  x = (-b ± √(b²-4ac)) / 2a           │ │ │
│  │  └────────────────────────────────────────────┘ │ │
│  │  ┌─ VirtualKeyboard ──────────────────────────┐ │ │
│  │  │  [常用][123][Σ][abc][αβγ]                  │ │ │
│  │  │  [0][1][2]...[E]  [A][B]...[E]            │ │ │
│  │  │  [+][-][*][/][=] │ [⇧][⌫][←][→][return]   │ │ │
│  │  └────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────┘
```

## 3. 功能需求详述

### 3.1 核心功能

#### F1：双输入模式切换

- ComposeBox 的内容输入框支持**两种输入方式**：系统键盘（默认）和 MathLive 虚拟键盘
- 两种输入方式**互斥**，同一时间只能激活一种
- 通过操作按钮行的 [🔢] 按钮切换

**切换规则**：

| 当前状态 | 用户操作 | 结果 |
|---------|---------|------|
| 系统键盘模式 | 点击 [🔢] 按钮 | 关闭系统键盘，显示 MathLive 编辑面板 |
| 数学键盘模式 | 点击 [🔢] 按钮（高亮态） | 隐藏 MathLive 编辑面板，回到系统键盘模式 |
| 数学键盘模式 | 点击内容输入框 | 可选行为（见 3.2 方案对比） |

#### F2：MathLive 虚拟键盘输入

- 虚拟键盘采用 MathLive 原生的 `<math-field>` + `VirtualKeyboard` 组件
- 支持自定义键盘布局，针对高中数学场景优化（见 [4. 键盘布局定制](#4-键盘布局定制)）
- 支持长按按键弹出变体面板（variants）
- 支持 Shift 键切换符号变体

#### F3：公式插入到内容输入框

- 在 MathLive 编辑面板的 `fixedRows` 中添加 **[插入]** 按键
- **短按 [插入]** → 以行内格式 `$...$` 插入公式
- **Shift + [插入]** → 以行间格式 `$$...$$` 插入公式
- 利用 VirtualKeyboard 按键原生的 `shift` 属性实现两种插入模式，无需自定义命令
- 插入格式遵循项目已有的 LaTeX 约定（见 [5. 数据流与格式转换](#5-数据流与格式转换)）
- 插入后 `<math-field>` 清空，可继续编辑下一个公式

> **为什么用 Shift 而不是长按/两个按键？** 详见 [3.3 行内与行间公式插入方案选型](#33-行内与行间公式插入方案选型)。

#### F4：公式预览

- `<math-field>` 本身提供所见即所得的实时渲染，无需额外预览组件
- 内容输入框中的 LaTeX 文本在消息列表中通过已有的 `MathWidget`（`flutter_math_fork`）渲染

### 3.3 行内与行间公式插入方案选型

LaTeX 公式分行内（`$...$`，文字中的小公式）和行间（`$$...$$`，独立居中显示的大公式）。需要在 [插入] 操作中区分这两种模式。以下是方案对比：

| 方案 | 交互方式 | 优点 | 缺点 |
|------|---------|------|------|
| **A. 短按/长按** | 短按→行内，长按→行间 | 只需一个按键 | ❌ MathLive 的长按机制是弹出 variants 面板，不能直接执行命令；❌ 与 VK 已有的"长按=变体"心智模型冲突；❌ 反馈不明确，用户不知道要按多久 |
| **B. 两个 command 按键** | [插入行内] + [插入行间] 两个独立按键 | 语义清晰 | ❌ 占两个按键位，挤占 fixedRows 空间；❌ 行内/行间是同一动作的变体，不应占两个独立位 |
| **C. Shift 变体（推荐）** | [插入] + Shift 切换 | ✅ 零学习成本（VK 的 Shift 机制用户已熟悉）；✅ 只占一个按键位；✅ Shift 后按键标签可动态更新为 `$$...$$`，反馈明确；✅ 无需注册自定义 command | 首次使用需发现 Shift 可以切换（但 VK 其他按键也有 Shift 变体，一致性高） |

**推荐方案 C**，实现方式如下：

#### 按键图标设计

行内/行间公式的按键采用 MathLive 内置标签风格，与 `[shift]`、`[backspace]` 等动作按键保持视觉一致：

| 状态 | 标签 | 含义 | 视觉语义 |
|------|------|------|----------|
| 默认（行内） | `[return]` | 插入行内公式 | 回车插入，公式嵌入文字行 |
| Shift（行间） | `↩️` | 插入行间公式 | 换行插入，公式独占一整行 |

> **设计思路**：`[return]` 是 MathLive 内置的确认/插入语义标签，自然地表达"将公式插入文字行"；Shift 状态切换为 `↩️`（回车箭头 emoji），暗示"另起一行插入"——与行间公式独占一行的含义吻合。

#### 代码实现

```javascript
// fixedRows 中的插入按键定义（替换原 [return]，width: 1）
{
  label: '[return]',       // 行内公式插入
  class: 'action',
  width: 1,
  command: 'insertInline',
  shift: {
    label: '↩️',            // 行间公式插入
    class: 'action',
    command: 'insertDisplay',
  }
}
```

当用户按下 Shift 后，按键标签从 `[return]` 变为 `↩️`，视觉反馈直观明确——一眼就能看出公式将从行内变为行间。

> **实现备注**：`command` 属性中的 `insertInline` / `insertDisplay` 是自定义命令，需要通过 MathLive 的 `register()` API 注册。这些命令内部通过 `JavascriptChannel` 向 Flutter 层传递公式，由 Flutter 层完成 TextField 的文本插入。详见 [6. 技术实现方案](#6-技术实现方案)。

### 3.4 方案对比

原始需求中提出了两种 `<math-field>` 的放置方案，这里进行详细对比：

| 维度 | 方案 A：math-field 在内容输入框内 | 方案 B：math-field 在 ComposeBox 下方（推荐） |
|------|----------------------------------|----------------------------------------------|
| **布局描述** | `<math-field>` 替代或嵌入 `_ContentInput` 的 `TextField` | `<math-field>` + `VirtualKeyboard` 作为独立面板在 ComposeBox 下方 |
| **交互模型** | 内容输入框本身变为数学编辑器 | 内容输入框保持纯文本，数学编辑是独立区域 |
| **系统键盘共存** | 需要处理 TextField 与 math-field 的焦点切换 | 自然分离，不需要焦点切换 |
| **混合内容输入** | 困难——数学/文字模式切换频繁 | 简单——文字用系统键盘，公式用 MathLive，互不干扰 |
| **实现复杂度** | 高——需要替换 Flutter TextField 为 WebView math-field | 中——新增独立 WebView 面板 |
| **用户体验** | 切换成本高，容易困惑 | 职责清晰，学习成本低 |
| **公式插入** | 不需要额外"插入"步骤，直接在内容中编辑 | 需要 [插入] 按钮将公式从 math-field 移到 TextField |

**推荐方案 B**，理由：

1. **职责分离**：系统键盘负责文字，数学键盘负责公式，符合用户心智模型
2. **实现更简单**：不需要替换 Flutter 原生的 `TextField`，只需要在下方增加一个 WebView 面板
3. **兼容性好**：不影响现有的 `_ContentInput`、`ComposeAutocomplete` 等组件逻辑
4. **与上游兼容**：对 `compose_box.dart` 的侵入性最小，便于合并上游更新

## 4. 键盘布局定制

### 4.1 高中数学定制布局

基于 MathLive 的 `layouts` API，定制适合高中数学的键盘布局：

```javascript
mathVirtualKeyboard.layouts = [
  {
    label: '常用',
    layers: [{
      rows: [
        // 行1: 数字 + 字母 A-E
        // 行2: 数字 + 字母 F-J
        // 行3: 基础运算 + 字母 K-O
        // 行4: 高级运算 + 字母 P-T
        // 行5: 几何符号 + 字母 U-Z
        // 行6: 集合/逻辑 + 三角函数
      ],
      fixedRows: [
        // 底部固定操作行: [+][-][*][/][=] │ [⇧][⌫][←][→][return]
      ],
    }],
  },
  'numeric',     // 内置数字布局
  'symbols',     // 内置符号布局
  'alphabetic',  // 内置字母布局
  'greek',       // 内置希腊字母布局
];
```

### 4.2 "常用"布局的按键分类

针对高中数学场景，"常用"布局的 6 行 `rows` 按功能分区：

| 行 | 左半区（数学符号） | 右半区（字母/函数） |
|----|-------------------|---------------------|
| 1 | 数字 0-4 | 字母 A-E（变体：希腊 α-ε） |
| 2 | 数字 5-9 | 字母 F-J（变体：希腊 ζ-θ） |
| 3 | 小数点、括号、比较符 | 字母 K-O（变体：希腊 κ-ο） |
| 4 | 导数、分数、指数、根号、向量 | 字母 P-T（变体：希腊 π-τ） |
| 5 | 绝对值、垂直、角度、三角形、因果 | 字母 U-Z（变体：希腊 υ-ω） |
| 6 | 集合、逻辑运算 | 三角函数、对数、极限 |

`fixedRows`（固定操作行）始终可见：

```
[+] [-] [*] [/] [=] │ [⇧] [⌫] [←] [→] [↵]
```

### 4.3 中文本地化按键

使用 MathLive 的 `insert` 属性实现中文数学语义的 LaTeX 插入：

```javascript
// 因果符号
{ latex: '\\because', insert: '\\text{因为}',
  variants: [{ latex: '\\therefore', insert: '\\text{所以}' }]
},
// 几何图形
{ latex: "\\triangle", insert: "△",
  variants: [
    { label: '▱', insert: '\\text{平行四边形}' },
    { label: '□', insert: '\\text{正方形}' },
    { label: '圆', insert: '\\text{圆}' },
  ]
},
```

## 5. 数据流与格式转换

### 5.1 公式插入流程

```
用户在 <math-field> 中编辑公式
       ↓
点击 fixedRows 中的 [return] 按键（行内）
   或 Shift + ↩️ 按键（行间）
       ↓
VK 执行自定义命令 insertInline / insertDisplay
       ↓
mf.getValue('latex') 获取 LaTeX 源码
       ↓
包装为 $...$（行内）或 $$...$$（行间）
       ↓
通过 InsertChannel.postMessage() 传递给 Flutter
       ↓
ComposeContentController.insertPadded() 或
ComposeContentController.insertionIndex()
       ↓
插入到内容输入框当前光标位置
       ↓
清空 <math-field>，用户继续编辑或发送
```

### 5.2 发送时的格式转换

Zulip 服务器使用非标准的 LaTeX 分隔符。发送消息时，需要进行以下转换（参考 `AGENTS.md` 中的 LaTeX auto-convert 描述）：

| 用户输入格式 | Zulip 服务器格式 | 说明 |
|-------------|----------------|------|
| `$...$` | ```` ```math ... ``` ``` | 行内公式 |
| `$$...$$` | ```` ```math ... ``` ``` | 行间公式 |
| `\(...\)` | 同上 | 行内公式（LaTeX 标准） |
| `\[...\]` | 同上 | 行间公式（LaTeX 标准） |

> **重要**：需要实现 `lib/model/latex_converter.dart` 模块，在发送时自动转换格式。同时需要处理 ZWSP（零宽空格）插入，以绕过服务器 `\B` 正则的限制。

### 5.3 消息渲染流程（已实现）

```
服务器返回 KaTeX HTML
       ↓
katex.dart 提取 TeX 源码（从 MathML annotation）
       ↓
MathWidget 使用 flutter_math_fork 渲染
       ↓
在消息列表中显示渲染后的公式
```

## 6. 技术实现方案

### 6.1 架构选择：WebView 嵌入 MathLive

MathLive 是一个 Web Components 库（`<math-field>` 自定义元素），无法直接在 Flutter 原生组件中使用。需要通过 **WebView** 桥接：

```
Flutter 层                              Web 层（WebView）
┌──────────────────┐                    ┌──────────────────────┐
│  ComposeBox      │                    │  <math-field>        │
│  ├─ TextField    │    JS Channel      │  ├─ 公式编辑区       │
│  ├─ [🔢] 按钮    │ ◄───────────────►  │  └─ [插入] 按钮     │
│  └─ [发送] 按钮  │                    │  VirtualKeyboard     │
│                  │                    │  └─ 自定义布局        │
└──────────────────┘                    └──────────────────────┘
```

### 6.2 关键技术组件

| 组件 | 技术 | 说明 |
|------|------|------|
| MathLive 加载 | WebView + 本地 HTML | 将 MathLive 的 `dist/` 资源打包到 `assets/` 中，WebView 加载本地 HTML |
| 双向通信 | `JavascriptChannel`（Flutter→JS）+ `evaluateJavascript`（JS→Flutter） | 公式插入、模式切换、状态同步 |
| 虚拟键盘策略 | `mathVirtualKeyboardPolicy: 'manual'` | 不自动弹出，由 [🔢] 按钮控制 |
| 键盘布局配置 | JS 注入 `mathVirtualKeyboard.layouts = [...]` | 在 WebView 初始化时注入自定义布局 |
| 公式插入 | `insertInline` / `insertDisplay` 自定义命令 → JS Channel → Flutter | Shift 区分行内 `$...$` / 行间 `$$...$$` |

### 6.3 WebView HTML 模板

```html
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      display: flex;
      flex-direction: column;
      font-family: sans-serif;
    }
    math-field {
      font-size: 20px;
      width: 100%;
      border: none;
      outline: none;
      padding: 8px 12px;
      min-height: 48px;
    }
    math-field::part(menu-toggle) { display: none; }
    math-field::part(virtual-keyboard-toggle) { display: none; }
  </style>
</head>
<body>
  <math-field id="mf" math-virtual-keyboard-policy="manual"></math-field>
  <script type="module">
    import './mathlive.mjs';

    // 注册自定义命令：插入行内/行间公式
    // （register 是 MathLive 暴露的命令注册 API）
    import { register } from './mathlive.mjs';

    register({
      insertInline: () => {
        const latex = document.getElementById('mf').getValue('latex');
        if (latex) {
          InsertChannel.postMessage('$' + latex + '$');
          document.getElementById('mf').value = '';
        }
        return false;
      },
      insertDisplay: () => {
        const latex = document.getElementById('mf').getValue('latex');
        if (latex) {
          InsertChannel.postMessage('$$' + latex + '$$');
          document.getElementById('mf').value = '';
        }
        return false;
      },
    }, { target: 'virtual-keyboard' });

    const mf = document.getElementById('mf');

    // 注入自定义布局（高中数学定制）
    mathVirtualKeyboard.layouts = [
      {
        label: '常用',
        layers: [{
          rows: [ /* ... 6行 ... */ ],
          fixedRows: [
            ['[+]', '[-]', '[*]', '[/]',
              { label: '=', variants: ['≠', '∼', '≈', '≅', '≡'], shift: '≈' },
              { class: 'separator', width: 0.5 },
              { label: '[shift]', width: 1 },
              { label: '[backspace]', width: 1 },
              '[left]',
              '[right]',
              // ★ [插入]按键：替换原 [return]，默认行内，Shift 行间
              // [return] = 行内插入 | ↩️ = 行间插入
              {
                label: '[return]',
                class: 'action',
                width: 1,
                command: 'insertInline',
                shift: {
                  label: '↩️',
                  class: 'action',
                  command: 'insertDisplay',
                },
              },
            ],
          ],
        }],
      },
      'numeric', 'symbols', 'alphabetic', 'greek',
    ];

    // 显示虚拟键盘
    mathVirtualKeyboard.show();

  </script>
</body>
</html>
```

### 6.4 Flutter 侧集成点

需要修改的核心文件：

| 文件 | 改动 | 说明 |
|------|------|------|
| `lib/widgets/compose_box.dart` | 添加 [🔢] 按钮 + MathLive 面板 Widget | 在操作按钮行新增切换按钮，在 ComposeBox 下方条件渲染 WebView 面板 |
| `lib/widgets/compose_box.dart` | `_ContentInput` 集成公式插入 | 接收 JS Channel 传来的 LaTeX 字符串，在光标位置插入 |
| `lib/model/latex_converter.dart` | **新建** | 发送时 LaTeX 格式转换 + ZWSP 插入 |
| `assets/mathlive/` | **新建目录** | MathLive 库文件 + 本地 HTML 模板 |
| `pubspec.yaml` | 添加 `webview_flutter` 依赖 | WebView 组件 |
| `lib/widgets/math_live_panel.dart` | **新建** | MathLive WebView 面板的 Widget 封装 |

### 6.5 状态管理

在 `ComposeBoxState` 中管理数学键盘的显示状态：

```dart
// 新增状态
ValueNotifier<bool> mathKeyboardVisible = ValueNotifier(false);

// 切换逻辑
void toggleMathKeyboard() {
  final newValue = !mathKeyboardVisible.value;
  if (newValue) {
    // 切换到数学键盘：关闭系统键盘
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
  mathKeyboardVisible.value = newValue;
}

// 公式插入回调
void onFormulaInserted(String latex) {
  final controller = this.controller;
  final insertionPoint = controller.content.insertionIndex();
  controller.content.value = TextEditingValue(
    text: controller.content.text.replaceRange(
      insertionPoint.start, insertionPoint.end, latex),
    selection: TextSelection.collapsed(
      offset: insertionPoint.start + latex.length),
  );
}
```

## 7. 交互流程

### 7.1 正常使用流程

```
1. 用户在 ComposeBox 的内容输入框中打字（系统键盘）
2. 用户需要输入数学公式
3. 点击 [🔢] 按钮
   → 系统键盘收起
   → MathLive 编辑面板从底部滑入
   → [🔢] 按钮变为高亮/选中态
4. 用户在 <math-field> 中通过虚拟键盘编辑公式
   → 实时看到渲染后的公式
5. 点击 fixedRows 中的 [return] 按键（替换原回车键位置）
   → 以行内公式格式 `$...$` 插入到内容输入框的光标位置
   → <math-field> 清空，可继续编辑下一个公式
6. （可选）需要行间公式时，先按 [⇧] 再按 ↩️ 按键
   → 以行间公式格式 `$$...$$` 插入
7. 用户可继续在 <math-field> 中编辑更多公式并插入
8. 再次点击 [🔢] 关闭数学面板
   → MathLive 编辑面板滑出
   → [🔢] 按钮恢复正常态
9. 用户点击 [发送] 发送消息
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
| 插入公式时光标在已有文字中间 | 在光标位置插入，前后不加额外空格（LaTeX 的 `$` 已自然分隔） |

## 8. 约束与风险

### 8.1 技术约束

| 约束 | 影响 | 应对策略 |
|------|------|---------|
| MathLive 是 Web Components，无法直接在 Flutter 中使用 | 必须通过 WebView 桥接 | 使用 `webview_flutter` 包，本地加载 MathLive 资源 |
| WebView 与 Flutter 的通信有延迟 | 公式插入可能有轻微延迟 | 使用 `JavascriptChannel` 的 `postMessage` 机制，延迟通常 < 50ms |
| WebView 在 iOS/Android 上行为不一致 | 需要双平台测试 | 使用 `webview_flutter` 跨平台抽象层 |
| MathLive 库体积较大（~2MB） | 增加应用安装包大小 | 仅打包 `dist/mathlive.mjs` 和必需的字体/CSS |
| 系统键盘与虚拟键盘互斥 | 需要精确控制键盘显示/隐藏 | 切换时先 `unfocus()` + `TextInput.hide()`，再显示 WebView 面板 |

### 8.2 性能风险

| 风险 | 严重性 | 缓解措施 |
|------|--------|---------|
| WebView 初始化耗时 | 中 | 预加载 WebView（可在页面进入时创建但隐藏） |
| 虚拟键盘按键响应延迟 | 低 | MathLive 原生键盘性能良好，本地加载无网络延迟 |
| WebView 内存占用 | 中 | 关闭面板时销毁 WebView 控制器 |
| 首次加载 MathLive JS | 中 | 将资源打包为本地 assets，避免网络请求 |

### 8.3 与上游的兼容性

| 考虑点 | 说明 |
|--------|------|
| `compose_box.dart` 改动 | 侵入性控制在最低：新增 [🔢] 按钮 + 条件渲染面板 Widget |
| `_ContentInput` 改动 | 仅新增公式插入方法，不修改现有逻辑 |
| 上游合并冲突 | 新增代码集中在尾部/独立 Widget，减少冲突面 |
| `flutter_math_fork` 渲染 | 不受影响——WebView 中的 MathLive 仅用于输入，消息渲染仍用 `flutter_math_fork` |

## 9. 实现路线

### 阶段一：最小可用（MVP）

- [ ] 在 `assets/mathlive/` 中准备 MathLive 本地资源
- [ ] 实现 `MathLivePanel` Widget（WebView 封装）
- [ ] 在 ComposeBox 操作按钮行添加 [🔢] 切换按钮
- [ ] 实现基本的公式插入功能（`$...$` 行内 + Shift `$$...$$` 行间）
- [ ] 使用 MathLive 默认键盘布局

### 阶段二：高中数学定制

- [ ] 定制"常用"布局（6 行 rows + fixedRows）
- [ ] 添加中文本地化按键（因为/所以/平行四边形等）
- [ ] 实现 `latex_converter.dart`（发送时格式转换 + ZWSP 插入）

### 阶段三：体验优化

- [ ] WebView 预加载，减少首次打开延迟
- [ ] 公式插入动画反馈
- [ ] 最近使用符号/公式历史
- [ ] 暗色模式适配（MathLive CSS 变量覆盖）

## 10. 参考资料

- [MathLive 官方文档](https://cortexjs.io/mathlive/)
- [MathLive VirtualKeyboard API](https://cortexjs.io/mathlive/virtual-keyboard/)
- [MathLive scrollable-keyboard 示例](file:///D:/VC/mathlive/examples/scrollable-keyboard/index.html)
- [Zulip Flutter 会话界面布局分析](./zulip-flutter-chat-layout-analysis.md)
- [MathLive math-field 与 VirtualKeyboard 分析](./mathlive-mathfield-virtualkeyboard-analysis.md)
- [Zulip Markdown 格式文档](https://zulip.com/help/format-your-message-using-markdown)
- [webview_flutter 包](https://pub.dev/packages/webview_flutter)

---

*文档版本：v2.0 · 更新时间：2026-07-02*
