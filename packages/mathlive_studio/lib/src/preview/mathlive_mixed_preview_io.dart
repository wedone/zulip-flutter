import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../config/mathlive_channels.dart';
import 'mathlive_mixed_preview_html.dart';

/// Read-only MathLive preview (Android / iOS / desktop).
class MathLiveMixedPreviewBody extends StatefulWidget {
  const MathLiveMixedPreviewBody({
    super.key,
    required this.previewText,
    required this.isDark,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSizePx,
    this.fontFamily,
    this.lineHeight = 1.45,
    this.fontWeight = 400,
    this.letterSpacing = 0,
    required this.maxViewportHeight,
    this.expandToContent = false,
    this.disableTextInteraction = false,
    this.clipOverflow = false,
    this.preventShrinkingReportedHeight = false,
  });

  final String previewText;
  final bool isDark;
  final Color backgroundColor;
  final Color textColor;
  final double fontSizePx;
  final String? fontFamily;
  final double lineHeight;
  final int fontWeight;
  final double letterSpacing;
  final double maxViewportHeight;
  final bool expandToContent;
  final bool disableTextInteraction;
  final bool clipOverflow;
  final bool preventShrinkingReportedHeight;

  @override
  State<MathLiveMixedPreviewBody> createState() =>
      _MathLiveMixedPreviewBodyState();
}

class _MathLiveMixedPreviewBodyState extends State<MathLiveMixedPreviewBody>
    with AutomaticKeepAliveClientMixin {
  bool get _embedWithoutScroll =>
      widget.expandToContent || widget.clipOverflow;

  static final Set<Factory<OneSequenceGestureRecognizer>>
      _previewGestureRecognizers =
      <Factory<OneSequenceGestureRecognizer>>{
    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
  };

  late final WebViewController _controller;
  double _contentHeight = 48;

  @override
  bool get wantKeepAlive =>
      widget.expandToContent && widget.preventShrinkingReportedHeight;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(widget.backgroundColor)
      ..addJavaScriptChannel(
        MathLiveMixedChannels.previewHeightJsChannel,
        onMessageReceived: (JavaScriptMessage message) {
          final double? h = double.tryParse(message.message.trim());
          if (!mounted || h == null || h <= 0) {
            return;
          }
          final double reportCap = widget.expandToContent
              ? widget.maxViewportHeight.clamp(48.0, 8000.0)
              : 1600.0;
          final double clamped = h.clamp(48.0, reportCap);
          final double next = (widget.expandToContent &&
                  widget.preventShrinkingReportedHeight)
              ? math.max(_contentHeight, clamped)
              : clamped;
          if ((next - _contentHeight).abs() > 3) {
            setState(() => _contentHeight = next);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _scheduleHeightReportsAfterLoad(),
        ),
      );
    if (_controller.platform is AndroidWebViewController) {
      unawaited(
        (_controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false),
      );
    }
    unawaited(_load());
  }

  static const String _kReportHeightJs = r"try{var r=document.getElementById('root');var h=Math.max(document.documentElement.scrollHeight,document.body.scrollHeight,r?r.scrollHeight:0,40);FlutterPreviewHeight.postMessage(String(Math.ceil(h)));}catch(e){}";

  void _scheduleHeightReportsAfterLoad() {
    void run(int delayMs) {
      unawaited(
        _controller.runJavaScript(
          'setTimeout(function(){$_kReportHeightJs},$delayMs);',
        ),
      );
    }

    run(120);
    if (widget.expandToContent || widget.clipOverflow) {
      run(400);
      run(900);
    }
  }

  Future<void> _load() async {
    final String html = buildMathLiveMixedPreviewHtml(
      source: widget.previewText,
      isDark: widget.isDark,
      backgroundColor: widget.backgroundColor,
      textColor: widget.textColor,
      fontSizePx: widget.fontSizePx,
      fontFamily: widget.fontFamily,
      lineHeight: widget.lineHeight,
      fontWeight: widget.fontWeight,
      letterSpacing: widget.letterSpacing,
      embedWithoutScroll: _embedWithoutScroll,
      clipRootOverflow: widget.clipOverflow,
      disableTextInteraction: widget.disableTextInteraction,
    );
    if (html.isEmpty) {
      return;
    }
    await _controller.loadHtmlString(
      html,
      baseUrl: 'https://cdn.jsdelivr.net/',
    );
  }

  @override
  void didUpdateWidget(covariant MathLiveMixedPreviewBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.previewText != widget.previewText ||
        oldWidget.isDark != widget.isDark ||
        oldWidget.backgroundColor != widget.backgroundColor ||
        oldWidget.textColor != widget.textColor ||
        oldWidget.fontSizePx != widget.fontSizePx ||
        oldWidget.fontFamily != widget.fontFamily ||
        oldWidget.lineHeight != widget.lineHeight ||
        oldWidget.fontWeight != widget.fontWeight ||
        oldWidget.letterSpacing != widget.letterSpacing ||
        oldWidget.expandToContent != widget.expandToContent ||
        oldWidget.maxViewportHeight != widget.maxViewportHeight ||
        oldWidget.clipOverflow != widget.clipOverflow ||
        oldWidget.preventShrinkingReportedHeight !=
            widget.preventShrinkingReportedHeight ||
        oldWidget.disableTextInteraction != widget.disableTextInteraction) {
      _contentHeight = 48;
      _controller.setBackgroundColor(widget.backgroundColor);
      unawaited(_load());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final String html = buildMathLiveMixedPreviewHtml(
      source: widget.previewText,
      isDark: widget.isDark,
      backgroundColor: widget.backgroundColor,
      textColor: widget.textColor,
      fontSizePx: widget.fontSizePx,
      fontFamily: widget.fontFamily,
      lineHeight: widget.lineHeight,
      fontWeight: widget.fontWeight,
      letterSpacing: widget.letterSpacing,
      embedWithoutScroll: _embedWithoutScroll,
      clipRootOverflow: widget.clipOverflow,
      disableTextInteraction: widget.disableTextInteraction,
    );
    if (html.isEmpty) {
      return const SizedBox.shrink();
    }
    final double maxCap = widget.maxViewportHeight.clamp(48.0, 8000.0);
    final double displayHeight = widget.expandToContent
        ? _contentHeight.clamp(48.0, maxCap)
        : widget.clipOverflow
            ? maxCap
            : math.min(_contentHeight, maxCap);
    final bool lockPreviewPointer =
        widget.expandToContent || widget.clipOverflow;
    final Widget webView = WebViewWidget(
      controller: _controller,
      gestureRecognizers: lockPreviewPointer
          ? const <Factory<OneSequenceGestureRecognizer>>{}
          : _previewGestureRecognizers,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: double.infinity,
        height: displayHeight,
        child: lockPreviewPointer
            ? IgnorePointer(child: webView)
            : webView,
      ),
    );
  }
}
