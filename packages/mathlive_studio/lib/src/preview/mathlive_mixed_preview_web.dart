// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../config/mathlive_channels.dart';
import 'mathlive_mixed_preview_html.dart';

/// Read-only MathLive preview (Flutter web) — iframe + blob HTML.
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
  static int _nextId = 0;
  late final String _viewType = 'mathlive-mixed-preview-${_nextId++}';
  html.IFrameElement? _iframe;
  String? _blobUrl;
  StreamSubscription<html.MessageEvent>? _sub;
  double _contentHeight = 48;

  @override
  bool get wantKeepAlive =>
      widget.expandToContent && widget.preventShrinkingReportedHeight;

  String _htmlDoc() {
    return buildMathLiveMixedPreviewHtml(
      source: widget.previewText,
      isDark: widget.isDark,
      backgroundColor: widget.backgroundColor,
      textColor: widget.textColor,
      fontSizePx: widget.fontSizePx,
      fontFamily: widget.fontFamily,
      lineHeight: widget.lineHeight,
      fontWeight: widget.fontWeight,
      letterSpacing: widget.letterSpacing,
      embedWithoutScroll: widget.expandToContent || widget.clipOverflow,
      clipRootOverflow: widget.clipOverflow,
      disableTextInteraction: widget.disableTextInteraction,
      webParentPostMessageId: _viewType,
    );
  }

  Future<void> _syncIframeDoc(html.IFrameElement? frame) async {
    if (frame == null) {
      return;
    }
    final String doc = _htmlDoc();
    if (doc.isEmpty) {
      return;
    }
    final String? old = _blobUrl;
    if (old != null) {
      html.Url.revokeObjectUrl(old);
      _blobUrl = null;
    }
    final html.Blob blob = html.Blob(<dynamic>[doc], 'text/html');
    final String url = html.Url.createObjectUrlFromBlob(blob);
    _blobUrl = url;
    frame.src = url;
  }

  void _scheduleSyncIframe() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_syncIframeDoc(_iframe));
    });
  }

  @override
  void initState() {
    super.initState();
    _sub = html.window.onMessage.listen(_onWindowMessage);
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final html.IFrameElement frame = html.IFrameElement()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      _iframe = frame;
      unawaited(_syncIframeDoc(frame));
      return frame;
    });
  }

  void _onWindowMessage(html.MessageEvent event) {
    final Object? raw = event.data;
    Map<dynamic, dynamic>? map;
    if (raw is Map) {
      map = raw;
    } else if (raw is String) {
      try {
        final Object? decoded = jsonDecode(raw);
        if (decoded is Map) {
          map = decoded;
        }
      } catch (_) {}
    }
    if (map == null) {
      return;
    }
    if (map['channel'] != MathLiveMixedChannels.previewHeight) {
      return;
    }
    if (map['id'] != _viewType) {
      return;
    }
    final Object? h = map['height'];
    final double? parsed = h is num ? h.toDouble() : double.tryParse('$h');
    if (!mounted || parsed == null || parsed <= 0) {
      return;
    }
    final double reportCap = widget.expandToContent
        ? widget.maxViewportHeight.clamp(48.0, 8000.0)
        : 1600.0;
    final double clamped = parsed.clamp(48.0, reportCap);
    final double next = (widget.expandToContent &&
            widget.preventShrinkingReportedHeight)
        ? math.max(_contentHeight, clamped)
        : clamped;
    if ((next - _contentHeight).abs() > 3) {
      setState(() => _contentHeight = next);
    }
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
      _scheduleSyncIframe();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    final String? url = _blobUrl;
    if (url != null) {
      html.Url.revokeObjectUrl(url);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final String htmlStr = _htmlDoc();
    if (htmlStr.isEmpty) {
      return const SizedBox.shrink();
    }
    final double maxCap = widget.maxViewportHeight.clamp(48.0, 8000.0);
    final double displayHeight = widget.expandToContent
        ? _contentHeight.clamp(48.0, maxCap)
        : widget.clipOverflow
            ? maxCap
            : math.min(_contentHeight, maxCap);
    final Widget view = HtmlElementView(viewType: _viewType);
    final bool lockPreviewPointer =
        widget.expandToContent || widget.clipOverflow;
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: ColoredBox(
          color: widget.backgroundColor,
          child: SizedBox(
            height: displayHeight,
            width: double.infinity,
            child: lockPreviewPointer ? IgnorePointer(child: view) : view,
          ),
        ),
      ),
    );
  }
}
