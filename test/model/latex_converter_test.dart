import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:zulip/model/latex_converter.dart';

void main() {
  group('convertLatexDelimitersToZulip', () {
    // Rule 1: \[...\] → ```math\n...\n```
    test(r'\[...\] converts to ```math block', () {
      check(convertLatexDelimitersToZulip(r'\[E = mc^2\]'))
        .equals('```math\nE = mc^2\n```');
    });

    // Rule 2: $$...$$ with newlines → ```math\n...\n```
    test(r'$$...$$ with newlines converts to ```math block', () {
      check(convertLatexDelimitersToZulip('\$\$\nE = mc^2\n\$\$'))
        .equals('```math\n\nE = mc^2\n\n```');
    });

    // Rule 3: \(...\) → $$...$$
    test(r'\(...\) converts to $$...$$', () {
      check(convertLatexDelimitersToZulip(r'\(x^2\)'))
        .equals(r'$$x^2$$');
    });

    // Rule 4: $...$ → $$...$$
    test(r'$...$ converts to $$...$$', () {
      check(convertLatexDelimitersToZulip(r'$x^2$'))
        .equals(r'$$x^2$$');
    });

    test(r'inline formula $E = mc^2$ converts to $$E = mc^2$$', () {
      check(convertLatexDelimitersToZulip(r'$E = mc^2$'))
        .equals(r'$$E = mc^2$$');
    });

    test(r'display formula $$\int_a^b f(x)dx$$ with newlines converts to ```math block', () {
      check(convertLatexDelimitersToZulip('\$\$\n\\int_a^b f(x)dx\n\$\$'))
        .equals('```math\n\n\\int_a^b f(x)dx\n\n```');
    });

    test(r'display formula $$\int_a^b f(x)dx$$ without newlines stays as-is', () {
      check(convertLatexDelimitersToZulip(r'$$\int_a^b f(x)dx$$'))
        .equals(r'$$\int_a^b f(x)dx$$');
    });

    test(r'LaTeX inline \(\alpha\) converts to $$\alpha$$', () {
      check(convertLatexDelimitersToZulip(r'\(\alpha\)'))
        .equals(r'$$\alpha$$');
    });

    test(r'LaTeX display \[\beta\] converts to ```math block', () {
      check(convertLatexDelimitersToZulip(r'\[\beta\]'))
        .equals('```math\n\\beta\n```');
    });

    test('code blocks containing \$ should not be converted', () {
      final input = '```\nvar x = \$5\n```\n\$x^2\$';
      final result = convertLatexDelimitersToZulip(input);
      check(result).equals('```\nvar x = \$5\n```\n\$\$x^2\$\$');
    });

    test('code blocks with language hint containing \$ should not be converted', () {
      final input = '```python\nprice = \$10\n```';
      check(convertLatexDelimitersToZulip(input))
        .equals('```python\nprice = \$10\n```');
    });

    test('inline code containing \$ should not be converted', () {
      final input = 'Use `\$5` not \$x\$';
      final result = convertLatexDelimitersToZulip(input);
      check(result).equals('Use `\$5` not \$\$x\$\$');
    });

    test(r'escaped \$ should not be treated as delimiter', () {
      final input = r'Price is \$5 and $x^2$';
      final result = convertLatexDelimitersToZulip(input);
      check(result).equals(r'Price is \$5 and $$x^2$$');
    });

    test(r'already-Zulip format $$...$$ without newlines should not be double-converted', () {
      check(convertLatexDelimitersToZulip(r'$$x^2$$'))
        .equals(r'$$x^2$$');
    });

    test('already existing ```math blocks should not be re-converted', () {
      final input = '```math\nE = mc^2\n```';
      check(convertLatexDelimitersToZulip(input))
        .equals('```math\nE = mc^2\n```');
    });

    test(r'$$ without newlines should remain as-is', () {
      check(convertLatexDelimitersToZulip(r'$$x^2 + y^2$$'))
        .equals(r'$$x^2 + y^2$$');
    });

    test(r'$$ with newlines should convert to ```math```', () {
      check(convertLatexDelimitersToZulip('\$\$\nx^2 + y^2\n\$\$'))
        .equals('```math\n\nx^2 + y^2\n\n```');
    });

    test('content with no formulas at all', () {
      final input = 'Just plain text with no math at all.';
      check(convertLatexDelimitersToZulip(input))
        .equals(input);
    });

    test('mixed content with multiple formula types', () {
      // $x$ → $$x$$, \[E = mc^2\] → ```math```, \(y\) → $$y$$
      final input = r'Text with $x$ and \[E = mc^2\] and \(y\).';
      final result = convertLatexDelimitersToZulip(input);
      check(result).equals(
        'Text with \$\$x\$\$ and ```math\nE = mc^2\n``` and \$\$y\$\$.');
    });

    test('multiple inline formulas in one line', () {
      check(convertLatexDelimitersToZulip(r'$a$ and $b$ and $c$'))
        .equals(r'$$a$$ and $$b$$ and $$c$$');
    });

    test('display math with multiline content', () {
      final input = r'\[\begin{aligned} x &= 1 \\ y &= 2 \end{aligned}\]';
      check(convertLatexDelimitersToZulip(input))
        .equals('```math\n\\begin{aligned} x &= 1 \\\\ y &= 2 \\end{aligned}\n```');
    });

    test('inline code with backticks inside larger text', () {
      final input = 'The `\$HOME` variable and \$x\$ formula';
      final result = convertLatexDelimitersToZulip(input);
      check(result).equals('The `\$HOME` variable and \$\$x\$\$ formula');
    });

    test('code block followed by math', () {
      final input = '```\ncode\n```\n\$x\$';
      final result = convertLatexDelimitersToZulip(input);
      check(result).equals('```\ncode\n```\n\$\$x\$\$');
    });

    test(r'existing ```math block followed by new math', () {
      final input = '```math\nE = mc^2\n```\n\$x\$';
      final result = convertLatexDelimitersToZulip(input);
      check(result).equals('```math\nE = mc^2\n```\n\$\$x\$\$');
    });

    test(r'\[...\] containing $ signs are protected after conversion', () {
      // After \[...\] is converted to ```math block, the escaped \$ inside
      // is restored as-is (LaTeX \$ renders as literal $ in math blocks).
      final input = r'\[\$5 + \$10\]';
      final result = convertLatexDelimitersToZulip(input);
      check(result).equals('```math\n' r'\$5 + \$10' '\n```');
    });

    test(r'$$...$$ with newlines containing $ signs are protected after conversion', () {
      // After $$...$$ with newlines is converted to ```math block,
      // the $ signs inside should not be further converted by Rule 4.
      final input = '\$\$\n\\\$5 + \\\$10\n\$\$';
      final result = convertLatexDelimitersToZulip(input);
      check(result).equals('```math\n\n\\\$5 + \\\$10\n\n```');
    });

    test(r'\(...\) with newlines converts to $$...$$, not ```math block', () {
      // Regression test: \(...\) is LaTeX inline math and should always
      // map to $$...$$ (Zulip inline), even if the content contains newlines.
      // Before the fix, Rule 3 (now Rule 2) would incorrectly convert the
      // $$...$$ produced by this rule to a ```math block.
      check(convertLatexDelimitersToZulip('\\(x\ny\\)'))
        .equals('\$\$x\ny\$\$');
    });

    test(r'$$...$$ with newlines and \(...\) both present', () {
      // Verify that $$...$$ with newlines is converted to ```math```
      // and \(...\) is independently converted to $$...$$.
      final input = '\$\$\nx^2\n\$\$ and \\(y^2\\)';
      check(convertLatexDelimitersToZulip(input))
        .equals('```math\n\nx^2\n\n``` and \$\$y^2\$\$');
    });

    test(r'$$...$$ without newlines and \(...\) both present', () {
      // Verify that $$...$$ without newlines is left as-is
      // and \(...\) is independently converted to $$...$$.
      final input = r'$$x^2$$ and \(y^2\)';
      check(convertLatexDelimitersToZulip(input))
        .equals(r'$$x^2$$ and $$y^2$$');
    });

    // Step 2.5: ZWSP insertion for $$ adjacent to \w characters.
    // The server's TEX_RE uses \B around $$, which fails when $$
    // is adjacent to a \w character. ZWSP (U+200B) breaks the
    // word boundary so the server regex matches.

    test(r'a$$...$$ (letter before opening $$)', () {
      check(convertLatexDelimitersToZulip(r'a$$x^2$$'))
        .equals('a\u200B$$x^2$$');
    });

    test(r'$$...$$a (letter after closing $$)', () {
      check(convertLatexDelimitersToZulip(r'$$x^2$$a'))
        .equals('$$x^2$$\u200Ba');
    });

    test(r'a$$...$$b (letters on both sides)', () {
      check(convertLatexDelimitersToZulip(r'a$$x^2$$b'))
        .equals('a\u200B$$x^2$$\u200Bb');
    });

    test(r'内容$$...$$ (Chinese before opening $$)', () {
      check(convertLatexDelimitersToZulip(r'内容$$x^2$$'))
        .equals('内容\u200B$$x^2$$');
    });

    test(r'$$...$$内容 (Chinese after closing $$)', () {
      check(convertLatexDelimitersToZulip(r'$$x^2$$内容'))
        .equals('$$x^2$$\u200B内容');
    });

    test(r'$$...$$1 (digit after closing $$, needs ZWSP)', () {
      // Digits are \w, so \B fails; ZWSP is needed.
      check(convertLatexDelimitersToZulip(r'$$x^2$$1'))
        .equals('$$x^2$$\u200B1');
    });

    test(r'#$$...$$ (symbol before, no ZWSP needed)', () {
      check(convertLatexDelimitersToZulip(r'#$$x^2$$'))
        .equals(r'#$$x^2$$');
    });

    test(r'$$...$$% (symbol after, no ZWSP needed)', () {
      check(convertLatexDelimitersToZulip(r'$$x^2$$%'))
        .equals(r'$$x^2$$%');
    });

    test(r'$...$ with adjacent letter before', () {
      // $...$ → $$...$$, then ZWSP inserted for adjacent letter.
      check(convertLatexDelimitersToZulip(r'a$x^2$'))
        .equals('a\u200B$$x^2$$');
    });

    test(r'$...$ with adjacent letter after', () {
      check(convertLatexDelimitersToZulip(r'$x^2$b'))
        .equals('$$x^2$$\u200Bb');
    });

    test(r'$$...$$ adjacent to Greek letter', () {
      check(convertLatexDelimitersToZulip(r'α$$x^2$$'))
        .equals('α\u200B$$x^2$$');
    });

    test(r'code block with $$ adjacent to letters is not affected', () {
      final input = '```\na$$x^2$$\n```\n$$y^2$$z';
      final result = convertLatexDelimitersToZulip(input);
      // The code block's $$ should remain untouched.
      // The external $$y^2$$z should get ZWSP after closing.
      check(result).contains(r'```\na$$x^2$$\n```');
      check(result).contains('$$y^2$$\u200Bz');
    });

    test(r'multiple $$...$$ with adjacent letters', () {
      check(convertLatexDelimitersToZulip(r'a$$x^2$$b$$y^2$$c'))
        .equals('a\u200B$$x^2$$\u200Bb\u200B$$y^2$$\u200Bc');
    });
  });
}
