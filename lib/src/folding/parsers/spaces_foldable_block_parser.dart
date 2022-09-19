import 'dart:collection';

import 'package:charcode/ascii.dart';
import '../foldable_block.dart';
import '../foldable_block_type.dart';

import 'abstract.dart';

///A parser for foldable blocks from spaces count at start of each line.
class SpacesFoldableBlockParser extends AbstractFoldableBlockParser {
  static const _kSeparatorLine = -1;

  void parse(String text) {
    _addWhitespacesBlocks(text);
    finalize();
  }

  void _addWhitespacesBlocks(String text) {
    final spacesCountBeforeLines = _countWhitespacesInStartOfEachLine(text);

    final openBlocksBySpacesCount = HashMap<int, List<FoldableBlock>>();
    final resultBlocks = List<FoldableBlock>.empty(growable: true);

    int lastValuableLine = spacesCountBeforeLines.length - 1;

    for (int i = 0; i < spacesCountBeforeLines.length - 1; i++) {
      final currentSpacesCount = spacesCountBeforeLines[i];

      if (currentSpacesCount == _kSeparatorLine) {
        continue;
      }

      final nextExistingSpacesCount =
          spacesCountBeforeLines.skip(i + 1).firstWhere(
                (element) => element != _kSeparatorLine,
                orElse: () => _kSeparatorLine,
              );

      if (nextExistingSpacesCount == _kSeparatorLine) {
        lastValuableLine = i;
        break;
      }

      if (nextExistingSpacesCount > currentSpacesCount) {
        if (openBlocksBySpacesCount[currentSpacesCount] == null) {
          openBlocksBySpacesCount[currentSpacesCount] =
              List.empty(growable: true);
        }

        openBlocksBySpacesCount[currentSpacesCount]!.add(
          FoldableBlock(
            startLine: i,
            endLine: -1,
            type: FoldableBlockType.spaces,
          ),
        );
      }

      if (nextExistingSpacesCount < currentSpacesCount) {
        openBlocksBySpacesCount.forEach((spacesCount, openedBlocks) {
          if (spacesCount >= nextExistingSpacesCount) {
            resultBlocks.addAll(
              openedBlocks.map(
                (e) => FoldableBlock(
                  startLine: e.startLine,
                  endLine: i,
                  type: FoldableBlockType.spaces,
                ),
              ),
            );
          }
        });
        openBlocksBySpacesCount.removeWhere(
          (key, value) => key >= nextExistingSpacesCount,
        );
      }
    }
    openBlocksBySpacesCount.forEach((spacesCount, openedBlocks) {
      resultBlocks.addAll(
        openedBlocks.map(
          (e) => FoldableBlock(
            startLine: e.startLine,
            endLine: lastValuableLine,
            type: FoldableBlockType.spaces,
          ),
        ),
      );
    });
    blocks.addAll(resultBlocks);
  }

  List<int> _countWhitespacesInStartOfEachLine(String text) {
    final lines = text.split('\n');
    final result = List.filled(lines.length, 0);
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      var count = 0;
      for (final char in line.runes) {
        if (char == $space) {
          count++;
        } else {
          break;
        }
      }
      result[i] = count == line.length ? _kSeparatorLine : count;
    }
    return result;
  }
}
