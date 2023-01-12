import 'package:meta/meta.dart';

import 'abstract.dart';
import 'line_semantics.dart';

/// A parser that iterates textual content to find foldable blocks.
abstract class TextFoldableBlockParser extends AbstractFoldableBlockParser {
  int _lineIndex = 0;

  int get lineIndex => _lineIndex;

  @protected
  void addToLineIndex(int n) => _lineIndex += n;

  /// If in the current line we found any keyword with import semantics.
  bool _foundImport = false;

  @protected
  void setFoundImport() => _foundImport = true;

  bool get foundImport => _foundImport;

  /// If in the current line we found any keyword that may or may not
  /// have import semantics depending on the context.
  bool _foundPossibleImport = false;

  @protected
  void setFoundPossibleImport() => _foundPossibleImport = true;

  /// If in the current line we found anything that terminates
  /// an import sequence.
  bool _foundImportTerminator = false;

  @protected
  void setFoundImportTerminator() => _foundImportTerminator = true;

  /// Import terminator is
  /// Any line that has first non-whitespace character to be:
  /// - not a sequence of a single line comment
  /// - not a sequence of start of a multiline comment that terminates within the line
  bool get foundImportTerminator => _foundImportTerminator;

  /// If in the current line we found a non-service single-line comment.
  bool _foundSingleLineComment = false;

  bool get foundSingleLineComment => _foundSingleLineComment;

  @protected
  void setFoundSingleLineComment() => _foundSingleLineComment = true;

  /// If in the current line we found a non-whitespace character that is
  /// not a comment.
  bool _foundNonWhitespace = false;

  bool get foundNonWhitespace => _foundNonWhitespace;

  @protected
  void setFoundNonWhitespace() => _foundNonWhitespace = true;

  @protected
  void submitCurrentLine() {
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

  @protected
  void clearLineFlags() {
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
