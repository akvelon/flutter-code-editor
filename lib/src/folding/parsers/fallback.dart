// ignore_for_file: use_string_buffers

import 'package:charcode/ascii.dart';
import 'package:highlight/highlight_core.dart';
import 'package:tuple/tuple.dart';

import '../../code/code_lines.dart';
import '../foldable_block_type.dart';
import 'text.dart';

/// A parser for foldable blocks from raw text.
class FallbackFoldableBlockParser extends TextFoldableBlockParser {
  final List<String> importPrefixes;

  /// [ ['/*', '*/'] , ...]
  final List<Tuple2<String, String>> multilineCommentSequences;

  /// ['//', '#']
  final List<String> singleLineCommentSequences;

  String? _startedMultilineCommentWith;
  int? _startedMultilineCommentAt;
  bool get _isInMultilineComment => _startedMultilineCommentWith != null;

  /// If in a string literal the last char was a backslash.
  bool _wasBackslash = false;

  bool _isInSingleQuoteLiteral = false;
  bool _isInDoubleQuoteLiteral = false;

  bool _foundServiceSingleLineComment = false;
  bool _isLineStart = true;

  FallbackFoldableBlockParser({
    required this.importPrefixes,
    this.multilineCommentSequences = const [],
    required this.singleLineCommentSequences,
  });

  @override
  void parse({
    required Result highlighted,
    required Set<Object?> serviceCommentsSources,
    required CodeLines lines,
  }) {
    final text = _requireText(highlighted);

    _processText(
      text: text,
      serviceCommentLines: serviceCommentsSources.whereType<int>().toSet(),
      lines: lines,
    );

    finalize();
  }

  String _requireText(Result highlighted) {
    if (highlighted.nodes?.length != 1) {
      throw Exception('A single-node highlighted result is required for this.');
    }

    final text = highlighted.nodes?.first.value;
    if (text == null) {
      throw Exception('No text found in the highlighted result.');
    }

    return text;
  }

  void _processText({
    required String text,
    required Set<int> serviceCommentLines,
    required CodeLines lines,
  }) {
    String line = '';

    for (final code in text.runes) {
      line += String.fromCharCode(code);

      if (_isLineStart) {
        final lineText = lines[lineIndex].text;
        if (importPrefixes.any(lineText.startsWith)) {
          setFoundImport();
        }
      }

      switch (code) {
        case $space:
        case $tab:
        case $cr:
        case $lf:
          break;

        default:
          if (_canStartLexeme()) {
            setFoundNonWhitespace();

            for (final c in singleLineCommentSequences) {
              if (line.endsWith(c)) {
                if (!serviceCommentLines.contains(lineIndex)) {
                  setFoundSingleLineComment();
                } else {
                  // Do not trigger super's foundSingleLineComment()
                  // so this comment does not join a possible comment block.
                  _foundServiceSingleLineComment = true;
                }

                if (line.replaceFirst(c, '').trim() != '') {
                  // If there are some symbols before comment sequence,
                  // the line is a terminator for an import block.
                  setFoundImportTerminator();
                }
                break;
              }
            }

            for (final c in multilineCommentSequences) {
              if (line.endsWith(c.item1)) {
                startBlock(lineIndex, FoldableBlockType.multilineComment);
                setFoundMultilineComment();

                _startedMultilineCommentAt = lineIndex;
                _startedMultilineCommentWith = c.item1;

                if (line.replaceFirst(c.item1, '').trim() != '') {
                  setFoundImportTerminator();
                }
                break;
              }
            }
          }

          if (_isInMultilineComment) {
            for (final c in multilineCommentSequences) {
              if (line.endsWith(c.item2) &&
                  _startedMultilineCommentWith == c.item1) {
                endBlock(lineIndex, FoldableBlockType.multilineComment);

                if (_startedMultilineCommentAt == lineIndex &&
                    lines.lines[lineIndex].text.trim() == line.trim()) {
                  // If multiline comment terminated on the same line and
                  // the full line text doesn't contain anything except comment.
                  setFoundSingleLineComment();
                }

                if (line.trim().startsWith(c.item1) ||
                    !line.contains(c.item1)) {
                  // If the line only contains multiline comment we can reset it
                  // without any issue.
                  // It is needed if there is a single line comment afterwards:
                  // /* this is a comment  */    // and this is also a comment
                  line = '';
                }

                _startedMultilineCommentAt = null;
                _startedMultilineCommentWith = null;
                break;
              }
            }
          }
      }

      switch (code) {
        case $lf: // Newline
          if (foundNonWhitespace &&
              !_foundSingleLineComment &&
              !foundImport &&
              !_isInMultilineComment) {
            setFoundImportTerminator();
          }

          if (_isInMultilineComment) {
            setFoundMultilineComment();
          }

          line = '';
          _isInDoubleQuoteLiteral = false;
          _isInSingleQuoteLiteral = false;
          submitCurrentLine();
          clearLineFlags();
          addToLineIndex(1);
          break;

        case $singleQuote: // '
          if (_foundSingleLineComment ||
              _wasBackslash ||
              _isInMultilineComment) {
            break;
          }
          _isInSingleQuoteLiteral = !_isInSingleQuoteLiteral;
          break;

        case $doubleQuote: // "
          if (_foundSingleLineComment ||
              _wasBackslash ||
              _isInMultilineComment) {
            break;
          }
          _isInDoubleQuoteLiteral = !_isInDoubleQuoteLiteral;
          break;

        case $openParenthesis: // (
          if (_canStartLexeme()) {
            startBlock(lineIndex, FoldableBlockType.parentheses);
          }
          break;

        case $closeParenthesis: // )
          if (_canStartLexeme()) {
            endBlock(lineIndex, FoldableBlockType.parentheses);
          }
          break;

        case $openBracket: // [
          if (_canStartLexeme()) {
            startBlock(lineIndex, FoldableBlockType.brackets);
          }
          break;

        case $closeBracket: // ]
          if (_canStartLexeme()) {
            endBlock(lineIndex, FoldableBlockType.brackets);
          }
          break;

        case $openBrace: // {
          if (_canStartLexeme()) {
            startBlock(lineIndex, FoldableBlockType.braces);
          }
          break;

        case $closeBrace: // }
          if (_canStartLexeme()) {
            endBlock(lineIndex, FoldableBlockType.braces);
          }
          break;
      }

      if (_isInLiteralSupportingSlash()) {
        if (code == $backslash) {
          _wasBackslash = !_wasBackslash;
        } else {
          _wasBackslash = false;
        }
      }
    }
  }

  bool _isInLiteralSupportingSlash() {
    return _isInSingleQuoteLiteral || _isInDoubleQuoteLiteral;
  }

  bool _isInStringLiteral() {
    return _isInSingleQuoteLiteral || _isInDoubleQuoteLiteral;
  }

  bool _canStartLexeme() {
    return !_isInStringLiteral() &&
        !_foundSingleLineComment &&
        !_isInMultilineComment;
  }

  @override
  void submitCurrentLine() {
    _foundServiceSingleLineComment = false;
    _isLineStart = true;
    super.submitCurrentLine();
  }

  bool get _foundSingleLineComment =>
      _foundServiceSingleLineComment || foundSingleLineComment;
}
