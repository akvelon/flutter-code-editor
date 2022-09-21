import 'dart:collection';

import 'package:highlight/highlight.dart';

import '../../code/code_line.dart';
import '../foldable_block.dart';
import '../foldable_block_type.dart';
import 'abstract.dart';

/// A parser for foldable blocks from lines indentation
class IndentFoldableBlockParser extends AbstractFoldableBlockParser {
  static const _kSeparatorLine = -1;

  final openBlocksLinesByIndent = HashMap<int, List<int>>();

  @override
  void parse(
    Result highlighted,
    Set<Object?> serviceCommentsSources,
    List<CodeLine> lines,
  ) {
    _addWhitespacesBlocks(lines);
    finalize();
  }

  void _addWhitespacesBlocks(List<CodeLine> lines) {
    final lineIndents = _calculateLineIndents(lines);

    int lastValuableLine = lineIndents.length - 1;

    for (int i = 0; i < lineIndents.length - 1; i++) {
      final currentLineIndent = lineIndents[i];

      if (currentLineIndent == _kSeparatorLine) {
        continue;
      }

      final nextExistingIndent = lineIndents.skip(i + 1).firstWhere(
            (element) => element != _kSeparatorLine,
            orElse: () => _kSeparatorLine,
          );

      if (nextExistingIndent == _kSeparatorLine) {
        lastValuableLine = i;
        break;
      }

      if (nextExistingIndent > currentLineIndent) {
        _openBlock(currentLineIndent, i);
      }

      if (nextExistingIndent < currentLineIndent) {
        openBlocksLinesByIndent.forEach((spacesCount, openedBlocks) {
          if (spacesCount >= nextExistingIndent) {
            _closeBlocks(openedBlocks, i);
          }
        });
        openBlocksLinesByIndent.removeWhere(
          (key, value) => key >= nextExistingIndent,
        );
      }
    }
    openBlocksLinesByIndent.forEach((spacesCount, openedBlocks) {
      _closeBlocks(openedBlocks, lastValuableLine);
    });
  }

  void _openBlock(int indent, int lineIndex) {
    if (openBlocksLinesByIndent[indent] == null) {
      openBlocksLinesByIndent[indent] = List.empty(growable: true);
    }
    openBlocksLinesByIndent[indent]!.add(lineIndex);
  }

  void _closeBlocks(List<int> openedBlocks, int endLine) {
    blocks.addAll(
      openedBlocks.map(
        (lineIndex) => FoldableBlock(
          startLine: lineIndex,
          endLine: endLine,
          type: FoldableBlockType.indent,
        ),
      ),
    );
  }

  List<int> _calculateLineIndents(List<CodeLine> lines) {
    final result = List.filled(lines.length, 0);
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      result[i] =
          line.indent == line.text.length ? _kSeparatorLine : line.indent;
    }
    return result;
  }
}
