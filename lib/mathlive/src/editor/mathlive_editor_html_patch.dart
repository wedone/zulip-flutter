/// Replaces placeholders in [assets/mathlive/mathlive_editor.html] after load.
String patchMathLiveEditorHtml(String raw, {String? rootAndClientId}) {
  final String id = rootAndClientId ?? 'mathlive-mixed-root';
  return raw
      .replaceAll('MATHLIVE_MIXED_ROOT_ID', id)
      .replaceAll('___MATHLIVE_MIXED_CLIENT___', id);
}

/// Asset path for [rootBundle.loadString].
const String kMathLiveEditorHtmlAsset =
    'assets/mathlive/mathlive_editor.html';
