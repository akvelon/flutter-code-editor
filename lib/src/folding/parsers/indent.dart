import 'package:highlight/highlight_core.dart';

import '../../code/code_line.dart';
import '../foldable_block.dart';
import '../foldable_block_type.dart';
import 'abstract.dart';

/// A parser for foldable blocks from lines indentation
class IndentFoldableBlockParser extends AbstractFoldableBlockParser {
  final _openBlocksLinesByIndent = <int, int>{};

  @override
  void parse({
    Result? highlighted,
    Set<Object?> serviceCommentsSources = const {},
    required List<CodeLine> lines,
  }) {
    _addIndentBlocks(lines);
    finalize();
  }

  void _addIndentBlocks(List<CodeLine> lines) {
    final lineIndents = _calculateLineIndents(lines);

    int lastNonEmptyLine = lineIndents.length - 1;

    for (int i = 0; i < lineIndents.length - 1; i++) {
      final currentLineIndent = lineIndents[i];

      if (currentLineIndent == null) {
        continue;
      }

      final nextNonEmptyIndent = lineIndents.skip(i + 1).firstWhere(
            (element) => element != null,
            orElse: () => null,
          );

      if (nextNonEmptyIndent == null) {
        lastNonEmptyLine = i;
        break;
      } 
      
      if (nextNonEmptyIndent > currentLineIndent) {
        _openBlock(currentLineIndent, i);
      } else {
        _closeBlocks(i, nextNonEmptyIndent);
      }
    }
    _openBlocksLinesByIndent.forEach((indentsCount, startLine) {
      _closeBlock(startLine, lastNonEmptyLine);
    });
  }

  void _openBlock(int indent, int lineIndex) {
    _openBlocksLinesByIndent[indent] = lineIndex;
  }

  void _closeBlocks(int i, int nextNonEmptyIndent) {
    _openBlocksLinesByIndent.forEachInvertedWhile((indentsCount, startLine) {
      _closeBlock(startLine, i);
    }, executeWhile: (indentsCount, _) => indentsCount >= nextNonEmptyIndent);
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

  List<int?> _calculateLineIndents(List<CodeLine> lines) {
    final result = List<int?>.filled(lines.length, 0);
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      result[i] = line.indent == line.text.length ? null : line.indent;
    }
    return result;
  }
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
