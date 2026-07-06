import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mathlive_studio/mathlive_studio.dart';
import 'package:mathlive_studio/utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MathLiveMixedExampleApp());
}

class MathLiveMixedExampleApp extends StatefulWidget {
  const MathLiveMixedExampleApp({super.key});

  @override
  State<MathLiveMixedExampleApp> createState() =>
      _MathLiveMixedExampleAppState();
}

class _MathLiveMixedExampleAppState extends State<MathLiveMixedExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathLive Mixed Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: ExampleHome(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: () {
          setState(() {
            _themeMode =
                _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
          });
        },
      ),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('mathlive_studio'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const <Tab>[
            Tab(text: 'Preview'),
            Tab(text: 'Editor'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: <Widget>[
          PreviewDemoTab(isDark: widget.isDark),
          EditorDemoTab(isDark: widget.isDark),
        ],
      ),
    );
  }
}

class PreviewDemoTab extends StatefulWidget {
  const PreviewDemoTab({super.key, required this.isDark});

  final bool isDark;

  @override
  State<PreviewDemoTab> createState() => _PreviewDemoTabState();
}

class _PreviewDemoTabState extends State<PreviewDemoTab> {
  int _sampleIndex = 0;
  bool _displayOnly = false;
  bool _clipOverflow = false;
  bool _expandToContent = true;

  static final List<String> _samples = <String>[
    'Plain text without math.',
    r'The quadratic formula: \(x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}\) for \(ax^2+bx+c=0\).',
    r'Mixed line: cost is \(12.50\) dollars and rate is \(\frac{3}{4}\).',
    '${'Long content:\n' * 8}${r'End with \(\sum_{i=1}^{n} i = \frac{n(n+1)}{2}\).'}',
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle base = TextStyle(
      fontSize: 15,
      height: 1.45,
      color: scheme.onSurface,
    );
    final String text = _samples[_sampleIndex];
    final bool useMathLive = textUsesMathLivePreview(text);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Sample', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: List<ButtonSegment<int>>.generate(
            _samples.length,
            (int i) => ButtonSegment<int>(value: i, label: Text('${i + 1}')),
          ),
          selected: <int>{_sampleIndex},
          onSelectionChanged: (Set<int> s) {
            setState(() => _sampleIndex = s.first);
          },
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('displayOnly'),
          value: _displayOnly,
          onChanged: (bool v) => setState(() => _displayOnly = v),
        ),
        SwitchListTile(
          title: const Text('clipOverflow'),
          value: _clipOverflow,
          onChanged: (bool v) => setState(() => _clipOverflow = v),
        ),
        SwitchListTile(
          title: const Text('expandToContent'),
          value: _expandToContent,
          onChanged: (bool v) => setState(() => _expandToContent = v),
        ),
        Text(
          useMathLive
              ? 'Using MathLiveMixedPreview'
              : 'Using InlineTexMixedText (fallback)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: useMathLive
              ? MathLiveMixedPreview(
                  previewText: text,
                  isDark: widget.isDark,
                  backgroundColor: scheme.surfaceContainerHighest,
                  baseStyle: base,
                  maxViewportHeight: _clipOverflow ? 72 : null,
                  expandToContent: _expandToContent,
                  displayOnly: _displayOnly,
                  clipOverflow: _clipOverflow,
                  preventShrinkingReportedHeight: _expandToContent,
                )
              : InlineTexMixedText(source: text, style: base),
        ),
        const SizedBox(height: 16),
        Text('Raw', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        SelectableText(text, style: base.copyWith(fontSize: 13)),
      ],
    );
  }
}

class EditorDemoTab extends StatefulWidget {
  const EditorDemoTab({super.key, required this.isDark});

  final bool isDark;

  @override
  State<EditorDemoTab> createState() => _EditorDemoTabState();
}

class _EditorDemoTabState extends State<EditorDemoTab> {
  String _latex = r'\frac{1}{2}';
  final ValueNotifier<String> _snapshot = ValueNotifier<String>('');

  @override
  void dispose() {
    _snapshot.dispose();
    super.dispose();
  }

  Future<void> _copyLatex() async {
    final String t = _snapshot.value.trim().isNotEmpty ? _snapshot.value : _latex;
    await Clipboard.setData(ClipboardData(text: t));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied: $t')),
    );
  }

  Future<void> _openFullEditor() async {
    final String? result = await MathLiveEditorPage.open(
      context,
      isDark: widget.isDark,
      initialLatex: _latex,
    );
    if (result != null) {
      setState(() => _latex = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle base = TextStyle(
      fontSize: 15,
      height: 1.45,
      color: scheme.onSurface,
    );
    final String previewBody =
        _latex.contains(r'\(') ? _latex : r'\(' + _latex + r'\)';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        MathLiveEmbeddedEditor(
          isDark: widget.isDark,
          initialLatex: _latex,
          height: 280,
          latexSnapshot: _snapshot,
          onLatexChanged: (String v) => setState(() => _latex = v),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            FilledButton(
              onPressed: _copyLatex,
              child: const Text('Copy LaTeX'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _openFullEditor,
              child: const Text('Full-screen editor'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Live preview', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        MathLiveMixedPreview(
          previewText: previewBody,
          isDark: widget.isDark,
          backgroundColor: scheme.surfaceContainerHighest,
          baseStyle: base,
          expandToContent: true,
          displayOnly: true,
        ),
        const SizedBox(height: 12),
        SelectableText(
          'LaTeX: $_latex',
          style: base.copyWith(fontSize: 13),
        ),
      ],
    );
  }
}
