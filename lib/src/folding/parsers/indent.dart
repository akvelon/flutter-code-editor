import 'package:highlight/highlight_core.dart';

import '../../code/code_line.dart';
import '../../code/code_lines.dart';
import '../../code/iterable.dart';
import '../foldable_block.dart';
import '../foldable_block_type.dart';
import 'abstract.dart';

/// A parser for foldable blocks from lines indentation.
class IndentFoldableBlockParser extends AbstractFoldableBlockParser {
  final _openBlocksLinesByIndent = <int, int>{};
  List<int?> _linesIndents = [];

  @override
  void parse({
    Result? highlighted,
    Set<Object?> serviceCommentsSources = const {},
    required CodeLines lines,
  }) {
    _parse(lines.lines);
    finalize();
  }

  void _parse(List<CodeLine> lines) {
    _linesIndents = _calculateLinesIndents(lines);
    final significantIndentIndexes =
        _SignificantIndentIndexes.fromLineIndents(_linesIndents);

    if (significantIndentIndexes == null) {
      return;
    }

    _createBlocks(significantIndentIndexes);
    _closeAllOpenedBlocksAt(significantIndentIndexes.last);

    _openBlocksLinesByIndent.clear();
    _linesIndents = [];
  }

  List<int?> _calculateLinesIndents(List<CodeLine> lines) {
    final result = List<int?>.filled(lines.length, 0);
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isSeparatorLine = line.indent == line.text.length;
      result[i] = isSeparatorLine ? null : line.indent;
    }
    return result;
  }

  void _createBlocks(_SignificantIndentIndexes significantIndentIndexes) {
    int lastExistingIndent = _linesIndents[significantIndentIndexes.first]!;
    int lastExistingIndentIndex = significantIndentIndexes.first;

    for (int i = significantIndentIndexes.second;
        i < _linesIndents.length;
        i++) {
      final currentLineIndent = _linesIndents[i];

      if (_isSeparatorLine(currentLineIndent)) {
        continue;
      }

      if (currentLineIndent! > lastExistingIndent) {
        _openBlock(lastExistingIndent, lastExistingIndentIndex);
      } else {
        _closeBlocks(lastExistingIndentIndex, currentLineIndent);
      }
      lastExistingIndentIndex = i;
      lastExistingIndent = currentLineIndent;
    }
  }

  void _closeAllOpenedBlocksAt(int index) {
    _openBlocksLinesByIndent.forEach((indentsCount, startLine) {
      _closeBlock(startLine, index);
    });
  }

  bool _isSeparatorLine(int? indent) => indent == null;

  void _openBlock(int indent, int lineIndex) {
    _openBlocksLinesByIndent[indent] = lineIndex;
  }

  void _closeBlocks(int index, int nextNonEmptyIndent) {
    for (final indent in _openBlocksLinesByIndent.keys.reversed) {
      final indentsCount = indent;

      if (indentsCount < nextNonEmptyIndent) {
        break;
      }

      final startLine = _openBlocksLinesByIndent[indentsCount];
      _closeBlock(startLine!, index);
    }

    _openBlocksLinesByIndent.removeWhere(
      (key, value) => key >= nextNonEmptyIndent,
    );
  }

  void _closeBlock(int startLine, int endLine) {
    blocks.add(
      FoldableBlock(
        type: FoldableBlockType.indent,
        firstLine: startLine,
        lastLine: endLine,
      ),
    );
  }
}

class _SignificantIndentIndexes {
  final int first;
  final int second;
  final int last;

  _SignificantIndentIndexes(this.first, this.second, this.last);

  static _SignificantIndentIndexes? fromLineIndents(List<int?> linesIndents) {
    final first = _getNextSignificantIndentIndex(linesIndents);
    if (first == null) {
      return null;
    }

    final second = _getNextSignificantIndentIndex(
      linesIndents,
      startIndex: first + 1,
    );
    if (second == null) {
      return null;
    }

    final last = _getLastSignificantIndentIndex(linesIndents);
    if (last == null) {
      return null;
    }

    return _SignificantIndentIndexes(first, second, last);
  }

  static int? _getNextSignificantIndentIndex(
    List<int?> indents, {
    int startIndex = 0,
  }) {
    for (int i = startIndex; i < indents.length; i++) {
      if (!_isSeparatorLine(indents[i])) {
        return i;
      }
    }
    return null;
  }

  static int? _getLastSignificantIndentIndex(List<int?> indents) {
    for (int i = indents.length - 1; i >= 0; i--) {
      if (!_isSeparatorLine(indents[i])) {
        return i;
      }
    }
    return null;
  }

  static bool _isSeparatorLine(int? indent) => indent == null;
}
