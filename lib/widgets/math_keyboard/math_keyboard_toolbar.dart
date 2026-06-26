import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../generated/l10n/zulip_localizations.dart';
import '../../model/math_keyboard_history.dart';
import '../../widgets/color.dart';
import '../../widgets/theme.dart';
import 'math_keyboard_data.dart' show kMathKeyboard, kCommonLeftSymbols, kCommonRightSymbols, MathKeyboardCategory, MathKeyboardItem, UnicodeSymbol, LatexSnippet, LatexWrapper;

/// The math keyboard toolbar that appears above the compose box input.
///
/// Shows category tabs, a symbol grid, and a "recently used" section.
class MathKeyboardToolbar extends StatefulWidget {
  const MathKeyboardToolbar({
    super.key,
    required this.controller,
  });

  /// The text controller for the compose content input.
  final TextEditingController controller;

  @override
  State<MathKeyboardToolbar> createState() => _MathKeyboardToolbarState();
}

class _MathKeyboardToolbarState extends State<MathKeyboardToolbar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> _recentSymbols = [];
  bool _recentLoaded = false;
  /// 记录上一个被按下的按键（用于显示浅灰色背景）。
  String? _lastPressedKey;

  static const _categoryOrder = MathKeyboardCategory.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _categoryOrder.length,
      vsync: this,
      initialIndex: MathKeyboardCategory.common.index,
    );
    _loadRecentSymbols();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSymbols() async {
    final recent = await MathKeyboardHistory.getRecentSymbols();
    if (!mounted) return;
    setState(() {
      _recentSymbols = recent;
      _recentLoaded = true;
    });
  }

  void _insertSymbol(MathKeyboardItem item) {
    final controller = widget.controller;
    final selection = controller.selection;
    final text = controller.text;

    switch (item) {
      case UnicodeSymbol(:final output):
        _insertText(output, cursorOffset: 0);
        MathKeyboardHistory.recordSymbol(output);
      case LatexSnippet(:final output, :final cursorOffset):
        _insertText(output, cursorOffset: cursorOffset);
        MathKeyboardHistory.recordSymbol(output);
      case LatexWrapper(:final prefix, :final suffix):
        if (selection.isValid && !selection.isCollapsed) {
          // Wrap selected text.
          final selectedText = text.substring(selection.start, selection.end);
          final replacement = '$prefix$selectedText$suffix';
          controller.value = controller.value.replaced(selection, replacement);
          controller.selection = TextSelection.collapsed(
            offset: selection.start + replacement.length,
          );
        } else {
          // Insert prefix + suffix with cursor between them.
          final insertPos = selection.isValid ? selection.start : text.length;
          final replacement = '$prefix$suffix';
          controller.value = controller.value.replaced(
            TextSelection.collapsed(offset: insertPos),
            replacement,
          );
          controller.selection = TextSelection.collapsed(
            offset: insertPos + prefix.length,
          );
        }
        MathKeyboardHistory.recordSymbol(item.display);
    }

    // Refresh recent symbols after recording.
    _loadRecentSymbols();
  }

  void _insertRecentSymbol(String symbol) {
    // Try to find the original MathKeyboardItem for proper insertion
    // (with cursor positioning and wrapping behavior).
    // Search in kCommonLeftSymbols and kCommonRightSymbols first,
    // then fall back to kMathKeyboard.values.
    for (final item in [...kCommonLeftSymbols, ...kCommonRightSymbols]) {
      final key = switch (item) {
        UnicodeSymbol(:final output) => output,
        LatexSnippet(:final output) => output,
        LatexWrapper(:final display) => display,
      };
      if (key == symbol) {
        _insertSymbol(item);
        return;
      }
    }
    for (final symbols in kMathKeyboard.values) {
      for (final item in symbols) {
        if (item is UnicodeSymbol && item.output == symbol) {
          _insertSymbol(item);
          return;
        }
        if (item is LatexSnippet && item.output == symbol) {
          _insertSymbol(item);
          return;
        }
        if (item is LatexWrapper && item.display == symbol) {
          _insertSymbol(item);
          return;
        }
      }
    }
    // Fallback: plain text insert
    _insertText(symbol, cursorOffset: 0);
    MathKeyboardHistory.recordSymbol(symbol);
    _loadRecentSymbols();
  }

  /// 插入长按变体符号（如大写字母长按弹出的小写字母）。
  void _insertVariantText(String text) {
    _insertText(text, cursorOffset: 0);
    MathKeyboardHistory.recordSymbol(text);
    _loadRecentSymbols();
  }

  void _insertText(String text, {required int cursorOffset}) {
    final controller = widget.controller;
    final selection = controller.selection;
    final insertPos = selection.isValid ? selection.start : controller.text.length;
    controller.value = controller.value.replaced(
      TextSelection.collapsed(offset: insertPos),
      text,
    );
    controller.selection = TextSelection.collapsed(
      offset: insertPos + text.length - cursorOffset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final zulipLocalizations = ZulipLocalizations.of(context);

    return Container(
      // 键盘整体背景：浅灰色，参考 MathLive 虚拟键盘
      color: const Color(0xFFcacfd7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category tabs
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.6),
              )),
            ),
            child: SizedBox(
              height: 30,
              child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: designVariables.icon,
              unselectedLabelColor: designVariables.foreground.withFadedAlpha(0.5),
              indicatorColor: designVariables.icon,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              tabs: [
                for (final category in _categoryOrder)
                  Tab(text: _categoryLabel(category, zulipLocalizations)),
              ],
            ),
            ),
          ),
          // Symbol grid (with recent section)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: TabBarView(
              controller: _tabController,
              children: [
                for (final category in _categoryOrder)
                  _SymbolGrid(
                    key: ValueKey(category),
                    category: category,
                    recentSymbols: _recentLoaded ? _recentSymbols : null,
                    onSymbolTap: _insertSymbol,
                    onRecentSymbolTap: _insertRecentSymbol,
                    onVariantTap: _insertVariantText,
                    lastPressedKey: _lastPressedKey,
                    onLastPressedKeyChanged: (key) => setState(() => _lastPressedKey = key),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _categoryLabel(MathKeyboardCategory category, ZulipLocalizations l) {
    return switch (category) {
      MathKeyboardCategory.common    => l.mathKeyboardCategoryCommon,
      MathKeyboardCategory.relations => l.mathKeyboardCategoryRelations,
      MathKeyboardCategory.functions => l.mathKeyboardCategoryFunctions,
      MathKeyboardCategory.greek     => l.mathKeyboardCategoryGreek,
      MathKeyboardCategory.templates => l.mathKeyboardCategoryTemplates,
      MathKeyboardCategory.recent    => l.mathKeyboardCategoryRecent,
    };
  }
}

/// A scrollable grid of symbol buttons for a given category.
class _SymbolGrid extends StatelessWidget {
  const _SymbolGrid({
    super.key,
    required this.category,
    required this.recentSymbols,
    required this.onSymbolTap,
    required this.onRecentSymbolTap,
    required this.onVariantTap,
    required this.lastPressedKey,
    required this.onLastPressedKeyChanged,
  });

  final MathKeyboardCategory category;
  final List<String>? recentSymbols;
  final void Function(MathKeyboardItem) onSymbolTap;
  final void Function(String) onRecentSymbolTap;
  final void Function(String) onVariantTap;
  /// 上一个被按下的按键 key，用于显示浅灰色背景。
  final String? lastPressedKey;
  /// 按键按下时回调，更新上一个按键记录。
  final void Function(String?) onLastPressedKeyChanged;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);

    if (category == MathKeyboardCategory.common) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  runAlignment: WrapAlignment.center,
                  children: [
                    for (final symbol in kCommonLeftSymbols)
                      _SymbolButton(
                        item: symbol,
                        onTap: () => onSymbolTap(symbol),
                        onLongPressVariants: _leftColumnVariant(symbol.display),
                        onVariantTap: onVariantTap,
                        lastPressedKey: lastPressedKey,
                        onLastPressedKeyChanged: onLastPressedKeyChanged,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  runAlignment: WrapAlignment.center,
                  children: [
                    for (final symbol in kCommonRightSymbols)
                      _SymbolButton(
                        item: symbol,
                        onTap: () => onSymbolTap(symbol),
                        onLongPressVariants: _lowercaseVariant(symbol.display),
                        onVariantTap: onVariantTap,
                        lastPressedKey: lastPressedKey,
                        onLastPressedKeyChanged: onLastPressedKeyChanged,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (category == MathKeyboardCategory.recent) {
      final zulipLocalizations = ZulipLocalizations.of(context);
      if (recentSymbols == null || recentSymbols!.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              zulipLocalizations.mathKeyboardNoRecentHint,
              style: TextStyle(
                fontSize: 14,
                color: designVariables.foreground.withFadedAlpha(0.3),
              ),
            ),
          ),
        );
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Center(
          child: Wrap(
            children: [
              for (final symbol in recentSymbols!)
                _SymbolButton(
                  item: UnicodeSymbol(display: symbol, output: symbol, category: MathKeyboardCategory.recent),
                  onTap: () => onRecentSymbolTap(symbol),
                  lastPressedKey: lastPressedKey,
                  onLastPressedKeyChanged: onLastPressedKeyChanged,
                ),
            ],
          ),
        ),
      );
    }

    final symbols = kMathKeyboard[category] ?? const [];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Center(
        child: Wrap(
          children: [
            for (final symbol in symbols)
              _SymbolButton(
                item: symbol,
                onTap: () => onSymbolTap(symbol),
                lastPressedKey: lastPressedKey,
                onLastPressedKeyChanged: onLastPressedKeyChanged,
              ),
          ],
        ),
      ),
    );
  }

  /// 返回大写英文字母对应的小写形式，用于长按变体。
  /// 非大写字母返回 null（即无长按功能）。
  static List<String>? _lowercaseVariant(String display) {
    if (display.length == 1 && display.codeUnitAt(0) >= 0x41 && display.codeUnitAt(0) <= 0x5A) {
      return [display.toLowerCase()];
    }
    return null;
  }

  /// 返回左栏符号的长按变体列表，用于将常用符号合并到相近按键中。
  /// 不支持的符号返回 null（即无长按功能）。
  static List<String>? _leftColumnVariant(String display) {
    return switch (display) {
      '.' => ['⋅','…'],
      ',' => [':',';'],
      '=' => ['≠','≈','≅'],
      '/' => [r'\'],
      '²' => ['³'],
      _ => null,
    };
  }
}

/// A single symbol button in the grid.
/// 参考 MathLive 虚拟键盘的按键样式：白色背景、浅灰边框、底部深色边框（3D 效果）、圆角。
/// 模板类符号（LatexSnippet/LatexWrapper）实时渲染 LaTeX，Unicode 符号直接显示文本。
/// 3 种状态颜色：
///   0. 平常：白色
///   1. 按下时：蓝色
///   2. 刚才按过：浅灰色（保持到按下其他按键）
///
/// 长按变体面板：
///   - 单个变体：长按直接插入（高效模式）
///   - 多个变体：长按弹出面板，释放时若未选中则默认插入第一个
class _SymbolButton extends StatefulWidget {
  const _SymbolButton({
    required this.item,
    required this.onTap,
    this.onLongPressVariants,
    this.onVariantTap,
    required this.lastPressedKey,
    required this.onLastPressedKeyChanged,
  });

  /// 符号项，决定渲染方式（LaTeX 或文本）。
  final MathKeyboardItem item;

  final VoidCallback onTap;

  /// 长按变体列表（如大写字母长按插入小写）。
  /// 为 null 或空列表时不支持长按。
  final List<String>? onLongPressVariants;

  /// 插入变体符号时的回调。
  final void Function(String variant)? onVariantTap;

  /// 上一个被按下的按键 key，用于显示浅灰色背景。
  final String? lastPressedKey;

  /// 按键按下时回调，更新上一个按键记录。
  final void Function(String?) onLastPressedKeyChanged;

  @override
  State<_SymbolButton> createState() => _SymbolButtonState();
}

class _SymbolButtonState extends State<_SymbolButton> {
  bool _pressed = false;
  bool _variantPanelShown = false;
  OverlayEntry? _variantOverlayEntry;

  /// 获取按键的唯一标识 key。
  String get _key {
    switch (widget.item) {
      case UnicodeSymbol(:final output):
        return output;
      case LatexSnippet(:final output):
        return output;
      case LatexWrapper(:final display):
        return display;
    }
  }

  /// 弹出变体选择面板（参考 MathLive showVariantsPanel）。
  void _showVariantPanel(List<String> variants) {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;

    _variantOverlayEntry = OverlayEntry(
      builder: (ctx) => _VariantPanelWidget(
        variants: variants,
        buttonGlobalPosition: position,
        buttonSize: buttonSize,
        onSelected: (variant) {
          widget.onVariantTap?.call(variant);
          _dismissVariantPanel();
        },
        onDismiss: _dismissVariantPanel,
      ),
    );

    Overlay.of(context).insert(_variantOverlayEntry!);
  }

  void _dismissVariantPanel() {
    _variantOverlayEntry?.remove();
    _variantOverlayEntry = null;
    _variantPanelShown = false;
  }

  @override
  Widget build(BuildContext context) {
    final isLastPressed = widget.lastPressedKey == _key;
    final hasVariants = widget.onLongPressVariants != null
        && widget.onLongPressVariants!.isNotEmpty;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        widget.onLastPressedKeyChanged(_key);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      onLongPress: hasVariants
        ? () {
            final variants = widget.onLongPressVariants!;
            if (variants.length == 1) {
              // 单个变体：直接插入，高效
              widget.onVariantTap?.call(variants.first);
            } else {
              // 多个变体：弹出面板供选择
              _variantPanelShown = true;
              _showVariantPanel(variants);
            }
          }
        : null,
      onLongPressUp: hasVariants
        ? () {
            setState(() => _pressed = false);
            if (!_variantPanelShown) return;
            // 延迟一帧检查：若用户未在面板中选中变体，默认插入第一个
            // 使用 Future.microtask 确保 Listener.onPointerUp 先于此处执行
            Future.microtask(() {
              if (_variantPanelShown) {
                widget.onVariantTap?.call(widget.onLongPressVariants!.first);
                _dismissVariantPanel();
              }
            });
          }
        : null,
      child: Container(
        width: 36,
        height: 40,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          // 3 种状态：按下时蓝色，刚才按过浅灰色，否则白色
          color: _pressed
              ? const Color(0xFF4A6CF7)
              : isLastPressed
                  ? const Color(0xFFf0f0f0)
                  : Colors.white,
          // 柔和圆角
          borderRadius: BorderRadius.circular(6),
          // 浅灰边框
          border: Border.all(
            color: _pressed
                ? const Color(0xFF4A6CF7)
                : isLastPressed
                    ? const Color(0xFFd5d6d9)
                    : const Color(0xFFe5e6e9),
            width: 1,
          ),
          // 底部深色边框营造 3D 凸起效果
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF8d8f92),
              offset: Offset(0, 1),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _buildContent(isLastPressed),
      ),
    );
  }

  Widget _buildContent(bool isLastPressed) {
    switch (widget.item) {
      case UnicodeSymbol():
        // Unicode 符号：直接显示文本
        return Text(
          widget.item.display,
          style: TextStyle(
            fontSize: _fontSizeForDisplay(widget.item.display),
            color: _pressed ? Colors.white : const Color(0xFF000000),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        );
      case LatexSnippet() || LatexWrapper():
        // 模板类符号：实时渲染 LaTeX
        return _renderLatex(widget.item.display, _pressed);
    }
  }

  /// 实时渲染 LaTeX 表达式，将 \square 替换为蓝色 \blacksquare。
  Widget _renderLatex(String latex, bool pressed) {
    final coloredLatex = latex.replaceAll(
      r'\square',
      r'{\color{#0066CC}{\blacksquare}}',
    );

    return Math.tex(
      coloredLatex,
      textStyle: TextStyle(
        fontSize: 14,
        color: pressed ? Colors.white : const Color(0xFF000000),
      ),
      onErrorFallback: (error) {
        // 渲染失败时回退到文本显示
        return Text(
          latex,
          style: TextStyle(
            fontSize: 12,
            color: pressed ? Colors.white : const Color(0xFF000000),
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }

  static double _fontSizeForDisplay(String display) {
    // Use smaller font for longer labels (like LaTeX commands)
    if (display.length <= 1) return 22;
    if (display.length <= 2) return 18;
    if (display.length <= 4) return 14;
    return 12;
  }
}

/// 变体选择弹出面板（参考 MathLive VariantsPanel）。
///
/// 在按键上方弹出，显示所有变体选项。使用 [Listener] 而非 [GestureDetector]
/// 接收原始指针事件，绕过手势竞技场，确保长按滑选能正常工作。
class _VariantPanelWidget extends StatelessWidget {
  const _VariantPanelWidget({
    required this.variants,
    required this.buttonGlobalPosition,
    required this.buttonSize,
    required this.onSelected,
    required this.onDismiss,
  });

  final List<String> variants;
  final Offset buttonGlobalPosition;
  final Size buttonSize;
  final ValueChanged<String> onSelected;
  final VoidCallback onDismiss;

  static const _buttonWidth = 36.0;
  static const _buttonHeight = 40.0;
  static const _buttonMargin = 1.0;
  static const _panelPadding = 6.0;
  static const _maxPerRow = 5;
  static const _gap = 4.0; // 面板与按键的间距

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // 计算面板尺寸
    final rows = (variants.length / _maxPerRow).ceil();
    final perRow = math.min(variants.length, _maxPerRow);
    final panelWidth = perRow * (_buttonWidth + _buttonMargin * 2) + _panelPadding * 2;
    final panelHeight = rows * (_buttonHeight + _buttonMargin * 2) + _panelPadding * 2;

    // 水平居中于按键
    var left = buttonGlobalPosition.dx + buttonSize.width / 2 - panelWidth / 2;
    left = left.clamp(0.0, screenSize.width - panelWidth);

    // 默认显示在按键上方
    var top = buttonGlobalPosition.dy - panelHeight - _gap;
    if (top < 0) {
      // 上方空间不足，显示在下方
      top = buttonGlobalPosition.dy + buttonSize.height + _gap;
    }

    return GestureDetector(
      // 点击遮罩层关闭面板（不插入任何变体）
      onTap: onDismiss,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            child: Container(
              width: panelWidth,
              padding: const EdgeInsets.all(_panelPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Wrap(
                children: [
                  for (final variant in variants)
                    _VariantButton(
                      variant: variant,
                      onPointerUp: () => onSelected(variant),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 变体面板中的单个按键。
///
/// 使用 [Listener] 接收原始指针事件，绕过手势竞技场，
/// 确保在长按手势持有期间，滑到此处释放时能正确触发 [onPointerUp]。
class _VariantButton extends StatelessWidget {
  const _VariantButton({
    required this.variant,
    required this.onPointerUp,
  });

  final String variant;
  final VoidCallback onPointerUp;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (_) => onPointerUp(),
      child: Container(
        width: _VariantPanelWidget._buttonWidth,
        height: _VariantPanelWidget._buttonHeight,
        margin: const EdgeInsets.all(_VariantPanelWidget._buttonMargin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFe5e6e9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF8d8f92),
              offset: Offset(0, 1),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          variant,
          style: TextStyle(
            fontSize: _SymbolButtonState._fontSizeForDisplay(variant),
            color: const Color(0xFF000000),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
