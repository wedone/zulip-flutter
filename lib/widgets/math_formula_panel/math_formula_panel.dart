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
class MathFormulaPanel extends StatefulWidget {
  const MathFormulaPanel({
    super.key,
    required this.visible,
    required this.isDark,
    this.initialLatex,
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
    }
  }

  @override
  void didUpdateWidget(covariant MathFormulaPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _everShown = true;
        _controller.forward();
        // 面板打开时收起系统键盘，避免与 MathLive 虚拟键盘叠加。
        FocusManager.instance.primaryFocus?.unfocus();
        // 同步 initialLatex 到快照（_onActionComplete 时可读取）。
        if (widget.initialLatex != null) {
          _latexSnapshot.value = widget.initialLatex!;
        }
      } else {
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

  void _onActionComplete() {
    final String latex = _latexSnapshot.value;
    if (latex.trim().isNotEmpty) {
      widget.onLatexConfirmed?.call(latex);
    }
    widget.onVisibilityChanged?.call(false);
  }

  void _onTapOutside() {
    // 点击面板外部，行为同点击「完成」。
    _onActionComplete();
  }

  @override
  Widget build(BuildContext context) {
    // 面板从未打开过时不渲染。
    if (!_everShown) {
      return const SizedBox.shrink();
    }

    final double panelHeight = MediaQuery.of(context).size.height * 0.45;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? _) {
        final double t = _controller.value;
        // 面板完全收起时忽略触摸，避免拦截下层交互。
        return IgnorePointer(
          ignoring: t == 0,
          child: Stack(
            children: <Widget>[
              // 半透明遮罩层：点击关闭。
              if (t > 0)
                GestureDetector(
                  onTap: _onTapOutside,
                  behavior: HitTestBehavior.opaque,
                  child: ColoredBox(
                    color: Colors.black.withOpacity(0.4 * t),
                  ),
                ),
              // 面板本体。
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: GestureDetector(
                    // 阻止点击面板内部时冒泡到遮罩层关闭面板。
                    onTap: () {},
                    child: Material(
                      elevation: 8,
                      color:
                          widget.isDark ? const Color(0xFF141922) : Colors.white,
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}