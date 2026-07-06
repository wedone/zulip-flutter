import 'package:mathlive_studio/mathlive_studio.dart';
import 'package:mathlive_studio/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('textUsesMathLivePreview detects inline delimiters', () {
    expect(textUsesMathLivePreview(r'Hi \(x\)'), isTrue);
    expect(textUsesMathLivePreview('plain'), isFalse);
  });

  test('parsePreviewParts splits text and math', () {
    final List<Map<String, String>> parts = parsePreviewParts(r'a \(b\) c');
    expect(parts.length, 3);
    expect(parts[0]['t'], 'text');
    expect(parts[1]['t'], 'math');
  });
}
