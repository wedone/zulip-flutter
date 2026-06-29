# MathLive 虚拟键盘自定义指南

## 概述

MathLive 虚拟键盘（`<math-virtual-keyboard>`）由多层结构组成，支持从按键布局到视觉样式的全方位自定义。本文档涵盖两种自定义方式：

1. **运行时 API 自定义**（推荐）—— 通过 JavaScript 在 `mathlive_editor.html` 中覆盖布局
2. **CSS 变量自定义** —— 调整视觉样式

---

## 一、键盘结构层次

```
mathVirtualKeyboard
  ├── layouts[]              ← 布局列表（显示在切换栏）
  │   ├── { label: "abc", rows: [...] }    ← 单层布局（简写）
  │   └── { label: "123", layers: [...] }  ← 多层布局（完整）
  │       └── layer { rows: [...] }
  │           └── row [ keycap, keycap, ... ]
  │               ├── { latex: "\\alpha" }           ← 插入 LaTeX
  │               ├── { label: "⌫", command: ... }   ← 执行命令
  │               ├── "[backspace]"                  ← 内置快捷字符串
  │               └── "[separator-5]"                ← 分隔符
  └── visible / show() / hide()
```

### 内置布局

| 名称 | 标签 | 说明 |
|------|------|------|
| `"numeric"` | `123` | 数字 + 常用运算符 |
| `"symbols"` | 符号 | 数学符号 |
| `"alphabetic"` | `abc` | 字母（自动适配 qwerty/azerty 等） |
| `"greek"` | αβγ | 希腊字母 |
| `"minimalist"` | — | 精简布局，适合简单表达式 |

---

## 二、自定义布局（运行时 API）

### 2.1 设置布局列表

```javascript
// 只显示数字和字母两个布局
mathVirtualKeyboard.layouts = ["numeric", "alphabetic"];

// 恢复默认
mathVirtualKeyboard.layouts = "default";
```

### 2.2 定义完整自定义布局

```javascript
mathVirtualKeyboard.layouts = [
  {
    label: "自定义",       // 切换栏显示的文字
    rows: [
      // 第一行
      [
        { latex: "\\alpha" },
        { latex: "\\beta" },
        { latex: "\\gamma" },
        "[separator-5]",
        "[7]",
        "[8]",
        "[9]",
      ],
      // 第二行
      [
        "[shift]",
        { latex: "x", shift: "y" },
        { label: "⌫", command: "deleteBackward" },
      ],
      // 第三行
      [
        "[left]",
        "[right]",
        { label: "确定", command: "commit" },
      ],
    ],
  },
];
```

### 2.3 多层布局（带 Shift 层）

```javascript
mathVirtualKeyboard.layouts = [
  {
    label: "字母",
    layers: [
      {
        id: "lowercase",
        rows: [
          [
            { label: "a", shift: "A" },
            { label: "b", shift: "B" },
            { label: "c", shift: "C" },
            { label: "d", shift: "D" },
          ],
          [
            "[shift]",   // 按此键切换到 uppercase 层
            { label: "e", shift: "E" },
            "[backspace]",
          ],
        ],
      },
      {
        id: "uppercase",
        rows: [
          [
            { label: "A", shift: "a" },
            { label: "B", shift: "b" },
            { label: "C", shift: "c" },
          ],
          [
            "[shift]",   // 切回 lowercase
            "[backspace]",
          ],
        ],
      },
    ],
  },
];
```

---

## 三、按键（Keycap）属性参考

### 3.1 完整属性

```typescript
interface VirtualKeyboardKeycap {
  // 显示内容
  label: string;           // HTML 标签，如 "<i>&alpha;</i>"
  latex: string;           // LaTeX 表达式，同时作为标签和插入内容
  insert: string;          // 插入的文本（优先级高于 latex）
  key: string;             // 插入的单个字符（优先级最低）
  command: string | string[];  // 执行的命令（优先级最高）

  // 行为
  shift: string | Partial<VirtualKeyboardKeycap>;  // Shift 变体
  variants: (string | Partial<VirtualKeyboardKeycap>)[];  // 长按变体
  layer: string;           // 按此键跳转到指定 layer
  aside: string;           // 标签旁的辅助说明

  // 样式
  class: string;           // CSS 类名
  width: 0.5 | 1.0 | 1.5 | 2.0 | 5.0;  // 按键宽度倍数
  tooltip: string;         // 提示文字
  stickyVariantPanel: boolean;  // 长按面板不自动关闭
}
```

### 3.2 内置快捷字符串

| 字符串 | 效果 |
|--------|------|
| `"[shift]"` | Shift 键（切换大小写层） |
| `"[backspace]"` | 退格键 |
| `"[action]"` | 确认/回车键 |
| `"[left]"` / `"[right]"` | 左右方向键 |
| `"[separator-5]"` | 半宽分隔符（`w5`） |
| `"[0]"` ~ `"[9]"` | 数字键 |
| `"[+]"` / `"[-]"` / `"[*]"` / `"[/]"` | 运算符 |
| `"[(]"` / `"[)]"` | 括号 |
| `"[=]"` | 等号 |

### 3.3 常用命令

| 命令 | 效果 |
|------|------|
| `"deleteBackward"` | 删除前一个字符 |
| `"deleteForward"` | 删除后一个字符 |
| `"moveLeft"` / `"moveRight"` | 移动光标 |
| `"commit"` | 提交/确认 |
| `["insert", "\\alpha"]` | 插入指定 LaTeX |
| `["performWithFeedback", ["switchMode", "text", "", ""]]` | 切换文本模式 |

---

## 四、自定义 alphabetic 布局（字母键盘）

### 4.1 替换默认的字母布局

MathLive 内置的 alphabetic 布局由 `alphabeticLayout()` 函数动态生成（在 `src/virtual-keyboard/utils.ts` 中）。要完全替换，在 HTML 的 `<script>` 中设置：

```javascript
// 在 init 中覆盖
mathVirtualKeyboard.layouts = [
  {
    label: "abc",
    rows: [
      // 自定义顺序：a b c d e f g ...
      [
        { label: "a", shift: "A" },
        { label: "b", shift: "B" },
        { label: "c", shift: "C" },
        { label: "d", shift: "D" },
        { label: "e", shift: "E" },
        { label: "f", shift: "F" },
        { label: "g", shift: "G" },
        { label: "h", shift: "H" },
        { label: "i", shift: "I" },
        { label: "j", shift: "J" },
      ],
      [
        "[separator-5]",
        { label: "k", shift: "K" },
        { label: "l", shift: "L" },
        { label: "m", shift: "M" },
        { label: "n", shift: "N" },
        { label: "o", shift: "O" },
        { label: "p", shift: "P" },
        { label: "q", shift: "Q" },
        { label: "r", shift: "R" },
        "[separator-5]",
      ],
      [
        "[shift]",
        { label: "s", shift: "S" },
        { label: "t", shift: "T" },
        { label: "u", shift: "U" },
        { label: "v", shift: "V" },
        { label: "w", shift: "W" },
        { label: "x", shift: "X" },
        { label: "y", shift: "Y" },
        { label: "z", shift: "Z" },
        "[backspace]",
      ],
      [
        "[-]", "[+]", "[=]",
        { label: " ", width: 1.5 },
        { label: ",", shift: ";", class: "hide-shift" },
        "[.]",
        "[left]", "[right]",
        { label: "[action]", width: 1.5 },
      ],
    ],
  },
  // 保留其他布局
  "numeric",
  "symbols",
  "greek",
];
```

### 4.2 只保留自定义布局

```javascript
mathVirtualKeyboard.layouts = [
  {
    label: "abc",
    rows: [ /* 自定义行 */ ],
  },
];
```

---

## 五、CSS 视觉样式自定义

### 5.1 CSS 变量（推荐）

在 `mathlive_editor.html` 的 `<style>` 中覆盖：

```css
math-virtual-keyboard {
  /* 按键尺寸 */
  --keycap-height: 42px;
  --keycap-width: min(52px, 10vw);
  --keycap-max-width: 60px;
  --keycap-gap: 4px;

  /* 字体 */
  --keycap-font-size: 17px;
  --keycap-shift-font-size: 10px;
  --keycap-small-font-size: 11px;
  --keyboard-toolbar-font-size: 15px;

  /* 颜色 */
  --keycap-background: #f8fafc;
  --keycap-text-color: #0f172a;
  --keycap-border-color: #cbd5e1;
  --keyboard-background: #ffffff;

  /* 暗色主题 */
  --keycap-background-dark: #1e2532;
  --keycap-text-color-dark: #e2e8f0;
  --keycap-border-color-dark: #334155;
  --keyboard-background-dark: #141922;
}
```

### 5.2 常用 CSS 变量完整列表

| 变量 | 默认值 | 作用 |
|------|--------|------|
| `--keycap-height` | 52px | 按键高度 |
| `--keycap-width` | 计算值 | 按键宽度 |
| `--keycap-max-width` | 100px | 按键最大宽度 |
| `--keycap-gap` | 8px | 按键间距 |
| `--keycap-font-size` | 16px | 按键字体大小 |
| `--keycap-background` | — | 按键背景色 |
| `--keycap-text-color` | — | 按键文字颜色 |
| `--keycap-border-color` | — | 按键边框颜色 |
| `--keyboard-background` | — | 键盘面板背景色 |
| `--keyboard-padding-horizontal` | 8px | 键盘水平内边距 |

### 5.3 Shadow DOM 样式穿透

MathLive 虚拟键盘使用 Shadow DOM，需要通过 `::part()` 选择器：

```css
/* 隐藏键盘切换按钮 */
math-field::part(virtual-keyboard-toggle) {
  display: none !important;
}

/* 隐藏菜单按钮 */
math-field::part(menu-toggle) {
  display: none !important;
}
```

---

## 六、在 `mathlive_editor.html` 中的集成示例

```html
<script>
  // 在 init 之前定义自定义布局
  const kCustomLayouts = [
    {
      label: "abc",
      rows: [
        [
          { label: "我", latex: "\\text{我}" },
          { label: "的", latex: "\\text{的}" },
          { label: "公", latex: "\\text{公}" },
          { label: "式", latex: "\\text{式}" },
        ],
        [
          "[shift]",
          { latex: "\\alpha" },
          { latex: "\\beta" },
          { latex: "\\pi" },
          "[backspace]",
        ],
        [
          "[left]", "[right]",
          { label: "[action]", width: 1.5 },
        ],
      ],
    },
    "numeric",
    "symbols",
  ];

  (function init() {
    // 应用自定义布局
    mathVirtualKeyboard.layouts = kCustomLayouts;

    // 其余初始化代码...
    mlMixedEnsureMathModeSpace();
    mlMixedAttachVirtualKeyboard();
    // ...
  })();
</script>
```

---

## 七、注意事项

### 7.1 布局设置时机

`mathVirtualKeyboard.layouts` 必须在虚拟键盘**首次渲染之前**设置。建议在 `init()` 开头立即设置。

### 7.2 布局与 math-field 的关联

虚拟键盘是**全局单例**，所有 `math-field` 共享同一个键盘实例。如果不同编辑器需要不同布局，在 `focusin` 事件中切换：

```javascript
mf1.addEventListener("focusin", () => {
  mathVirtualKeyboard.layouts = ["numeric", "alphabetic"];
});
mf2.addEventListener("focusin", () => {
  mathVirtualKeyboard.layouts = ["minimalist"];
});
```

### 7.3 与内置布局混合

自定义布局可以和内置布局名称混用：

```javascript
mathVirtualKeyboard.layouts = [
  "numeric",          // 保留内置数字布局
  "symbols",          // 保留内置符号布局
  {                  // 自定义字母布局
    label: "abc",
    rows: [ /* ... */ ],
  },
];
```

### 7.4 修改源码 vs 运行时覆盖

| 方式 | 优点 | 缺点 |
|------|------|------|
| **运行时 API**（推荐） | 不改第三方库，升级友好 | 需在 JS 中写较多代码 |
| **修改 mathlive.min.js** | 可直接改内置布局 | 升级被覆盖，不推荐 |
| **CSS 变量** | 简单高效 | 只能调样式，不能改按键 |

---

## 八、参考资源

- MathLive 官方虚拟键盘指南：https://mathlive.io/mathfield/guides/virtual-keyboard/
- MathLive 虚拟键盘使用说明：https://mathlive.io/mathfield/virtual-keyboard/
- 源码位置：`/mnt/d/vc/mathlive/src/virtual-keyboard/`
  - `data.ts` — 内置布局定义（numeric, symbols, greek）
  - `utils.ts` — 布局规范化、alphabetic 布局生成
  - `virtual-keyboard.ts` — 键盘核心逻辑
  - `variants.ts` — 长按变体面板
- 项目中的 HTML 文件：`packages/mathlive_studio/assets/mathlive/mathlive_editor.html`
