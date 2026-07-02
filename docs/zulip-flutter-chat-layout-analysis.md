# Zulip Flutter 会话界面布局分析

> 本文档基于 `zulip-flutter` 数学增强版代码库，重点分析会话界面的布局结构、组件层级与数据流。

## 1. 项目概览

| 属性 | 说明 |
|------|------|
| 类型 | 移动端跨平台聊天应用（Flutter） |
| 语言 | Dart |
| 框架版本 | Flutter main channel（非 stable/beta） |
| 上游仓库 | [zulip/zulip-flutter](https://github.com/zulip/zulip-flutter) |
| 数学增强 | `flutter_math_fork ^0.7.4`、KaTeX 解析、数学键盘、LaTeX 预览 |
| 最低服务器 | Zulip Server 7.0（feature level 185） |
| 版本方案 | `30.0.272-math-vX.Y+Z` |

## 2. 应用入口与导航

### 2.1 启动流程

```
main.dart → mainInit() → runApp(ZulipApp())
                              ↓
                     ZulipApp (app.dart)
                              ↓
                     MaterialApp + Navigator
                              ↓
                     ChooseAccountPage / HomePage
```

### 2.2 导航体系

应用使用 `MaterialAccountWidgetRoute` 包装页面路由，每个路由绑定一个账户 ID，确保页面内的 `PerAccountStoreWidget` 能获取正确的账户数据。

**主要导航路径：**

```
HomePage (底部导航)
  ├── InboxPageBody (收件箱)
  ├── SubscriptionListPageBody (频道列表)
  └── RecentDmConversationsPageBody (私聊列表)
      │
      ├──→ MessageListPage (频道/话题/DM/搜索)
      │       ├── AppBar (标题/搜索)
      │       ├── MessageList (消息列表)
      │       └── ComposeBox (输入框)
      │
      ├──→ TopicListPage (话题列表)
      ├──→ ProfilePage (个人资料)
      ├──→ SettingsPage (设置)
      └──→ AboutZulipPage (关于)
```

## 3. 会话界面整体布局

### 3.1 页面骨架（MessageListPage）

`MessageListPage` 是所有会话视图的统一页面，通过不同的 `Narrow` 类型展示不同内容。

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
│  ├─ 内容输入框                              │
│  └─ 操作按钮行: [附件] [图片] [相机] [发送]  │
└─────────────────────────────────────────────┘
```

### 3.2 关键源文件位置

| 组件 | 文件路径 |
|------|----------|
| 主页面 | `lib/widgets/home.dart` |
| 会话页面 | `lib/widgets/message_list.dart` |
| 输入框 | `lib/widgets/compose_box.dart` |
| 消息内容渲染 | `lib/widgets/content.dart` |
| 数学公式组件 | `lib/widgets/math_widget.dart` |
| 应用根组件 | `lib/widgets/app.dart` |
| Narrow 定义 | `lib/model/narrow.dart` |
| 消息列表模型 | `lib/model/message_list.dart` |
| 状态管理 | `lib/model/store.dart` |
| 消息定义 | `lib/model/message.dart` |

## 4. 消息列表（MessageList）详细分析

### 4.1 双 Sliver 架构

消息列表采用上下两个 Sliver 实现"从中间向两端"的无限滚动加载：

```
MessageListScrollView (center: centerSliverKey)
  ├── topSliver (SliverStickyHeaderList)
  │     ├── child 0: 最近一条中间消息
  │     ├── child 1: 更早的消息
  │     ├── ...
  │     └── child N: _buildStartCap() (历史起点/加载指示器)
  │
  └── bottomSliver (SliverStickyHeaderList, key=centerSliverKey)
        ├── child 0: 紧跟中间消息之后的消息
        ├── child 1: 更新的消息
        ├── ...
        └── child N: _buildEndCap() (TypingStatus + MarkAsRead + 间距)
```

**关键常量：**

| 常量 | 值 | 说明 |
|------|----|------|
| `maxContentWidth` | 760 | 消息和输入框内容最大宽度（居中） |
| `kFetchMessagesBufferPixels` | ~4000 | 触发预加载的滚动距离 |
| `_kShortMessageHeight` | 80 | 短消息近似高度（用于计算预加载缓冲） |

### 4.2 消息项（MessageItem）布局

```
StickyHeaderItem
  └─ Stack
       ├── Column
       │     ├── (如果是首条/换发送者) SenderRow
       │     │     ├── Avatar (32px, borderRadius: 3)
       │     │     ├── 发送者名称 (18px, wght: 600)
       │     │     ├── UserStatusEmoji
       │     │     ├── Bot图标 (15px)
       │     │     └── 时间戳 (16px, small-caps)
       │     │
       │     └── Row (消息内容行)
       │           ├── SizedBox(width: 16) — 左缩进
       │           ├── Expanded
       │           │     └── Column
       │           │           ├── MessageContent (渲染的HTML)
       │           │           ├── ReactionChipsList (表情回应)
       │           │           └── 编辑状态文字
       │           └── SizedBox(width: 16) — 星标占位
       │
       └── _UnreadMarker (左侧4px蓝色条, 动画渐隐)
```

### 4.3 收件人头（RecipientHeader）

**频道消息头（StreamMessageRecipientHeader）：**

```
ColoredBox(频道色背景)
  └── Row
        ├── streamWidget (频道图标+名称+箭头) 或 SizedBox(width:16)
        ├── Expanded → topicWidget (话题名+可见策略图标)
        └── RecipientHeaderDate (日期, small-caps)
```

**私聊消息头（DmRecipientHeader）：**

```
ColoredBox(dmRecipientHeaderBg)
  └── Padding(vertical: 11)
        └── Row
              ├── Icon(two_person, 16px)
              ├── Expanded → Text("You and XXX")
              └── RecipientHeaderDate
```

### 4.4 日期分隔符（DateSeparator）

```
Row
  ├── Expanded → 分隔线
  ├── DateText (small-caps, "Today" / "Yesterday" / "Dec 2")
  └── SizedBox(width:12) → 短分隔线
```

### 4.5 滚动与标记已读

- `MessageListScrollController` 监听滚动位置
- `_findMessagesInViewport()` 遍历 widget 树，找到当前可见的消息 ID 范围
- `_markReadFromScroll()` 计算可见范围与上次的"凸包"，批量标记已读
- `ScrollToBottomButton` 在非底部时显示，支持平滑滚动或跳转

## 5. 输入框（ComposeBox）详细分析

### 5.1 三种模式

| 模式 | 控制器 | 使用场景 | 话题输入 | 发送按钮 |
|------|--------|---------|---------|---------|
| 频道输入 | `StreamComposeBoxController` | `ChannelNarrow` | ✅ | ✅ |
| 固定目标输入 | `FixedDestinationComposeBoxController` | `TopicNarrow` / `DmNarrow` | ❌ | ✅ |
| 编辑消息 | `EditMessageComposeBoxController` | 长按消息→编辑 | ❌ | ❌ (保存/取消在banner) |

### 5.2 输入框布局

```
_ComposeBoxContainer
  ├── _Banner (可选, 如"未订阅频道"提示)
  └── SafeArea
        └── _ComposeBoxBody
              ├── ConstrainedBox(maxWidth: 760)
              │     └── Column
              │           ├── Padding(horizontal: 8)
              │           │     └── Column
              │           │           ├── _TopicInput (仅频道模式)
              │           │           │     ├── TopicAutocomplete
              │           │           │     └── TextField (20px, wght:600)
              │           │           └── _ContentInput
              │           │                 ├── InsetShadowBox (上下渐隐)
              │           │                 └── TextField (17px, minLines:2)
              │           │
              │           └── SizedBox(height: 44) — 按钮行
              │                 └── Row
              │                       ├── [_AttachFileButton] [_AttachMediaButton] [_AttachFromCameraButton]
              │                       └── [_SendButton]
              │
```

### 5.3 内容输入框特性

- **最大高度**：178px（1x 文字缩放），267px（≥1.5x 缩放）
- **最少行数**：2 行（增大触控面积）
- **InsetShadowBox**：上下各 8px 的渐隐阴影，滚动内容自然淡出
- **ClipRect**：替代 TextField 自带裁剪，配合 InsetShadowBox

### 5.4 话题输入交互状态机

```
                    (默认)
 话题输入             │          内容输入
 失去焦点             ▼          获得焦点
┌────────────► notEditingNotChosen ────────────┐
│                                 │            │
│         话题输入                │            │
│         获得焦点                │            │
│       ◄─────────────────────────┘            ▼
 isEditing ◄───────────────────────────── hasChosen
   │         焦点从内容移到话题              │ │     ▲
   │                                      │ │     │
   └──────────────────────────────────────┘ └─────┘
    焦点从话题移到内容                   内容失去焦点但话题未获得
```

## 6. Narrow 类型与界面差异

### 6.1 Narrow 类型映射表

| Narrow 类型 | 有输入框 | AppBar 样式 | 消息头 | 点击消息 |
|------------|---------|------------|--------|---------|
| `CombinedFeedNarrow` | ❌ | "Combined feed" + 搜索按钮 | 频道+话题 | 无 |
| `ChannelNarrow` | ✅ (话题+内容) | 频道名 (单行居中) | 仅话题 | 无 |
| `TopicNarrow` | ✅ (仅内容) | 频道名+话题名 (两行) | 可省略 | 无 |
| `DmNarrow` | ✅ (仅内容) | 对方名字 | 可省略 | 无 |
| `MentionsNarrow` | ❌ | "Mentions" | 频道+话题 | → 跳转会话 |
| `StarredMessagesNarrow` | ❌ | "Starred messages" | 频道+话题 | → 跳转会话 |
| `KeywordSearchNarrow` | ❌ | 搜索输入框 | 频道+话题 | → 跳转会话 |

### 6.2 AppBar 背景色规则

| Narrow | AppBar 背景色 | 底部边框 |
|--------|-------------|---------|
| 频道/话题 | 频道色板 `barBackground` | 移除（与消息头同色） |
| DM | `dmRecipientHeaderBg` | 移除 |
| 其他 | 默认 (inherit) | 保留 |

## 7. 主题与样式系统

### 7.1 主题扩展

| 扩展类 | 文件 | 用途 |
|--------|------|------|
| `MessageListTheme` | `message_list.dart` | 消息列表特有颜色（未读标记、时间戳、DM头背景等） |
| `ComposeBoxTheme` | `compose_box.dart` | 输入框特有样式（暗色模式阴影） |
| `ContentTheme` | `content.dart` | 消息内容渲染样式（代码块、链接、数学公式等） |
| `DesignVariables` | `theme.dart` | 全局设计变量（颜色、图标等） |

### 7.2 消息列表主题关键色

| 变量 | 亮色 | 暗色 |
|------|------|------|
| `unreadMarker` | `hsl(227, 78%, 59%)` | `hsl(227, 78%, 59%, 75%)` |
| `unreadMarkerGap` | `white(60%)` | `transparent` |
| `dmRecipientHeaderBg` | `hsl(46, 35%, 93%)` | `hsl(46, 15%, 20%)` |
| `labelTime` | `black(49%)` | `white(50%)` |
| `senderBotIcon` | `hsl(180, 8%, 65%)` | `hsl(180, 5%, 50%)` |

## 8. 状态管理与数据流

### 8.1 状态层级

```
GlobalStore (全局，跨账户)
  └── PerAccountStore (每账户，含 mixin substores)
        ├── Unreads (未读消息)
        ├── TypingStatus (正在输入)
        ├── Subscriptions (频道订阅)
        ├── Messages (消息缓存)
        └── TypingNotifier (输入通知)
```

### 8.2 关键数据流

```
用户滚动 → MessageListScrollController
         → _handleScrollMetrics()
         → _markReadFromScroll() → store.markReadFromScroll()
         → fetchOlder/fetchNewer (边界预加载)

用户发送 → _SendButton._send()
        → store.sendMessage(destination, content)
        → API 请求
        → 事件系统 → MessageListView._modelChanged()
        → setState() 重建消息列表

消息事件 → MessageListView (ChangeNotifier)
        → _modelChanged()
        → MessageList.setState()
        → 重建可见消息项
```

### 8.3 跨组件通信机制

| 机制 | 使用场景 |
|------|---------|
| `GlobalKey<State>` | `_messageListKey`、`_composeBoxKey` — 父组件访问子组件状态 |
| `InheritedWidget` | `PerAccountStoreWidget`、`ComposeBoxInheritedWidget`、`_RevealedMutedMessagesProvider` |
| `ValueNotifier` | `_tab`（底部导航）、`_scrollToBottomVisible`、`topicInteractionStatus` |
| `ChangeNotifier` | `MessageListView`、`RevealedMutedMessagesState` |
| `PerAccountStoreAwareStateMixin` | 自动监听 store 变化，调用 `onNewStore()` |

## 9. 数学增强特性

### 9.1 数学相关模块

| 模块 | 文件 | 功能 |
|------|------|------|
| KaTeX 解析 | `lib/model/katex.dart` | 从服务器渲染的 KaTeX HTML 提取 TeX 源码（MathML annotation） |
| LaTeX 转换 | `lib/model/latex_converter.dart` | 发送时将标准 `$...$`/`$$...$$`/`\(...\)`/`\[...\]` 转为 Zulip 非标准格式 |
| 数学键盘 | `lib/widgets/math_keyboard/` | 6 分类工具栏，含最近符号持久化 (`math_keyboard_history.dart`) |
| LaTeX 预览 | `lib/model/latex_preview.dart` | 实时预览（300ms 防抖） |
| 数学组件 | `lib/widgets/math_widget.dart` | 集成 `flutter_math_fork` 的渲染组件 |
| ZWSP 插入 | — | 绕过服务器 `\B` 正则的零宽空格变通方案 |

### 9.2 渲染管线

```
服务器 KaTeX HTML → katex.dart 提取 TeX → math_widget.dart 渲染
                                              ↓
                                    flutter_math_fork (纯 Dart KaTeX)
                                    (无需外部字体依赖)
```

## 10. 性能优化要点

| 优化 | 位置 | 说明 |
|------|------|------|
| Widget Key 复用 | `_buildListView()` | 使用 `ValueKey(message.id)` 配合 `findChildIndexCallback` 二分查找 |
| 双 Sliver 架构 | `MessageList` | 从中间向两端增量加载，避免一次性构建全部消息 |
| 预加载缓冲 | `kFetchMessagesBufferPixels` | 距边界 ~4000px 时触发下一批加载 |
| `Offstage` 标签页 | `HomePage` | 非活跃标签页保持状态但不渲染 |
| `RepaintBoundary` | 消息内容 | 隔离重绘范围（由 Flutter 框架自动处理部分） |

## 11. 开发约定速查

| 约定 | 说明 |
|------|------|
| 测试框架 | `package:checks`（非 `expect`/`matcher`） |
| API 构造参数 | 全部 `required`（即使 nullable） |
| 导入风格 | 优先相对导入，`prefer_relative_imports` lint |
| 代码格式 | 不使用 `dart format`，手动遵循现有风格 |
| 严格分析 | `strict-inference`、`strict-raw-types`、`strict-casts` 全部开启 |
| 术语 | 新代码使用 "channel" 而非 "stream" |
| 检查命令 | `tools/check`（变更文件）/ `tools/check --all`（全部文件） |

---

*文档生成时间：2026-07-02*
