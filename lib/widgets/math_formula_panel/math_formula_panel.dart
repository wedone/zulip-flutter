import 'package:flutter/material.dart';

import '../../mathlive/mathlive_studio.dart';

/// 内联公式编辑面板。
///
/// 在 compose_box 中作为底部面板使用，通过 [visible] 控制显示/隐藏。
/// 用户点击「完成」或点击面板外部时，通过 [onLatexConfirmed] 提交 LaTeX，
/// 并通过 [onVisibilityChanged] 通知外部关闭面板。
///
/// 内部使用 [MathLiveEmbeddedEditor] 作为核心编辑器。一旦面板首次显示，
/// WebView 实例会常驻于 widget 树中（通过 [GlobalKey] 保留 State），
/// 避免重复加载 HTML/JS 资源。
///
/// 面板从底部升起，不覆盖 compose_box 上方的消息列表区域，
/// 类似系统键盘的交互方式。点击面板外部（消息列表区域）时面板收起。
/// 无半透明遮罩层，避免遮挡消息列表。
class MathFormulaPanel extends StatefulWidget {
  const MathFormulaPanel({
    super.key,
    required this.visible,
    required this.isDark,
    this.initialLatex,
    this.panelHeight,
    this.onLatexConfirmed,
    this.onVisibilityChanged,
  });

  /// 是否显示面板。
  final bool visible;

  /// 是否暗色主题。
  final bool isDark;

  /// 打开面板时加载的初始 LaTeX（不含界定符）。
  ///
  /// 当 [visible] 从 false 变为 true 时，会同步到内部的 latex 快照。
  final String? initialLatex;

  /// 面板高度（像素）。
  ///
  /// 若为 null 或非正数，则使用默认逻辑：取屏幕高度的 45% 与 360px 中的较大值，
  /// 与系统键盘高度（Android 约 280-320px，iOS 约 280-340px）+ math-field 行高相当。
  final double? panelHeight;

  /// LaTeX 提交回调（用户点击「完成」或点击面板外部时触发）。
  ///
  /// 仅当 LaTeX 非空（trim 后）时才会被调用。
  final ValueChanged<String>? onLatexConfirmed;

  /// 面板可见性变化回调。
  ///
  /// 当用户点击「完成」或点击面板外部时，会以 false 调用此回调，
  /// 外部应在回调中通过 setState 将 [visible] 置为 false 以触发收起动画。
  final ValueChanged<bool>? onVisibilityChanged;

  @override
  State<MathFormulaPanel> createState() => _MathFormulaPanelState();
}

class _MathFormulaPanelState extends State<MathFormulaPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  /// 跟踪当前 LaTeX（由 WebView 实时同步）。
  final ValueNotifier<String> _latexSnapshot = ValueNotifier<String>('');

  /// 编辑器的固定 Key，保证 WebView State 在面板收起/展开时不被 dispose。
  final GlobalKey _editorKey = GlobalKey();

  /// 是否曾经显示过面板。未显示过时不渲染编辑器，节省资源。
  bool _everShown = false;

  /// 面板是否处于交互状态（可见且尚未触发关闭流程）。
  ///
  /// 用于防止 [TapRegion.onTapOutside] 与遮罩层 [GestureDetector.onTap]
  /// 重复触发 [_onActionComplete]，以及面板已关闭后误触发提交。
  bool _isInteracting = false;

  /// 计算面板高度。
  ///
  /// 优先使用外部传入的 [MathFormulaPanel.panelHeight]；
  /// 否则取屏幕高度 45% 与 360px 中的较大值。
  double _resolvePanelHeight(BuildContext context) {
    final configured = widget.panelHeight;
    if (configured != null && configured > 0) return configured;
    final mediaQuery = MediaQuery.of(context);
    final heightByRatio = mediaQuery.size.height * 0.45;
    const heightFixed = 360.0;
    return heightByRatio > heightFixed ? heightByRatio : heightFixed;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // 从底部滑入
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    if (widget.visible) {
      _controller.value = 1.0;
      _everShown = true;
      _isInteracting = true;
    }
  }

  @override
  void didUpdateWidget(covariant MathFormulaPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _everShown = true;
        _isInteracting = true;
        _controller.forward();
        // 面板打开时收起系统键盘，避免与 MathLive 虚拟键盘叠加。
        FocusManager.instance.primaryFocus?.unfocus();
        // 同步 initialLatex 到快照（_onActionComplete 时可读取）。
        if (widget.initialLatex != null) {
          _latexSnapshot.value = widget.initialLatex!;
        }
      } else {
        _isInteracting = false;
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _latexSnapshot.dispose();
    super.dispose();
  }

  /// 用户点击「完成」或点击面板外部时触发。
  ///
  /// 通过 [_isInteracting] 保证只触发一次：提交 LaTeX 并通知外部关闭。
  void _onActionComplete() {
    if (!_isInteracting) return;
    _isInteracting = false;
    final String latex = _latexSnapshot.value;
    if (latex.trim().isNotEmpty) {
      widget.onLatexConfirmed?.call(latex);
    }
    widget.onVisibilityChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    // 面板从未打开过时不渲染。
    if (!_everShown) {
      return const SizedBox.shrink();
    }

    final double panelHeight = _resolvePanelHeight(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? _) {
        final double t = _controller.value;
        // 面板完全收起时不渲染任何内容，避免占用布局空间。
        // WebView State 仍由 [_editorKey] 保留，下次展开时复用。
        if (t == 0) {
          return const SizedBox.shrink();
        }
        return TapRegion(
          onTapOutside: (_) => _onActionComplete(),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Material(
              elevation: 8,
              color: widget.isDark
                  ? const Color(0xFF141922)
                  : Colors.white,
              child: SizedBox(
                height: panelHeight,
                child: MathLiveEmbeddedEditor(
                  key: _editorKey,
                  isDark: widget.isDark,
                  initialLatex: widget.initialLatex,
                  onLatexChanged: (String latex) {
                    _latexSnapshot.value = latex;
                  },
                  latexSnapshot: _latexSnapshot,
                  onActionComplete: _onActionComplete,
                  height: panelHeight,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
