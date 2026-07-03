/// MathLive 公式插入工具。
///
/// 将 LaTeX 源码包装为 Zulip 服务器格式:
/// - 行内公式: `$$latex$$`
/// - 行间公式: ` ```math\nlatex\n``` `
///
/// 连续公式之间插入零宽空格(ZWSP, U+200B)避免界定符粘连
/// (如 ` ```...``````...``` ` 连续 6 个反引号无法渲染)。
///
/// 该文件只提供纯函数,不依赖 Flutter 或 compose_box.dart,
/// 以避免循环依赖。ZWSP 分隔的插入逻辑由调用方
/// (compose_box.dart 中的 [ComposeBoxController])实现。
library;

/// 公式类型。
enum FormulaType {
  /// 行内公式,界定符为 `$$…$$`。
  inline,

  /// 行间(块级)公式,界定符为 ` ```math\n…\n``` `。
  block,
}

/// 包装 LaTeX 为 Zulip 格式字符串。
///
/// [type] 为 [FormulaType.inline] 时返回 `$$latex$$`,
/// [type] 为 [FormulaType.block] 时返回 ` ```math\nlatex\n``` `。
///
/// 不对 [latex] 做任何转义;调用方需保证 LaTeX 源码本身不含
/// 会破坏界定符的字符(如行间公式内的反引号)。
String wrapFormula(FormulaType type, String latex) {
  switch (type) {
    case FormulaType.inline:
      return '\$\$$latex\$\$';
    case FormulaType.block:
      return '```math\n$latex\n```';
  }
}

/// 公式界定符的结尾/开头字符,用于 ZWSP 分隔检测。
///
/// 行内公式界定符为 `$$`,行间公式界定符为 ` ``` `。
/// 当连续两个公式之间没有其他字符时,前一个的结尾界定符
/// 与后一个的开头界定符会直接相邻,造成 6 个连续反引号
/// 或 4 个连续 `$`,服务器无法正确渲染。
/// 此时在两者之间插入 ZWSP (`\u200B`) 即可。
const List<String> formulaDelimiters = <String>['\$\$', '```'];
