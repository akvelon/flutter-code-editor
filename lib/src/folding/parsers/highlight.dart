import 'package:charcode/ascii.dart';
import 'package:collection/collection.dart';
import 'package:highlight/highlight_core.dart';

import '../../../flutter_code_editor.dart';
import '../../highlight/keyword_semantics.dart';
import '../../highlight/node.dart';
import '../../highlight/node_classes.dart';
import 'abstract.dart';
import 'line_semantics.dart';

/// A parser for foldable blocks from highlight's [Result].
class HighlightFoldableBlockParser extends AbstractFoldableBlockParser {
  int _lineIndex = 0;

  /// If in the current line we found any keyword with import semantics.
  bool _foundImport = false;

  /// If in the current line we found any keyword that may or may not
  /// have import semantics depending on the context.
  bool _foundPossibleImport = false;

  /// If in the current line we found anything that terminates
  /// an import sequence.
  bool _foundImportTerminator = false;

  /// If in the current line we found a single-line comment.
  bool _foundSingleLineComment = false;

  /// If in the current line we found a non-whitespace character that is
  /// not a comment.
  bool _foundNonWhitespace = false;

  @override
  void parse(
    Result highlighted,
    Set<Object?> serviceCommentsSources,
    List<CodeLine> lines,
  ) {
    if (highlighted.nodes != null) {
      _processNodes(highlighted.nodes!, serviceCommentsSources);
    }

    _submitLine(); // In case the last one did not end with '\n'.
    finalize();
  }

  void _processNodes(List<Node> nodes, Set<Object?> serviceCommentsSources) {
    for (final node in nodes) {
      _processNode(node, serviceCommentsSources);
    }
  }

  void _processNode(Node node, Set<Object?> serviceCommentsSources) {
    switch (node.className) {
      case NodeClasses.comment:
        _processComment(node, serviceCommentsSources);
        break;

      case NodeClasses.keyword:
        _processKeyword(node);
        break;

      case NodeClasses.string:
        _processString(node);
        break;

      default:
        _processDefault(node, serviceCommentsSources);
    }
  }

  void _processComment(Node node, Set<Object?> serviceComments) {
    final newlineCount = node.getNewlineCount();

    if (_foundNonWhitespace) {
      return;
    }

    if (serviceComments.contains(node)) {
      return;
    }

    if (newlineCount == 0) {
      _foundSingleLineComment = true;
      return;
    }

    _foundImportTerminator = true;
    _submitLine();

    startBlock(_lineIndex, FoldableBlockType.multilineComment);

    _lineIndex += newlineCount;
    endBlock(_lineIndex, FoldableBlockType.multilineComment);
  }

  void _processKeyword(Node node) {
    final child = node.children?.firstOrNull;
    if (child == null) {
      return;
    }

    final semantics = node.keywordSemantics;

    switch (semantics) {
      case KeywordSemantics.import:
        _foundImport = true;
        break;
      case KeywordSemantics.possibleImport:
        _foundPossibleImport = true;
        break;
      case null:
        _foundImportTerminator = true;
        break;
    }
  }

  void _processString(Node node) {
    final newlineCount = node.getNewlineCount();

    _foundNonWhitespace = true;
    if (newlineCount > 0) {
      _foundImportTerminator = true;
      _submitLine();
      _clearLineFlags();
    }

    _lineIndex += newlineCount;
  }

  void _processDefault(Node node, Set<Object?> serviceCommentsSources) {
    _processDefaultValue(node);

    if (node.children != null) {
      _processNodes(node.children!, serviceCommentsSources);
    }
  }

  /// Except: comment, keyword, string
  void _processDefaultValue(Node node) {
    final value = node.value;
    if (value == null) {
      return;
    }

    for (final code in value.runes) {
      switch (code) {
        case $space:
        case $tab:
        case $cr:
        case $lf:
          break;
        default:
          _foundNonWhitespace = true;
      }

      switch (code) {
        case $lf: // Newline
          _submitLine();
          _clearLineFlags();
          _lineIndex++;
          break;

        case $openParenthesis: // (
          startBlock(_lineIndex, FoldableBlockType.parentheses);
          break;

        case $closeParenthesis: // )
          endBlock(_lineIndex, FoldableBlockType.parentheses);
          break;

        case $openBracket: // [
          startBlock(_lineIndex, FoldableBlockType.brackets);
          break;

        case $closeBracket: // ]
          endBlock(_lineIndex, FoldableBlockType.brackets);
          break;

        case $openBrace: // {
          startBlock(_lineIndex, FoldableBlockType.braces);
          break;

        case $closeBrace: // }
          endBlock(_lineIndex, FoldableBlockType.braces);
          break;
      }
    }
  }

  void _submitLine() {
    if (_foundImport) {
      _endCommentSequence();
      _submitLineSemantics(LineSemantics.import);
      return;
    }

    if (_foundImportTerminator) {
      _endCommentSequence();
      endImportSequenceIfAny(_lineIndex);
      _submitLineSemantics(LineSemantics.singleLineCommentAndImportTerminator);
      return;
    }

    if (_foundPossibleImport) {
      _endCommentSequence();
      _submitLineSemantics(LineSemantics.possibleImport);
      return;
    }

    if (_foundSingleLineComment) {
      _submitLineSemantics(LineSemantics.singleLineComment);
      return;
    }

    if (_foundNonWhitespace) {
      _endCommentSequence();
      _submitLineSemantics(LineSemantics.singleLineCommentTerminator);
      return;
    }

    _submitLineSemantics(LineSemantics.blank);
  }

  void _clearLineFlags() {
    _foundImport = false;
    _foundPossibleImport = false;
    _foundImportTerminator = false;
    _foundSingleLineComment = false;
    _foundNonWhitespace = false;
  }

  void _endCommentSequence() => endCommentSequenceIfAny(_lineIndex);

  void _submitLineSemantics(LineSemantics semantics) {
    submitLine(_lineIndex, semantics);
  }
}
