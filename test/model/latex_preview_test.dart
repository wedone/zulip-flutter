import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:zulip/model/latex_preview.dart';

void main() {
  group('findLatexAtCursor', () {
    // $...$ inline math
    test(r'$x^2$ cursor in middle returns inline formula', () {
      final result = findLatexAtCursor(r'$x^2$', 3);
      check(result).isNotNull();
      check(result!.content).equals(r'x^2');
      check(result.displayMode).equals(false);
    });

    test(r'$x^2$ cursor at start (inside delimiter) returns formula', () {
      // Cursor at position 1 (just after opening $, inside the formula)
      final result = findLatexAtCursor(r'$x^2$', 1);
      check(result).isNotNull();
      check(result!.content).equals(r'x^2');
      check(result.displayMode).equals(false);
    });

    test(r'$x^2$ cursor at end (inside delimiter) returns formula', () {
      // Cursor at position 4 (just before closing $, inside the formula)
      final result = findLatexAtCursor(r'$x^2$', 4);
      check(result).isNotNull();
      check(result!.content).equals(r'x^2');
      check(result.displayMode).equals(false);
    });

    test(r'$x^2$ cursor at boundary (outside) returns null', () {
      // Cursor at position 0 (at opening $) or 5 (at closing $) is outside
      check(findLatexAtCursor(r'$x^2$', 0)).isNull();
      check(findLatexAtCursor(r'$x^2$', 5)).isNull();
      check(findLatexAtCursor(r'$x^2$', 6)).isNull();
    });

    // Unclosed $...$
    test(r'$x^2 without closing delimiter returns null', () {
      final result = findLatexAtCursor(r'$x^2', 3);
      check(result).isNull();
    });

    // Cursor outside delimiters
    test(r'cursor outside $...$ returns null', () {
      final text = r'a $x^2$ b';
      check(findLatexAtCursor(text, 0)).isNull();
      check(findLatexAtCursor(text, 8)).isNull();
    });

    // $$...$$ display math with newlines
    test(r'$$...$$ with newlines returns display formula', () {
      final text = '\$\$\nE = mc^2\n\$\$';
      final result = findLatexAtCursor(text, 5);
      check(result).isNotNull();
      check(result!.content).equals('\nE = mc^2\n');
      check(result.displayMode).equals(true);
    });

    // $$...$$ without newlines (inline math for preview)
    test(r'$$...$$ without newlines returns inline formula', () {
      final text = r'$$x^2$$';
      final result = findLatexAtCursor(text, 3);
      check(result).isNotNull();
      check(result!.content).equals(r'x^2');
      check(result.displayMode).equals(false);
    });

    // \[...\] display math
    test(r'\[...\] returns display formula', () {
      final text = r'\[E = mc^2\]';
      final result = findLatexAtCursor(text, 5);
      check(result).isNotNull();
      check(result!.content).equals(r'E = mc^2');
      check(result.displayMode).equals(true);
    });

    test(r'\[...\] without closing returns null', () {
      final result = findLatexAtCursor(r'\[E = mc^2', 5);
      check(result).isNull();
    });

    // \(...\) inline math
    test(r'\(...\) returns inline formula', () {
      final text = r'\(\alpha\)';
      final result = findLatexAtCursor(text, 4);
      check(result).isNotNull();
      check(result!.content).equals(r'\alpha');
      check(result.displayMode).equals(false);
    });

    test(r'\(...\) without closing returns null', () {
      final result = findLatexAtCursor(r'\(\alpha', 4);
      check(result).isNull();
    });

    // Multiple formulas: returns the one containing the cursor
    test('multiple formulas returns the one at cursor', () {
      final text = r'$a$ and $b$ and $c$';
      final resultA = findLatexAtCursor(text, 2);
      check(resultA).isNotNull();
      check(resultA!.content).equals('a');

      final resultB = findLatexAtCursor(text, 9);
      check(resultB).isNotNull();
      check(resultB!.content).equals('b');

      final resultC = findLatexAtCursor(text, 16);
      check(resultC).isNotNull();
      check(resultC!.content).equals('c');
    });

    // Cursor between two formulas (strictly outside)
    test(r'\[a\] \[b\] cursor between formulas returns null', () {
      final text = r'\[a\] \[b\]';
      // Cursor at position 5 (space between the two formulas)
      check(findLatexAtCursor(text, 5)).isNull();
    });

    test(r'$a$ $b$ cursor between formulas returns null', () {
      final text = r'$a$ $b$';
      // Cursor at position 4 (space between)
      check(findLatexAtCursor(text, 4)).isNull();
    });

    // Empty content
    test('empty text returns null', () {
      check(findLatexAtCursor('', 0)).isNull();
    });

    // No formulas at all
    test('plain text returns null', () {
      check(findLatexAtCursor('Just plain text', 5)).isNull();
    });

    // $...$ with newlines should not match (inline math rule)
    test(r'$...$ with newlines returns null', () {
      final text = '\$x\ny\$';
      final result = findLatexAtCursor(text, 2);
      check(result).isNull();
    });

    // Mixed content
    test(r'mixed content with $ and \[', () {
      final text = r'Text $x$ and \[E = mc^2\]';
      final resultInline = findLatexAtCursor(text, 6);
      check(resultInline).isNotNull();
      check(resultInline!.content).equals('x');
      check(resultInline.displayMode).equals(false);

      final resultDisplay = findLatexAtCursor(text, 18);
      check(resultDisplay).isNotNull();
      check(resultDisplay!.content).equals(r'E = mc^2');
      check(resultDisplay.displayMode).equals(true);
    });

    // Invalid cursor position
    test('negative cursor position returns null', () {
      check(findLatexAtCursor(r'$x$', -1)).isNull();
    });

    test('cursor position beyond text length returns null', () {
      check(findLatexAtCursor(r'$x$', 10)).isNull();
    });

    // Escaped delimiters
    test(r'\$5.00 is not a formula delimiter', () {
      final result = findLatexAtCursor(r'\$5.00', 2);
      check(result).isNull();
    });

    test(r'text with \$5 and $x^2$ only matches $x^2$', () {
      final text = r'\$5 and $x^2$';
      // Cursor inside $x^2$ (position 10 is the ^)
      final result = findLatexAtCursor(text, 10);
      check(result).isNotNull();
      check(result!.content).equals(r'x^2');
      // Cursor at \$5 (position 2) should not match
      check(findLatexAtCursor(text, 2)).isNull();
    });

    // $$ with newlines takes precedence over $$ without
    test(r'$$ with newlines takes precedence over $$ without', () {
      final text = '\$\$\nx^2\n\$\$';
      final result = findLatexAtCursor(text, 3);
      check(result).isNotNull();
      check(result!.displayMode).equals(true);
    });

    // Multiple $$ blocks
    test(r'multiple $$ blocks returns the one at cursor', () {
      final text = '\$\$\na\n\$\$ and \$\$\nb\n\$\$';
      final resultA = findLatexAtCursor(text, 3);
      check(resultA).isNotNull();
      check(resultA!.content).equals('\na\n');

      final resultB = findLatexAtCursor(text, 15);
      check(resultB).isNotNull();
      check(resultB!.content).equals('\nb\n');
    });
  });
}