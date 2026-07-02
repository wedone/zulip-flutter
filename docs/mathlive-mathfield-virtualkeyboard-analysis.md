# MathLive 项目分析 — 聚焦 math-field 与 VirtualKeyboard

> 本文档基于 `D:\VC\mathlive` 代码库，重点分析 `<math-field>` 自定义元素与虚拟键盘（VirtualKeyboard）的架构、API 与定制方式，并以 `examples/scrollable-keyboard/index.html` 为实例深入解读。

## 1. 项目概览

| 属性 | 说明 |
|------|------|
| 类型 | Web 数学公式编辑器库 |
| 语言 | TypeScript |
| 输出格式 | ES Module (`dist/mathlive.mjs`) |
| 自定义元素 | `<math-field>` — W3C Web Components 标准 |
| 渲染引擎 | 自研排版引擎（非 KaTeX/MathJax 依赖） |
| 计算引擎 | `@cortex-js/compute-engine` |
| 许可证 | 见 `LICENSE.txt` |

### 1.1 核心能力

- **所见即所得数学编辑**：基于 LaTeX 的实时渲染与编辑
- **虚拟键盘**：内置可定制的数学虚拟键盘，支持自定义布局、按键变体、fixedRows
- **多格式输入输出**：LaTeX、MathJSON、MathML、AsciiMath、语音朗读
- **Smart Mode**：自动在数学/文本模式间切换

## 2. 项目结构

```
mathlive/
├── src/
│   ├── public/                    ← 公共 API 类型定义
│   │   ├── mathfield-element.ts   ← MathfieldElement 自定义元素（核心）
│   │   ├── mathfield.ts           ← Mathfield 接口
│   │   ├── virtual-keyboard.ts    ← 虚拟键盘类型定义
│   │   ├── options.ts             ← MathfieldOptions / 键绑定
│   │   ├── core-types.ts          ← 基础类型（ParseMode, Style, Selection 等）
│   │   ├── commands.ts            ← 命令选择器类型
│   │   └── keyboard-layout.ts     ← 物理键盘布局
│   │
│   ├── virtual-keyboard/          ← 虚拟键盘实现
│   │   ├── virtual-keyboard.ts    ← VirtualKeyboard 类（核心实现）
│   │   ├── data.ts                ← 内置键盘布局数据（numeric, symbols 等）
│   │   ├── utils.ts               ← 键盘渲染、规范化、样式注入
│   │   ├── variants.ts            ← 按键变体面板（长按弹出）
│   │   ├── proxy.ts               ← iframe 场景下的代理
│   │   ├── global.ts              ← mathVirtualKeyboard 全局单例
│   │   ├── commands.ts            ← 键盘命令
│   │   └── mathfield-proxy.ts     ← MathfieldProxy 接口
│   │
│   ├── editor-mathfield/          ← Mathfield 内部实现
│   │   ├── mathfield-private.ts   ← _Mathfield 类（核心逻辑）
│   │   ├── options.ts             ← 选项获取/更新
│   │   ├── render.ts              ← 渲染与重绘
│   │   ├── keyboard-input.ts      ← 物理键盘输入处理
│   │   ├── pointer-input.ts       ← 指针/触摸输入
│   │   ├── mode-editor-math.ts    ← 数学模式编辑器
│   │   ├── mode-editor-text.ts    ← 文本模式编辑器
│   │   ├── mode-editor-latex.ts   ← LaTeX 模式编辑器
│   │   ├── styling.ts             ← 样式钩子
│   │   └── autocomplete.ts       ← 自动补全
│   │
│   ├── core/                      ← 排版引擎核心
│   │   ├── atom.ts                ← Atom 原子树
│   │   ├── box.ts                 ← Box 排版盒子
│   │   ├── parser.ts             ← LaTeX 解析器
│   │   ├── context.ts            ← 排版上下文
│   │   └── fonts.ts              ← 字体加载
│   │
│   ├── atoms/                     ← 各种 Atom 类型（约 25 种）
│   ├── editor/                    ← 编辑器基础
│   ├── editor-model/              ← 文档模型（选择、撤销等）
│   ├── ui/                        ← UI 组件
│   └── mathlive.ts                ← 库入口
│
├── css/
│   ├── mathfield.less             ← math-field 样式
│   ├── virtual-keyboard.less      ← 虚拟键盘样式（1123 行）
│   └── fonts.less                ← 字体样式
│
├── dist/
│   ├── mathlive.mjs               ← 构建产物（ES Module）
│   └── virtual-keyboard/          ← 键盘子资源
│
├── examples/
│   ├── scrollable-keyboard/       ← ★ 可滚动键盘示例
│   ├── custom-virtual-keyboard/   ← 自定义键盘示例
│   ├── draggable-virtual-keyboard/← 可拖拽键盘示例
│   └── ...
│
└── docs/
    └── Customizing the Virtual Keyboard.md  ← 虚拟键盘定制文档
```

## 3. `<math-field>` 自定义元素详解

### 3.1 类继承体系

```
HTMLElement
  └── MathfieldElement (src/public/mathfield-element.ts)
        ├── 内部持有 _Mathfield (src/editor-mathfield/mathfield-private.ts)
        │     └── 内部持有 Model (src/editor-model/)
        └── 通过 MathfieldElementAttributes 支持 HTML 属性
```

`MathfieldElement` 是对外的 Web Component，内部委托 `_Mathfield` 执行编辑逻辑。

### 3.2 核心 API

```typescript
// 获取/设置 LaTeX 值
mf.value: string                    // 获取 LaTeX
mf.value = '\\frac{1}{2}'           // 设置 LaTeX

// 选择与定位
mf.selection: Selection             // 获取选区
mf.position: Offset                 // 获取光标位置

// 模式控制
mf.defaultMode: 'math' | 'text' | 'inline-math'

// 虚拟键盘策略
mf.mathVirtualKeyboardPolicy: 'auto' | 'manual' | 'sandboxed'

// 输出格式
mf.getValue('latex')               // LaTeX
mf.getValue('math-json')            // MathJSON
mf.getValue('math-ml')             // MathML
mf.getValue('spoken-text')          // 语音文本

// 命令执行
mf.executeCommand('selectAll')
mf.executeCommand(['insert', '\\sqrt{#0}'])

// 选项
mf.readOnly: boolean
mf.smartMode: 'on' | 'off'
mf.smartFence: 'on' | 'off'
mf.smartSuperscript: 'on' | 'off'
```

### 3.3 自定义事件

| 事件名 | 时机 |
|--------|------|
| `mode-change` | 编辑模式切换（math/text/latex） |
| `mount` | 元素挂载到 DOM |
| `unmount` | 元素从 DOM 移除 |
| `move-out` | 光标移出边界（可 cancel） |
| `selection-change` | 选区变化 |
| `undo-state-change` | 撤销栈变化 |
| `before-virtual-keyboard-toggle` | 虚拟键盘即将显示/隐藏 |
| `virtual-keyboard-toggle` | 虚拟键盘已显示/隐藏 |
| `read-aloud-status-change` | 朗读状态变化 |

### 3.4 HTML 属性映射

| HTML 属性 | JS 属性 | 类型 |
|-----------|---------|------|
| `default-mode` | `defaultMode` | string |
| `read-only` | `readOnly` | boolean |
| `smart-mode` | `smartMode` | 'on'/'off' |
| `smart-fence` | `smartFence` | 'on'/'off' |
| `smart-superscript` | `smartSuperscript` | 'on'/'off' |
| `math-virtual-keyboard-policy` | `mathVirtualKeyboardPolicy` | VirtualKeyboardPolicy |
| `placeholder` | `contentPlaceholder` | string |
| `min-font-scale` | `minFontScale` | number |

### 3.5 CSS 伪部件（::part）

```css
math-field::part(menu-toggle) { display: none; }
math-field::part(virtual-keyboard-toggle) { display: none; }
```

用于隐藏默认的菜单按钮和键盘切换按钮。

## 4. VirtualKeyboard 详解

### 4.1 架构概览

```
┌──────────────────────────────────────────────────────┐
│  mathVirtualKeyboard (全局单例)                       │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Layout Toolbar (布局切换标签)                    │ │
│  │  [常用] [123] [符号] [abc] [αβγ]               │ │
│  ├─────────────────────────────────────────────────┤ │
│  │                                                  │ │
│  │  Layer (当前可见的键盘面板)                       │ │
│  │  ┌───────────────────────────────────────────┐  │ │
│  │  │  rows (可滚动区域)                          │  │ │
│  │  │  ┌─────┬─────┬─────┬─────┬─────┐         │  │ │
│  │  │  │ [0] │ [1] │ [2] │ ... │ [E] │  行1    │  │ │
│  │  │  ├─────┼─────┼─────┼─────┼─────┤         │  │ │
│  │  │  │ [5] │ [6] │ [7] │ ... │ [J] │  行2    │  │ │
│  │  │  ├─────┼─────┼─────┼─────┼─────┤         │  │ │
│  │  │  │ ... │ ... │ ... │ ... │ ... │  ...    │  │ │
│  │  │  └─────┴─────┴─────┴─────┴─────┘         │  │ │
│  │  └───────────────────────────────────────────┘  │ │
│  │  ┌───────────────────────────────────────────┐  │ │
│  │  │  fixedRows (固定在底部、不可滚动)            │  │ │
│  │  │  [+] [-] [*] [/] [=] │ [⇧] [⌫] [←] [→] [↵]│  │ │
│  │  └───────────────────────────────────────────┘  │ │
│  │                                                  │ │
│  ├─────────────────────────────────────────────────┤ │
│  │  Edit Toolbar (右侧编辑工具栏，可选)             │ │
│  └─────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

### 4.2 VirtualKeyboard 类

**文件**：`src/virtual-keyboard/virtual-keyboard.ts`

```typescript
class VirtualKeyboard implements VirtualKeyboardInterface, EventTarget {
  // 核心状态
  private _visible: boolean;
  private _element?: HTMLDivElement;
  private _shiftPressCount: 0 | 1 | 2;  // 0=未按, 1=下次生效, 2=Caps Lock
  
  // 键帽注册表（自定义键帽覆盖）
  private keycapRegistry: Record<string, Partial<VirtualKeyboardKeycap>>;
  
  // 核心方法
  show(options?: { animate: boolean }): void;
  hide(options?: { animate: boolean }): void;
  executeCommand(command): boolean;
  
  // 布局管理
  layouts: (VirtualKeyboardName | VirtualKeyboardLayout)[];
  currentLayer: string;
}
```

**全局访问**：

```javascript
// window.mathVirtualKeyboard 是全局唯一实例
mathVirtualKeyboard.show();
mathVirtualKeyboard.hide();
mathVirtualKeyboard.layouts = [...];
mathVirtualKeyboard.visible: boolean;
```

### 4.3 键盘策略（VirtualKeyboardPolicy）

| 值 | 行为 |
|-----|------|
| `'auto'` | 触控设备聚焦 math-field 时自动显示 |
| `'manual'` | 不自动显示，需手动调用 `show()` |
| `'sandboxed'` | 在当前 iframe 内显示（非顶层窗口） |

### 4.4 内置键盘布局名称

| 名称 | 标签 | 说明 |
|------|------|------|
| `'numeric'` | 123 | 数字 + 常用数学符号 |
| `'compact'` | 123 | 紧凑数字键盘 |
| `'minimalist'` | 123 | 极简键盘 |
| `'numeric-only'` | 123 | 仅数字 |
| `'symbols'` | Σ | 符号键盘 |
| `'alphabetic'` | abc | 字母键盘（自动检测 QWERTY/AZERTY/QWERTZ） |
| `'greek'` | αβγ | 希腊字母键盘 |

### 4.5 VirtualKeyboardKeycap — 按键定义

```typescript
interface VirtualKeyboardKeycap {
  label: string;         // 按键显示的 HTML 标记
  latex: string;         // LaTeX 片段（也是插入内容，除非指定 insert）
  insert: string;        // 插入的内容（优先于 latex）
  command: string | [];  // 按下时执行的命令
  key: string;           // 插入的键值
  class: string;         // CSS 类名（tex, small, action, separator 等）
  width: 0.5 | 1 | 1.5 | 2 | 5;  // 宽度倍数
  variants: (string | Partial<VirtualKeyboardKeycap>)[];  // 长按变体
  shift: string | Partial<VirtualKeyboardKeycap>;         // Shift 变体
  aside: string;         // 旁注说明
  layer: string;         // 按下后切换到的层
  stickyVariantPanel: boolean;  // 变体面板不自动关闭
}
```

**按键简写约定**：

| 简写 | 等价于 | 说明 |
|------|--------|------|
| `'[5]'` | `{ label: '5', latex: '5', key: '5' }` | 数字键 |
| `'[+]'` | `{ label: '+', latex: '+' }` | 运算符键 |
| `'[backspace]'` | 退格键 | 标准动作键 |
| `'[left]'` / `'[right]'` | 方向键 | 标准动作键 |
| `'[shift]'` | Shift 键 | 切换 shift 状态 |
| `'[return]'` | 回车键 | 标准动作键 |
| `'[separator-5]'` | 半宽分隔符 | 0.5 宽空白 |

### 4.6 VirtualKeyboardLayout — 布局定义

```typescript
type VirtualKeyboardLayout = VirtualKeyboardLayoutCore & (
  | { layers: (string | VirtualKeyboardLayer)[] }  // 多层布局
  | { rows: (string | Partial<VirtualKeyboardKeycap>)[][] }  // 简写：单层
  | { markup: string }  // 纯 HTML 标记
);

interface VirtualKeyboardLayoutCore {
  label?: string;          // 布局切换标签文字
  labelClass?: string;     // 标签 CSS 类
  tooltip?: string;        // 标签提示
  id?: string;             // 布局唯一标识
  displayShiftedKeycaps?: boolean;  // 是否显示 shift 变体
  displayEditToolbar?: boolean;     // 是否显示编辑工具栏
}
```

### 4.7 VirtualKeyboardLayer — 层定义

```typescript
interface VirtualKeyboardLayer {
  rows?: (Partial<VirtualKeyboardKeycap> | string)[][];    // 可滚动行
  fixedRows?: (Partial<VirtualKeyboardKeycap> | string)[][]; // 固定在底部的行
  markup?: string;     // 纯 HTML 标记
  style?: string;      // CSS 样式
  backdrop?: string;   // 背景CSS类
  container?: string;   // 容器CSS类
  id?: string;          // 层唯一标识
}
```

**关键特性 `fixedRows`**：这是 scrollable-keyboard 示例的核心，`fixedRows` 中的行固定在键盘底部，不随 `rows` 内容滚动。

### 4.8 Shift 状态机

```
_shiftPressCount:
  0 → 未按 Shift
  1 → Shift 仅对下一个字符生效（按一次 Shift）
  2 → Caps Lock 模式（连按两次 Shift）
```

## 5. scrollable-keyboard 示例深入分析

**文件**：`examples/scrollable-keyboard/index.html`

### 5.1 整体布局

```html
<body>
  <!-- 编辑器区域：flex=1，内容靠下对齐 -->
  <div class="editor-area">
    <math-field id="mf">x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}</math-field>
  </div>
  
  <script type="module">
    import '/dist/mathlive.mjs';
    // 虚拟键盘配置...
  </script>
</body>
```

**页面布局**：

```
┌────────────────────────────────────────────┐
│                                            │
│           .editor-area                     │
│         (flex: 1, 靠下对齐)                │
│                                            │
│  ┌──────────────────────────────────────┐  │
│  │         <math-field>                 │  │
│  │   x = (-b ± √(b²-4ac)) / 2a        │  │
│  └──────────────────────────────────────┘  │
│                                            │
├────────────────────────────────────────────┤
│         虚拟键盘 (永远显示)                │
│  ┌──────────────────────────────────────┐  │
│  │ rows (可滚动区域，6行)               │  │
│  │  行1: [0][1][2][3][4] │ [A][B]...[E] │  │
│  │  行2: [5][6][7][8][9] │ [F][G]...[J] │  │
│  │  行3: [.][(][)][<][>] │ [K][L]...[O] │  │
│  │  行4: ['][/][^][√][→] │ [P][Q]...[T] │  │
│  │  行5: [|][⊥][∠][△][∵] │ [U][V][x][y][z]│ │
│  │  行6: [∈][∋][∪][⇒][⇐] │ [sin][cos]... │ │
│  ├──────────────────────────────────────┤  │
│  │ fixedRows (固定在底部)               │  │
│  │  [+][-][*][/][=] │ [⇧][⌫][←][→][↵]  │  │
│  └──────────────────────────────────────┘  │
└────────────────────────────────────────────┘
```

### 5.2 CSS 关键技巧

```css
/* 1. body 使用 flex 纵向布局 */
body {
  display: flex;
  flex-direction: column;
  height: 100%;
}

/* 2. 编辑器区域撑满剩余空间，math-field 靠下对齐 */
.editor-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;  /* 靠下 */
  align-items: center;
}

/* 3. math-field 全宽无边框 */
math-field {
  font-size: 22px;
  width: 100%;
  border: none;
  outline: none;
  padding: 8px 12px;
}

/* 4. 隐藏默认的菜单和键盘切换按钮 */
math-field::part(menu-toggle) { display: none; }
math-field::part(virtual-keyboard-toggle) { display: none; }

/* 5. 虚拟键盘与 math-field 无缝连接 */
body > .ML__keyboard.is-visible > .MLK__backdrop {
  box-shadow: none;
  border-top: none;
}
```

### 5.3 虚拟键盘配置详解

```javascript
const mf = document.getElementById('mf');

// 1. 手动控制虚拟键盘（不自动弹出）
mf.mathVirtualKeyboardPolicy = 'manual';
mathVirtualKeyboard.show();

// 2. 自定义布局
mathVirtualKeyboard.layouts = [
  {
    label: '常用',
    layers: [
      {
        // 可滚动的6行
        rows: [ 行1, 行2, 行3, 行4, 行5, 行6 ],
        // 固定在底部、不可滚动的行
        fixedRows: [ 底部操作行 ],
      },
    ],
  },
  'numeric',     // 内置数字布局
  'symbols',     // 内置符号布局
  'alphabetic',  // 内置字母布局
  'greek',       // 内置希腊字母布局
];
```

### 5.4 自定义布局行详细解读

#### 行 1：数字 + 字母 A-E

```javascript
[
  // 数字 0，带变体和 shift
  {
    latex: '0',
    variants: ['∞', '\\propto', { latex: '×10}^{#0}', class: 'small' }],
    shift: '\\infty'
  },
  // [1] 带特殊变体
  { label: '[1]', variants: ['\\frac{1}{#@}', '{#@}^{-1}', '{#@}_1'] },
  { label: '[2]', variants: ['\\frac{1}{2}', '{#@}_2', '{#@}^2', '\\sqrt{2}'] },
  '[3]', '[4]',
  // 分隔符（0.5 宽）
  { class: 'separator', width: 0.5 },
  // 字母键，带希腊字母变体和 shift
  { label: "A", variants: ["a", "α"], shift: "α" },
  { label: "B", variants: ["b", "β"], shift: "β" },
  // ...
]
```

**设计思路**：左半区数字 + 右半区字母，中间用 `separator` 分隔。每个数字键长按弹出相关数学符号，每个字母键长按弹出希腊字母。

#### 行 4：运算 + 字母 P-T

```javascript
[
  { latex: '{#@}^{\\prime}', variants: ['{#@}^{\\doubleprime}', '{#@}°'] },
  { class: 'small', latex: '\\frac{#@}{#?}', variants: [...] },
  { latex: '{#@}^{\\placeholder{@0}}', variants: [...] },  // 上标/下标
  { latex: '\\sqrt{#0}', variants: ['\\sqrt{#@}'] },        // 平方根
  { latex: '\\overrightarrow{#0}', variants: ['\\vec{#0}'] }, // 向量
  { class: 'separator', width: 0.5 },
  // 字母 P-T...
]
```

**占位符语法**：
- `#@` — 当前选中的内容
- `#?` — 新的插入点
- `#0` — 整个表达式
- `\\placeholder{@0}` — 带标签的占位符

#### 行 5：几何符号 + 字母 U-Z

```javascript
[
  { latex: '|{#0}|', variants: ['||{#0}||'] },  // 绝对值/范数
  { latex: '\\perp', variants: ['∥', '\\not\\perp'] },  // 垂直/平行
  { label: '∠', variants: ['∡', '∢'] },         // 角度符号
  // 几何图形，用 insert 插入中文文本
  { latex: "\\triangle", insert: "△",
    variants: [
      { label: '▱', insert: '\\text{平行四边形}' },
      { label: '□', insert: '\\text{正方形}' },
      { label: '圆', insert: '\\text{圆}' },
    ]
  },
  // 因果符号
  { latex: '\\because', insert: '\\text{因为}',
    variants: [{ latex: '\\therefore', insert: '\\text{所以}' }]
  },
  // ...
]
```

**中文本地化**：使用 `insert: '\\text{因为}'` 将中文语义包装在 `\text{}` 中，确保 LaTeX 语法正确。

#### 行 6：集合/逻辑 + 三角函数

```javascript
[
  { latex: '∈', variants: ['⊆', '⊂', '\\notin'] },
  { latex: '∋', variants: ['⊇', '⊃'] },
  { latex: '∪', variants: ['∩', '∅'] },
  { latex: '⇒', variants: ['→', '⟺'] },
  { latex: '⇐', variants: ['←', '⇔'] },
  { class: 'separator', width: 0.5 },
  { latex: "\\sin", variants: [{ latex: '\\sin^{-1}', class: 'small' }, '\\arcsin'] },
  { latex: "\\cos", variants: [...] },
  { latex: "\\tan", variants: [...] },
  { latex: "\\log", variants: ['\\ln', '\\lg'] },
  { latex: '\\max', variants: ['\\min', "\\lim"] },
]
```

#### fixedRows — 固定操作行

```javascript
fixedRows: [
  ['[+]', '[-]', '[*]', '[/]',
    { label: '=', variants: ['≠', '∼', '≈', '≅', '≡'] },
    { class: 'separator', width: 0.5 },
    { label: '[shift]', width: 1 },
    { label: '[backspace]', width: 1 },
    '[left]',
    '[right]',
    { label: '[return]', width: 1 }
  ],
]
```

**fixedRows 特性**：
- 始终固定在键盘底部
- 不随 `rows` 区域滚动
- 适合放置高频操作键（运算符、方向键、退格、回车）
- 确保在任何滚动位置都能快速操作

### 5.5 variants（按键变体）机制

```
短按按键 → 插入 latex/insert/key 的值
长按按键 → 弹出变体面板，选择其他符号
Shift+按 → 插入 shift 值
```

**变体定义格式**：

```javascript
variants: [
  '\\infty',                              // 简写：同值 LaTeX
  { latex: '\\beta', label: 'beta' },    // 自定义标签
  { latex: '×10}^{#0}', class: 'small' }, // 带 CSS 类
]
```

### 5.6 虚拟键盘与 math-field 的连接

```
用户点击虚拟键盘按键
       ↓
VirtualKeyboard.executeCommand()
       ↓
_Commander → _Mathfield
       ↓
_Mathfield.model → 插入 LaTeX / 执行命令
       ↓
requestUpdate() → 重新渲染
       ↓
触发 'selection-change' / 'input' 事件
```

## 6. 虚拟键盘样式定制

### 6.1 CSS 变量覆盖

```css
.ML__keyboard {
  --keyboard-accent-color: #0c75d8;
  --keyboard-background: #cacfd7;
  --keyboard-border: #ddd;
  --keycap-background: #f0f0f0;
  --keycap-text: #000;
  /* ... 更多变量见 virtual-keyboard.less */
}
```

### 6.2 关键 CSS 类

| 类名 | 用途 |
|------|------|
| `.ML__keyboard` | 键盘容器 |
| `.ML__keyboard.is-visible` | 可见状态 |
| `.ML__keyboard.is-caps-lock` | Caps Lock 激活 |
| `.MLK__layer` | 键盘层 |
| `.MLK__layer.is-visible` | 当前可见层 |
| `.MLK__backdrop` | 层背景 |
| `.MLK__keycap` | 按键元素 |
| `.MLK__keycap.is-pressed` | 按下状态 |
| `.MLK__keycap.small` | 小号按键标签 |
| `.MLK__keycap.separator` | 分隔符 |
| `.MLK__keycap.action` | 动作键 |
| `.MLK__shift` | Shift 指示器 |

### 6.3 响应式断点

```less
@xs: (max-width: 414px);   // iPhone 5
@sm: (max-width: 744px);   // 手机
@md: (max-width: 768px);   // 手机横屏
@lg: (max-width: 1024px);  // 平板
```

## 7. iframe 场景下的虚拟键盘

### 7.1 架构

```
┌─ 顶层窗口 ──────────────────────────────────┐
│  VirtualKeyboard (实例)                      │
│  ├── 实际 DOM 渲染                           │
│  └── 通过 postMessage 与 Proxy 通信           │
│                                              │
│  ┌─ iframe ───────────────────────────────┐ │
│  │  VirtualKeyboardProxy                   │ │
│  │  ├── 代理接口，转发操作到顶层 VirtualKeyboard │ │
│  │  └── 通过 postMessage 通信              │ │
│  │                                         │ │
│  │  <math-field>                           │ │
│  └─────────────────────────────────────────┘ │
└──────────────────────────────────────────────┘
```

### 7.2 消息协议

| 动作 | 方向 | 说明 |
|------|------|------|
| `connect` | Proxy → VK | math-field 聚焦时连接 |
| `disconnect` | Proxy → VK | math-field 失焦时断开 |
| `execute-command` | Proxy → VK | 执行键盘命令 |
| `show` / `hide` | Proxy → VK | 显示/隐藏键盘 |
| `update-setting` | Proxy → VK | 更新配置 |
| `geometry-changed` | VK → Proxy | 键盘尺寸变化 |
| `synchronize-proxy` | VK → Proxy | 同步状态 |
| `update-state` | VK → Proxy | 更新 shift 状态 |

## 8. 与 zulip-flutter 数学增强版的关联

### 8.1 功能映射

| MathLive 能力 | zulip-flutter 对应 | 状态 |
|--------------|---------------------|------|
| `<math-field>` 编辑 | `ComposeBox` 内容输入 | 需适配 |
| VirtualKeyboard 自定义布局 | `lib/widgets/math_keyboard/` (6分类工具栏) | 已实现（Flutter 原生） |
| `fixedRows` 固定操作行 | 数学键盘底部操作区 | 可参考 |
| `variants` 长按变体 | 数学键盘符号变体 | 可参考 |
| LaTeX 渲染 | `flutter_math_fork` | 已实现（不同引擎） |
| KaTeX HTML 解析 | `lib/model/katex.dart` | 已实现 |
| Smart Mode | 无 | 潜在增强 |

### 8.2 可借鉴的设计模式

1. **fixedRows 模式**：数学键盘可借鉴 `fixedRows`，将运算符和方向键固定在底部，符号区域可滚动
2. **variants 变体面板**：长按弹出相关符号变体，减少键盘分类数量
3. **Shift 状态机**：一次 Shift 对下一个字符生效，两次 Shift 锁定大写
4. **占位符语法**：`#@`（当前选中）、`#?`（新插入点）可用于模板插入
5. **中文本地化**：通过 `insert: '\\text{因为}'` 方式在 LaTeX 中嵌入中文

## 9. 开发与构建

### 9.1 常用命令

| 任务 | 命令 |
|------|------|
| 开发服务器 | `./scripts/start.sh` |
| 构建 | `./scripts/build.sh` |
| 测试 | `./scripts/test.sh` |
| 清理 | `./scripts/clean.sh` |

### 9.2 关键依赖

| 依赖 | 用途 |
|------|------|
| `@cortex-js/compute-engine` | 数学计算引擎 |
| `typescript` | 编译 |
| `jest` | 单元测试 |
| `playwright` | E2E 测试 |
| `eslint` | 代码检查 |
| `less` | CSS 预处理 |

---

*文档生成时间：2026-07-02*
