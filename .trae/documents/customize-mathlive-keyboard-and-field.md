# 为 mathlive\_studio 包自定义 math-virtual-keyboard 与 math-field

## Context（背景）

`zulip-flutter` 项目通过 `pubspec.yaml` 依赖 `mathlive_studio` 包（[pubspec.yaml#L55](file:///d:/vc/zulip-flutter/pubspec.yaml#L55)）。该包的 HTML 模板 [mathlive\_editor.html](file:///d:/vc/mathlive_editor_package/flutter_mathlive_mixed/assets/mathlive/mathlive_editor.html) 当前使用 MathLive 默认的虚拟键盘布局，`<math-field>` 样式也是包内写死的。

用户参考 [d:/vc/mathlive/examples/scrollable-keyboard/index.html](file:///d:/vc/mathlive/examples/scrollable-keyboard/index.html) 中的实现，希望把以下两项自定义能力移植到 `mathlive_studio` 包中：

1. **自定义** **`math-virtual-keyboard`** **的 layouts**：包含 6 行自定义按键 + `fixedRows`，附加 `'numeric'`、`'symbols'`、`'alphabetic'`、`'greek'` 内置布局，每个按键支持 `variants`（长按变体）、`shift`（上档）、`class: 'small'`、`insert` 覆盖、中文 label 等。
2. **自定义** **`<math-field>`** **视觉样式**：去掉默认 border，改用蓝色 box-shadow 聚焦样式等。

预期结果：修改 `mathlive_studio` 包源码后，包内的编辑器（`MathLiveEmbeddedEditor` / `MathLiveEditorPage`）开箱即用使用新的键盘布局和样式。**不破坏**包现有的能力（toolbar、空格键拦截插入 `\ ` 、Enter 键插入换行、theme 切换、高度同步、`patchMathLiveEditorHtml` 占位符替换、`flutter` 端 postMessage 通信等）。

## 不在本次范围

* 不扩展 Dart API 让宿主可传入 layouts 配置（保持改动最小，layouts 直接 hardcode 在 HTML 模板里）。如后续需要可配置化，可参考 `patchMathLiveEditorHtml` 的占位符替换模式扩展。

* 不修改 `<math-field>` 的行为属性（`read-only`、`smart-mode`、`keybindings`、`locale` 等），仅改视觉样式。

* 不修改 `zulip-flutter` 项目的 `pubspec.yaml` 依赖方式（仍为 `^0.1.2`，从 pub.dev 拉取）。本次只改 `mathlive_editor_package` 包源码；用户若要在 zulip-flutter 中立即看到效果，需要自行切换为 `path` 或 `git` 依赖，或发布新版本到 pub.dev。

## 修改方案

### 唯一需要修改的文件

[mathlive\_editor.html](file:///d:/vc/mathlive_editor_package/flutter_mathlive_mixed/assets/mathlive/mathlive_editor.html)

### 改动点 1：替换 `<math-field>` 的 CSS（[L113-L123](file:///d:/vc/mathlive_editor_package/flutter_mathlive_mixed/assets/mathlive/mathlive_editor.html#L113-L123)）

参考 `scrollable-keyboard` 示例 [index.html#L37-L57](file:///d:/vc/mathlive/examples/scrollable-keyboard/index.html#L37-L57)，但保留包内现有的尺寸约束（`flex: 1 1 auto`、`min-height: 160px` 用于撑满 `#editor-shell`）。修改后的 `math-field` 规则：

```css
math-field {
  flex: 1 1 auto;
  width: 100%;
  min-height: 160px;
  font-size: 22px;
  border: none;                 /* 去掉默认 border，沿用示例 */
  outline: none;                /* 去掉浏览器默认聚焦轮廓 */
  border-radius: 12px;
  padding: 12px;
  box-sizing: border-box;
}
math-field:focus-within {
  outline: none;
  border-color: #0d80f2;        /* 蓝色聚焦（示例风格） */
  box-shadow: 0 0 0 2px rgba(13, 128, 242, 0.2);
}
```

替换原来的 `math-field:focus { outline: 2px solid #ff6200; ... }`（橙色 outline）。

暗色模式下的 `math-field` 规则（[L132-L137](file:///d:/vc/mathlive_editor_package/flutter_mathlive_mixed/assets/mathlive/mathlive_editor.html#L132-L137)）保持不变。

`@media (pointer: coarse)` 中 `math-field { font-size: 24px; min-height: 180px; }`（[L147](file:///d:/vc/mathlive_editor_package/flutter_mathlive_mixed/assets/mathlive/mathlive_editor.html#L147)）保持不变。

### 改动点 2：在 `mlMixedAttachVirtualKeyboard()` 中注入自定义 layouts（[L328-L361](file:///d:/vc/mathlive_editor_package/flutter_mathlive_mixed/assets/mathlive/mathlive_editor.html#L328-L361)）

在 `mlMixedAttachVirtualKeyboard` 函数开头、`container` 绑定**之前**，插入 `mathVirtualKeyboard.layouts = [...]`。逻辑：

```js
function mlMixedAttachVirtualKeyboard() {
  var vkRoot = document.getElementById('vk-root');
  if (typeof mathVirtualKeyboard === 'undefined') return;

  // ★ 新增：注入自定义 layouts（移植自 scrollable-keyboard 示例）
  try {
    mathVirtualKeyboard.layouts = mlMixedBuildLayouts();
  } catch (eLayout) {}

  // 原有逻辑保持不变：container 绑定 + geometrychange 监听
  if (vkRoot && !mlMixedIsInIframe()) {
    try { mathVirtualKeyboard.container = vkRoot; } catch (eContainer) {}
  }
  // ... 原有 geometrychange 监听不变 ...
}
```

### 改动点 3：新增 `mlMixedBuildLayouts()` 函数

在 `<script>` 块内（建议放在 `mlMixedAttachVirtualKeyboard` 函数之前，便于阅读），新增一个独立函数，返回 `scrollable-keyboard` 示例 [index.html#L91-L263](file:///d:/vc/mathlive/examples/scrollable-keyboard/index.html#L91-L263) 的 layouts 数组。函数体直接复制示例中的 layouts 定义，**保留**：

* 第一项：自定义 layer（`label: '常用'`，6 行 `rows` + 1 行 `fixedRows`，最后一行包含 `[return]` 按键，`command: 'performWithFeedback(commit)'`）

* 后续：`'numeric'`、`'symbols'`、`'alphabetic'`、`'greek'` 四个内置布局名

**注意**：示例中的注释（如 `// 第一行`、`// { class: 'small', latex: '\\frac{#@}{#?}' }, ...`）原样保留，便于后续维护。

### 改动点 4：调用时机

无需新增调用点。`mlMixedAttachVirtualKeyboard()` 已经在 init IIFE 中被多次调用（[L720](file:///d:/vc/mathlive_editor_package/flutter_mathlive_mixed/assets/mathlive/mathlive_editor.html#L720)、[L729](file:///d:/vc/mathlive_editor_package/flutter_mathlive_mixed/assets/mathlive/mathlive_editor.html#L729)、[L736-L737](file:///d:/vc/mathlive_editor_package/flutter_mathlive_mixed/assets/mathlive/mathlive_editor.html#L736-L737)），layouts 会在每次调用时设置。MathLive 对重复设置 `layouts` 是幂等的。

### 不改动的部分

* 顶部 toolbar（`#toolbar`、`#ml-btn-menu`、`#ml-btn-keyboard`）保持不变 —— 用户仍然通过 ⌨ 按钮显隐键盘。**不**调用 `mathVirtualKeyboard.show()` 让键盘默认显示（避免抢占屏幕空间，保留包现有交互模式）。

* `mlMixedFixKeys()` 中的空格键拦截、Enter 键拦截保持不变。

* `mlMixedOpenMenu()`、`mlMixedClampMenusToViewport()`、菜单 MutationObserver 保持不变。

* `patchMathLiveEditorHtml` 占位符替换逻辑（`MATHLIVE_MIXED_ROOT_ID` / `___MATHLIVE_MIXED_CLIENT___`）保持不变。

* postMessage 通信协议（`mlMixedPostToHost`、`mlMixedExportLatex`、`mlMixedSetLatex`、`mlMixedSetTheme`、`mlMixedNotifyHostChromeHeight`）保持不变。

* Dart 层（`MathLiveEmbeddedEditor`、`MathLiveEditorPage`、`MathLiveMixedTheme`）零改动。

## 验证方式

1. **静态检查**：修改后用浏览器直接打开 `mathlive_editor.html` 不行（依赖 Flutter JS bridge），但可以用 IDE 的 JS 语法检查确认无语法错误。
2. **运行 example 应用**：

   ```bash
   cd d:/vc/mathlive_editor_package/flutter_mathlive_mixed/example
   flutter pub get
   flutter run -d chrome    # 或 flutter run（iOS/Android）
   ```

   打开编辑器 tab，确认：

   * 虚拟键盘默认布局是"常用"（含数字 0-9、字母 A-Z、希腊字母变体、关系符、三角函数等）

   * 长按按键出现 variants 菜单（如长按 `[1]` 出现 `\frac{1}{#@}`、`{#@}^{-1}` 等）

   * 点 `[shift]` 按钮后，`A` 变 `α`、`B` 变 `β` 等

   * 切换到其他布局（numeric/symbols/alphabetic/greek）正常

   * `[return]` 按键能正常触发 `commit` 命令（导出 LaTeX）

   * `math-field` 聚焦时是蓝色 box-shadow，不再是橙色 outline

   * 暗色模式下编辑器样式正常

   * 空格键仍插入 `\ ` ，Enter 键仍插入换行

   * toolbar 的 ⌨ 按钮仍能显隐键盘
3. **在 zulip-flutter 中验证（可选）**：若用户切换为 path 依赖，启动 zulip-flutter，在消息编辑流程中触发 MathLive 编辑器，确认上述行为一致。

## 风险与回退

* **风险 1**：自定义 layouts 中的 `command: 'performWithFeedback(commit)'` 在不同 MathLive 版本下命令名可能不同。当前包锁定 `mathlive@0.101.2`（[L8](file:///d:/vc/mathlive_editor_package/flutter_mathlive_mixed/assets/mathlive/mathlive_editor.html#L8)），与 `scrollable-keyboard` 示例同源（`/dist/mathlive.mjs`），应能正常工作。若 `[return]` 按键无效，可降级为 `command: ['insert', '\n']` 或移除 command 仅保留 label。

* **风险 2**：layouts 中的 `insert` 字段（如 `\\text{平行四边形}`、`\\text{圆}`）依赖 MathLive 的 `\text` 命令解析，与 `mlMixedFixKeys` 的空格拦截无冲突。

* **回退方式**：本次只改一个文件（`mathlive_editor.html`）。回退只需 `git checkout` 该文件即可恢复原状。

