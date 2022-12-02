import 'dart:math';

import 'package:charcode/ascii.dart';
import 'package:collection/collection.dart';
import 'package:highlight/highlight_core.dart';

import '../../code/code_lines.dart';
import '../foldable_block_type.dart';
import 'text.dart';

/// A parser for foldable blocks from raw text.
class FallbackFoldableBlockParser extends TextFoldableBlockParser {
  final List<String> singleLineCommentSequences;
  final List<String> importPrefixes;

  /// The size of a rolling window to remember processed characters.
  final int _tailLength;

  /// If in a string literal the last char was a backslash.
  bool _wasBackslash = false;

  bool _isInSingleQuoteLiteral = false;
  bool _isInDoubleQuoteLiteral = false;
  bool _foundServiceSingleLineComment = false;
  bool _isLineStart = true;

  FallbackFoldableBlockParser({
    required this.singleLineCommentSequences,
    required this.importPrefixes,
  }) : _tailLength = singleLineCommentSequences.map((s) => s.length).max;

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
    String tail = '';

    for (final code in text.runes) {
      tail += String.fromCharCode(code); // ignore: use_string_buffers
      tail = tail.substring(max(0, tail.length - _tailLength));

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
          setFoundNonWhitespace();

          if (_canStartLexeme()) {
            for (final c in singleLineCommentSequences) {
              if (tail.endsWith(c)) {
                if (!serviceCommentLines.contains(lineIndex)) {
                  setFoundSingleLineComment();
                } else {
                  // Do not trigger super's foundSingleLineComment()
                  // so this comment does not join a possible comment block.
                  _foundServiceSingleLineComment = true;
                }
                break;
              }
            }
          }

          if (!_foundSingleLineComment && !foundImport) {
            setFoundImportTerminator();
          }
      }

      switch (code) {
        case $lf: // Newline
          submitCurrentLine();
          clearLineFlags();
          addToLineIndex(1);
          break;

        case $singleQuote: // '
          if (_foundSingleLineComment || _wasBackslash) {
            break;
          }
          _isInSingleQuoteLiteral = !_isInSingleQuoteLiteral;
          break;

        case $doubleQuote: // "
          if (_foundSingleLineComment || _wasBackslash) {
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
    return !_isInStringLiteral() && !_foundSingleLineComment;
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
