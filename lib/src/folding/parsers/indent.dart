import 'package:highlight/highlight_core.dart';

import '../../code/code_line.dart';
import '../foldable_block.dart';
import '../foldable_block_type.dart';
import 'abstract.dart';

/// A parser for foldable blocks from lines indentation.
class IndentFoldableBlockParser extends AbstractFoldableBlockParser {
  Map<int, int> _openBlocksLinesByIndent = <int, int>{};
  List<int?> _lineIndents = [];

  @override
  void parse({
    Result? highlighted,
    Set<Object?> serviceCommentsSources = const {},
    required List<CodeLine> lines,
  }) {
    _parse(lines);
    finalize();
  }

  @override
  void finalize() {
    super.finalize();
    _openBlocksLinesByIndent = {};
    _lineIndents = [];
  }

  void _parse(List<CodeLine> lines) {
    _lineIndents = _calculateLineIndents(lines);
    final significantIndentIndexes =
        _SignificantIndentIndexes.fromLineIndents(_lineIndents);

    if (!significantIndentIndexes.areExist) {
      return;
    }

    _createBlocks(significantIndentIndexes);
    _closeAllOpenedBlocksAt(significantIndentIndexes.last!);
  }

  List<int?> _calculateLineIndents(List<CodeLine> lines) {
    final result = List<int?>.filled(lines.length, 0);
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      result[i] = line.indent == line.text.length ? null : line.indent;
    }
    return result;
  }

  void _createBlocks(_SignificantIndentIndexes significantIndentIndexes) {
    int lastExistingIndent = _lineIndents[significantIndentIndexes.first!]!;
    int lastExistingIndentIndex = significantIndentIndexes.first!;

    for (int i = significantIndentIndexes.second!;
        i < _lineIndents.length;
        i++) {
      final currentLineIndent = _lineIndents[i];

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

  void _closeBlocks(int i, int nextNonEmptyIndent) {
    _openBlocksLinesByIndent.forEachInvertedWhile(
      (indentsCount, startLine) {
        _closeBlock(startLine, i);
      },
      executeWhile: (indentsCount, _) => indentsCount >= nextNonEmptyIndent,
    );
    _openBlocksLinesByIndent.removeWhere(
      (key, value) => key >= nextNonEmptyIndent,
    );
  }

  void _closeBlock(int startLine, int endLine) {
    blocks.add(
      FoldableBlock(
        type: FoldableBlockType.indent,
        startLine: startLine,
        endLine: endLine,
      ),
    );
  }
}

class _SignificantIndentIndexes {
  late final int? first;
  late final int? second;
  late final int? last;
  late final bool areExist;

  _SignificantIndentIndexes.fromLineIndents(List<int?> lineIndents) {
    first = _getNextSignificantIndentIndex(lineIndents);
    
    if (first == null) {
      second = null;
      last = null;
      areExist = false;
      return;
    }
    
    second = _getNextSignificantIndentIndex(
      lineIndents,
      startIndex: first! + 1,
    );
    last = _getLastExistingIndentIndex(lineIndents);
    areExist = first != null && second != null && last != null;
  }

  int? _getNextSignificantIndentIndex(
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

  int? _getLastExistingIndentIndex(List<int?> indents) {
    for (int i = indents.length - 1; i >= 0; i--) {
      if (!_isSeparatorLine(indents[i])) {
        return i;
      }
    }
    return null;
  }

  bool _isSeparatorLine(int? indent) => indent == null;
}

extension _MyMap<K, V> on Map<K, V> {
  /// Iterates over the map in reverse order while [executeWhile] returns true.
  void forEachInvertedWhile(
    void Function(K key, V value) f, {
    required bool Function(K key, V value) executeWhile,
  }) {
    final keys = this.keys.toList();
    for (int i = keys.length - 1; i >= 0; i--) {
      if (!executeWhile(keys[i], this[keys[i]]!)) {
        break;
      }
      final key = keys[i];
      final value = this[key];
      f(key, value!);
    }
  }
}
