import 'dart:math';

import 'package:charcode/ascii.dart';
import 'package:collection/collection.dart';
import 'package:highlight/highlight_core.dart';
import 'package:tuple/tuple.dart';

import '../../code/code_lines.dart';
import '../foldable_block_type.dart';
import 'text.dart';

/// A parser for foldable blocks from raw text.
class FallbackFoldableBlockParser extends TextFoldableBlockParser {
  final List<String> singleLineCommentSequences;
  final List<String> importPrefixes;

  /// [ ['/*', '*/'] , ...]
  final List<Tuple2<String, String>>? multilineCommentSequences;

  /// The size of a rolling window to remember processed characters.
  final int _tailLength;

  String? _startedMultilineCommentWith;

  /// If in a string literal the last char was a backslash.
  bool _wasBackslash = false;

  bool _isInDoubleQuoteLiteral = false;
  bool _isInMultilineComment = false;
  bool _isInSingleQuoteLiteral = false;
  bool _isLineStart = true;
  bool _isPossibleCommentSequence = false;
  bool _foundServiceSingleLineComment = false;

  FallbackFoldableBlockParser({
    required this.singleLineCommentSequences,
    required this.importPrefixes,
    this.multilineCommentSequences,
  }) : _tailLength = getTailLength(
          multilineCommentSequences,
          singleLineCommentSequences,
        );

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
      final char = String.fromCharCode(code);
      tail += char; // ignore: use_string_buffers
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
              if (c.contains(char)) {
                _isPossibleCommentSequence = true;
              }
            }

            if (isMultilineCommentingEnabled && !foundImportTerminator) {
              for (final c in multilineCommentSequences!) {
                if (tail.endsWith(c.item1)) {
                  if (!serviceCommentLines.contains(lineIndex)) {
                    startBlock(lineIndex, FoldableBlockType.multilineComment);
                    _startedMultilineCommentWith = c.item1;
                    _isInMultilineComment = true;
                    break;
                  }
                }
                if (c.item1.contains(char)) {
                  _isPossibleCommentSequence = true;
                }
              }
            }
          }

          if (isInMultilineComment) {
            for (final c in multilineCommentSequences!) {
              if (tail.endsWith(c.item2) &&
                  _startedMultilineCommentWith == c.item1) {
                if (!serviceCommentLines.contains(lineIndex)) {
                  final blocksCount = blocks.length;
                  endBlock(lineIndex, FoldableBlockType.multilineComment);
                  if (blocksCount == blocks.length) {
                    setFoundSingleLineComment();
                  }

                  _isInMultilineComment = false;
                  _startedMultilineCommentWith = null;
                  break;
                }
              }
            }
          }

          if (!_foundSingleLineComment &&
              !foundImport &&
              !_isPossibleCommentSequence) {
            setFoundImportTerminator();
          }
      }

      switch (code) {
        case $lf: // Newline
          _isInDoubleQuoteLiteral = false;
          _isInSingleQuoteLiteral = false;
          if (_isPossibleCommentSequence && !_foundSingleLineComment) {
            setFoundImportTerminator();
          }
          _isPossibleCommentSequence = false;
          submitCurrentLine();
          clearLineFlags();
          addToLineIndex(1);
          break;

        case $singleQuote: // '
          if (_foundSingleLineComment ||
              _wasBackslash ||
              isInMultilineComment) {
            break;
          }
          _isInSingleQuoteLiteral = !_isInSingleQuoteLiteral;
          break;

        case $doubleQuote: // "
          if (_foundSingleLineComment ||
              _wasBackslash ||
              isInMultilineComment) {
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
        !isInMultilineComment;
  }

  @override
  void submitCurrentLine() {
    _foundServiceSingleLineComment = false;
    _isLineStart = true;
    super.submitCurrentLine();
  }

  bool get _foundSingleLineComment =>
      _foundServiceSingleLineComment || foundSingleLineComment;

  bool get isInMultilineComment =>
      _isInMultilineComment && isMultilineCommentingEnabled;

  bool get isMultilineCommentingEnabled =>
      multilineCommentSequences != null &&
      multilineCommentSequences!.isNotEmpty;

  /// get max length of a sequence from possible sequences
  static int getTailLength(
    List<Tuple2<String, String>>? multilineCommentSequences,
    List<String> singleLineCommentSequences,
  ) =>
      [
        singleLineCommentSequences.map((s) => s.length).max,
        multilineCommentSequences
                ?.map((e) => max(e.item1.length, e.item2.length))
                .max ??
            0
      ].max;
}
