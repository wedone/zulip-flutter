import 'package:flutter/material.dart';

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
          // Symbol grid (with recent section)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: TabBarView(
              controller: _tabController,
              children: [
                for (final category in _categoryOrder)
                  _SymbolGrid(
                    category: category,
                    recentSymbols: _recentLoaded ? _recentSymbols : null,
                    onSymbolTap: _insertSymbol,
                    onRecentSymbolTap: _insertRecentSymbol,
                    onVariantTap: _insertVariantText,
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
    required this.category,
    required this.recentSymbols,
    required this.onSymbolTap,
    required this.onRecentSymbolTap,
    required this.onVariantTap,
  });

  final MathKeyboardCategory category;
  final List<String>? recentSymbols;
  final void Function(MathKeyboardItem) onSymbolTap;
  final void Function(String) onRecentSymbolTap;
  final void Function(String) onVariantTap;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);

    if (category == MathKeyboardCategory.common) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                runAlignment: WrapAlignment.center,
                children: [
                  for (final symbol in kCommonLeftSymbols)
                    _SymbolButton(
                      display: symbol.display,
                      onTap: () => onSymbolTap(symbol),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Wrap(
                runAlignment: WrapAlignment.center,
                children: [
                  for (final symbol in kCommonRightSymbols)
                    _SymbolButton(
                      display: symbol.display,
                      onTap: () => onSymbolTap(symbol),
                      onLongPressVariant: _lowercaseVariant(symbol.display),
                      onVariantTap: onVariantTap,
                    ),
                ],
              ),
            ),
          ],
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Wrap(
            children: [
              for (final symbol in recentSymbols!)
                _SymbolButton(
                  display: symbol,
                  onTap: () => onRecentSymbolTap(symbol),
                ),
            ],
          ),
        ),
      );
    }

    final symbols = kMathKeyboard[category] ?? const [];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Wrap(
          children: [
            for (final symbol in symbols)
              _SymbolButton(
                display: symbol.display,
                onTap: () => onSymbolTap(symbol),
              ),
          ],
        ),
      ),
    );
  }

  /// 返回大写英文字母对应的小写形式，用于长按变体。
  /// 非大写字母返回 null。
  static String? _lowercaseVariant(String display) {
    if (display.length == 1 && display.codeUnitAt(0) >= 0x41 && display.codeUnitAt(0) <= 0x5A) {
      return display.toLowerCase();
    }
    return null;
  }
}

/// A single symbol button in the grid.
/// 参考 MathLive 虚拟键盘的按键样式：白色背景、浅灰边框、底部深色边框（3D 效果）、圆角。
class _SymbolButton extends StatelessWidget {
  const _SymbolButton({
    required this.display,
    required this.onTap,
    this.onLongPressVariant,
    this.onVariantTap,
  });

  final String display;

  final VoidCallback onTap;

  /// 长按时直接插入的变体符号（如大写字母长按插入小写）。
  /// 为 null 时不支持长按。
  final String? onLongPressVariant;

  /// 插入变体符号时的回调。
  final void Function(String variant)? onVariantTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPressVariant != null
        ? () => onVariantTap?.call(onLongPressVariant!)
        : null,
      child: Container(
        width: 36,
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          // 白色按键面
          color: Colors.white,
          // 柔和圆角
          borderRadius: BorderRadius.circular(6),
          // 浅灰边框
          border: Border.all(
            color: const Color(0xFFe5e6e9),
            width: 1,
          ),
          // 底部深色边框营造 3D 凸起效果
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF8d8f92),
              offset: Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          display,
          style: TextStyle(
            fontSize: _fontSizeForDisplay(display),
            color: const Color(0xFF000000),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
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
