# 数学输入增强功能 Spec

## Why
高中生用户在 Zulip 聊天中频繁需要输入数学符号和公式，但系统键盘输入希腊字母、运算符号等非常不便；同时 Zulip 的 LaTeX 界定符（行内用 `$$`，独立用 `` ```math ``` ``）与通用 LaTeX 格式（行内用 `$`，独立用 `$$`）不同，导致从外部复制粘贴的公式无法正确渲染。需要提供数学符号快捷输入和 LaTeX 界定符自动转换两个功能来提升数学交流效率。

## What Changes
- 新增 LaTeX 界定符自动转换功能：发送消息时将通用 LaTeX 界定符自动转换为 Zulip 格式
- 新增数学符号工具栏：在输入框上方提供分类符号面板，支持 Unicode 符号和 LaTeX 片段快捷插入
- 新增"最近使用"符号记录功能
- 新增全局设置开关控制是否启用自动转换（默认开启）
- 更新版本号：`30.0.272-for-math.1` → `30.0.272-for-math.2`

## Impact
- Affected code:
  - `lib/widgets/compose_box.dart` — 发送按钮逻辑、工具栏按钮、工具栏 UI
  - `lib/model/settings.dart` — 新增 BoolGlobalSetting
  - `lib/widgets/settings.dart` — 设置页面 UI
  - `assets/l10n/app_en.arb` 等本地化文件 — 新增翻译字符串
  - `pubspec.yaml` — 版本号更新
  - `RELEASE_NOTES.md` — 版本号更新
  - `README.md` — 版本号更新
  - `.github/workflows/build-stable-release.yml` — 版本号更新
  - 新增 `lib/model/latex_converter.dart` — LaTeX 界定符转换逻辑
  - 新增 `lib/widgets/math_symbols/` — 数学符号工具栏相关组件

---

## ADDED Requirements

### Requirement: LaTeX 界定符自动转换

系统 SHALL 在发送新消息时，将输入内容中的通用 LaTeX 界定符自动转换为 Zulip 格式。

转换规则：
| 用户输入（通用格式） | 转换结果（Zulip 格式） | 说明 |
|---|---|---|
| `$...$` | `$$...$$` | 行内公式：单$ → 双$ |
| `$$...$$` | `` ```math\n...\n``` `` | 独立公式：双$ → math代码块 |
| `\(...\)` | `$$...$$` | LaTeX 行内 → Zulip 行内 |
| `\[...\]` | `` ```math\n...\n``` `` | LaTeX 独立 → math代码块 |

边界情况处理：
- 代码块（`` `...` `` 和 `` ```...``` ``）中的 `$` 不转换
- 已有的 `` ```math ... ``` `` 块不重复转换
- 转义的 `\$` 不作为界定符处理
- `$$...$$` 中内容包含换行时才转换为 `` ```math ``` ``，否则保持不变（可能是 Zulip 行内格式）

#### Scenario: 发送新消息时自动转换行内公式
- **GIVEN** 自动转换功能已开启
- **WHEN** 用户输入 `$E = mc^2$` 并点击发送
- **THEN** 发送的内容为 `$$E = mc^2$$`

#### Scenario: 发送新消息时自动转换独立公式
- **GIVEN** 自动转换功能已开启
- **WHEN** 用户输入 `$$\int_a^b f(x)dx$$` 并点击发送
- **THEN** 发送的内容为 `` ```math\n\int_a^b f(x)dx\n``` ``

#### Scenario: 编辑已有消息时不转换
- **GIVEN** 自动转换功能已开启
- **WHEN** 用户编辑一条已有消息并保存
- **THEN** 不对内容进行界定符转换（编辑时内容已经是 Zulip 格式）

#### Scenario: 自动转换功能关闭时不转换
- **GIVEN** 自动转换功能已关闭
- **WHEN** 用户输入 `$E = mc^2$` 并点击发送
- **THEN** 发送的内容为 `$E = mc^2$`（不转换）

#### Scenario: 代码块中的 $ 不转换
- **GIVEN** 自动转换功能已开启
- **WHEN** 用户输入 `` `price is $5` `` 并点击发送
- **THEN** 发送的内容为 `` `price is $5` ``（代码块内不转换）

### Requirement: LaTeX 自动转换设置开关

系统 SHALL 提供一个全局设置开关，控制是否在发送消息时自动转换 LaTeX 界定符。默认值为开启。

该设置存储为 `BoolGlobalSetting`，类型为 `GlobalSettingType.experimentalFeatureFlag`。

#### Scenario: 用户关闭自动转换
- **WHEN** 用户在设置中关闭"LaTeX 界定符自动转换"
- **THEN** 后续发送消息时不进行界定符转换

#### Scenario: 用户开启自动转换
- **WHEN** 用户在设置中开启"LaTeX 界定符自动转换"
- **THEN** 后续发送新消息时自动转换界定符

### Requirement: 数学符号工具栏

系统 SHALL 在输入框按钮行提供一个数学符号按钮，点击后在输入框上方展开符号工具栏。

工具栏包含以下分类标签：
- **常用**：函数（sin, cos, tan, log, ln, lim 等）、常用符号、LaTeX 快捷片段
- **希腊字母**：小写和大写希腊字母
- **运算符**：± × ÷ √ ∑ ∫ ∂ ∞ 等
- **关系符**：≠ ≤ ≥ ∥ ⊥ ∠ ≈ ≡ 等
- **集合**：∈ ∉ ⊆ ⊇ ∪ ∩ ∅ 等
- **公式模板**：\frac{}{}, \sqrt{}, \sum_{}^{}, \int_{}^{}, 行内/独立公式包裹等

#### Scenario: 打开数学符号工具栏
- **WHEN** 用户点击输入框按钮行的数学符号按钮
- **THEN** 输入框上方展开符号工具栏，默认显示"常用"分类

#### Scenario: 选择符号后工具栏保持打开
- **WHEN** 用户在工具栏中点击一个符号
- **THEN** 符号插入到光标位置，工具栏保持打开状态

#### Scenario: 关闭数学符号工具栏
- **WHEN** 用户再次点击数学符号按钮，或点击工具栏外部区域
- **THEN** 工具栏关闭

#### Scenario: 切换分类标签
- **WHEN** 用户点击不同的分类标签
- **THEN** 工具栏显示对应分类的符号

#### Scenario: 插入 LaTeX 模板并定位光标
- **WHEN** 用户点击 `\frac{}{}` 模板
- **THEN** 输入框插入 `\frac{}{}`，光标定位到第一个 `{}` 内部

### Requirement: 最近使用符号

系统 SHALL 在工具栏顶部显示用户最近使用的数学符号（最多10个），数据持久化到本地存储。

#### Scenario: 记录最近使用的符号
- **WHEN** 用户从工具栏中点击一个符号
- **THEN** 该符号被记录到最近使用列表的头部（去重）

#### Scenario: 显示最近使用的符号
- **WHEN** 用户打开数学符号工具栏
- **THEN** 工具栏顶部显示最近使用的符号（最多10个），若无记录则显示提示文字

### Requirement: 行内/独立公式一键包裹

系统 SHALL 在公式模板分类中提供行内公式和独立公式的包裹按钮。

#### Scenario: 包裹选中文字为行内公式
- **GIVEN** 用户在输入框中选中了文字 `x^2 + 1`
- **WHEN** 用户点击行内公式包裹按钮
- **THEN** 选中文字变为 `$$x^2 + 1$$`

#### Scenario: 无选中文字时插入空公式
- **GIVEN** 用户在输入框中未选中任何文字
- **WHEN** 用户点击行内公式包裹按钮
- **THEN** 在光标位置插入 `$$$$`，光标定位在两个 `$$` 之间

### Requirement: 版本号更新

系统 SHALL 将版本号从 `30.0.272-for-math.1` 更新为 `30.0.272-for-math.2`。

需要更新版本号的文件：
- `pubspec.yaml`：`version: 30.0.272-for-math.1+1` → `version: 30.0.272-for-math.2+1`
- `RELEASE_NOTES.md`：`v30.0.272-for-math.1` → `v30.0.272-for-math.2`
- `README.md`：`v30.0.272-for-math.1` → `v30.0.272-for-math.2`
- `.github/workflows/build-stable-release.yml`：默认版本号更新

#### Scenario: 版本号正确更新
- **WHEN** 所有功能开发完成
- **THEN** 上述4个文件中的版本号均已从 `30.0.272-for-math.1` 更新为 `30.0.272-for-math.2`
