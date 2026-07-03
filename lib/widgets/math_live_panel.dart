import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

/// A panel that hosts the MathLive math formula editor inside a [WebView].
///
/// The editor is loaded from the bundled asset
/// `assets/mathlive/mathlive_editor.html`. When the user taps the insert key
/// in the MathLive virtual keyboard, the HTML page posts a JSON message
/// (`{type, latex}`) back to Dart through the `InsertChannel` JavaScript
/// channel, and [onFormulaInserted] is invoked with `type` being either
/// `'inline'` or `'block'`.
class MathLivePanel extends StatefulWidget {
  const MathLivePanel({
    super.key,
    required this.isDark,
    required this.onFormulaInserted,
  });

  /// Whether the editor should render in dark mode.
  final bool isDark;

  /// Called when the user inserts a formula from the editor.
  ///
  /// `type` is either `'inline'` or `'block'`; `latex` is the LaTeX source of
  /// the formula the user composed.
  final void Function(String type, String latex) onFormulaInserted;

  @override
  State<MathLivePanel> createState() => _MathLivePanelState();
}

class _MathLivePanelState extends State<MathLivePanel> {
  WebViewController? _controller;
  bool _loading = true;
  String? _error;
  bool _ready = false;

  Color get _bg => widget.isDark ? const Color(0xFF141922) : Colors.white;
  Color get _fg => widget.isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'InsertChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (!mounted) return;
          try {
            final decoded = jsonDecode(message.message) as Map<String, dynamic>;
            final type = decoded['type'] as String?;
            final latex = decoded['latex'] as String?;
            if (type != null && latex != null) {
              widget.onFormulaInserted(type, latex);
            }
          } catch (_) {}
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _loading = true;
                _error = null;
              });
            }
          },
          onPageFinished: (_) async {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _ready = true;
            });
            await _applyTheme();
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame == false) return;
            if (mounted) {
              setState(() {
                _loading = false;
                _error = error.description;
              });
            }
          },
        ),
      );
    unawaited(_bootstrap());
  }

  Future<void> _tunePlatform() async {
    final WebViewController? c = _controller;
    if (c == null) return;
    try {
      await c.enableZoom(false);
    } catch (_) {}
    if (defaultTargetPlatform != TargetPlatform.android) return;
    if (c.platform is! AndroidWebViewController) return;
    final AndroidWebViewController android =
        c.platform as AndroidWebViewController;
    try {
      await android.setAllowFileAccess(true);
    } catch (_) {}
    try {
      await android.setMediaPlaybackRequiresUserGesture(false);
    } catch (_) {}
  }

  Future<void> _bootstrap() async {
    await _tunePlatform();
    final WebViewController? c = _controller;
    if (!mounted || c == null) return;
    try {
      final String html =
          await rootBundle.loadString('assets/mathlive/mathlive_editor.html');
      final String js =
          await rootBundle.loadString('assets/mathlive/mathlive.mjs');
      final String patched =
          html.replaceFirst("import './mathlive.mjs';", js);
      await c.loadHtmlString(
        patched,
        baseUrl: 'file:///android_asset/flutter_assets/assets/mathlive/',
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load math editor';
        });
      }
    }
  }

  Future<void> _applyTheme() async {
    final WebViewController? c = _controller;
    if (c == null) return;
    try {
      await c.runJavaScript(
        'try{mlSetTheme(${widget.isDark ? 'true' : 'false'});}catch(e){}',
      );
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant MathLivePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark && _ready) {
      unawaited(_applyTheme());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 320,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (_controller != null)
              ColoredBox(
                color: _bg,
                child: WebViewWidget(controller: _controller!),
              ),
            if (_loading) _loadingOverlay(),
            if (_error != null && !_loading) _errorOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _loadingOverlay() {
    return ColoredBox(
      color: _bg.withValues(alpha: 0.88),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(color: _fg),
            const SizedBox(height: 12),
            Text('加载 MathLive…', style: TextStyle(fontSize: 13, color: _fg)),
          ],
        ),
      ),
    );
  }

  Widget _errorOverlay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: _fg),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _loading = true;
                });
                unawaited(_bootstrap());
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
