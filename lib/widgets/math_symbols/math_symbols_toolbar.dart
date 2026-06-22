import 'package:flutter/material.dart';

import '../../generated/l10n/zulip_localizations.dart';
import '../../model/math_symbols_history.dart';
import '../color.dart';
import '../theme.dart';
import 'math_symbols_data.dart' show kMathSymbols, kCommonLeftSymbols, kCommonRightSymbols, MathSymbolCategory, MathSymbolItem, UnicodeSymbol, LatexSnippet, LatexWrapper;

/// The math symbols toolbar that appears above the compose box input.
///
/// Shows category tabs, a symbol grid, and a "recently used" section.
class MathSymbolsToolbar extends StatefulWidget {
  const MathSymbolsToolbar({
    super.key,
    required this.controller,
  });

  /// The text controller for the compose content input.
  final TextEditingController controller;

  @override
  State<MathSymbolsToolbar> createState() => _MathSymbolsToolbarState();
}

class _MathSymbolsToolbarState extends State<MathSymbolsToolbar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> _recentSymbols = [];
  bool _recentLoaded = false;

  static const _categoryOrder = MathSymbolCategory.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _categoryOrder.length,
      vsync: this,
      initialIndex: MathSymbolCategory.common.index,
    );
    _loadRecentSymbols();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSymbols() async {
    final recent = await MathSymbolsHistory.getRecentSymbols();
    if (!mounted) return;
    setState(() {
      _recentSymbols = recent;
      _recentLoaded = true;
    });
  }

  void _insertSymbol(MathSymbolItem item) {
    final controller = widget.controller;
    final selection = controller.selection;
    final text = controller.text;

    switch (item) {
      case UnicodeSymbol(:final output):
        _insertText(output, cursorOffset: 0);
        MathSymbolsHistory.recordSymbol(output);
      case LatexSnippet(:final output, :final cursorOffset):
        _insertText(output, cursorOffset: cursorOffset);
        MathSymbolsHistory.recordSymbol(output);
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
        MathSymbolsHistory.recordSymbol(item.display);
    }

    // Refresh recent symbols after recording.
    _loadRecentSymbols();
  }

  void _insertRecentSymbol(String symbol) {
    // Try to find the original MathSymbolItem for proper insertion
    // (with cursor positioning and wrapping behavior).
    // Search in kCommonLeftSymbols and kCommonRightSymbols first,
    // then fall back to kMathSymbols.values.
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
    for (final symbols in kMathSymbols.values) {
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
    MathSymbolsHistory.recordSymbol(symbol);
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Category tabs
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
              color: designVariables.foreground.withFadedAlpha(0.1),
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
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _categoryLabel(MathSymbolCategory category, ZulipLocalizations l) {
    return switch (category) {
      MathSymbolCategory.common    => l.mathSymbolsCategoryCommon,
      MathSymbolCategory.relations => l.mathSymbolsCategoryRelations,
      MathSymbolCategory.functions => l.mathSymbolsCategoryFunctions,
      MathSymbolCategory.greek     => l.mathSymbolsCategoryGreek,
      MathSymbolCategory.templates => l.mathSymbolsCategoryTemplates,
      MathSymbolCategory.recent    => l.mathSymbolsCategoryRecent,
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
  });

  final MathSymbolCategory category;
  final List<String>? recentSymbols;
  final void Function(MathSymbolItem) onSymbolTap;
  final void Function(String) onRecentSymbolTap;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);
    final zulipLocalizations = ZulipLocalizations.of(context);

    if (category == MathSymbolCategory.common) {
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
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (category == MathSymbolCategory.recent) {
      if (recentSymbols == null || recentSymbols!.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              zulipLocalizations.mathSymbolsNoRecentHint,
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

    final symbols = kMathSymbols[category] ?? const [];
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
}

/// A single symbol button in the grid.
class _SymbolButton extends StatelessWidget {
  const _SymbolButton({
    required this.display,
    required this.onTap,
  });

  final String display;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final designVariables = DesignVariables.of(context);

    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        onPressed: onTap,
        style: IconButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          highlightColor: designVariables.editorButtonPressedBg,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
        ),
        icon: Text(
          display,
          style: TextStyle(
            fontSize: _fontSizeForDisplay(display),
            color: designVariables.foreground,
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
