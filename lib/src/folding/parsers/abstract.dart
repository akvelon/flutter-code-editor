import 'package:collection/collection.dart';
import 'package:highlight/highlight_core.dart';
import 'package:meta/meta.dart';

import '../../code/code_lines.dart';
import '../foldable_block.dart';
import '../foldable_block_type.dart';
import '../invalid_foldable_block.dart';
import 'line_semantics.dart';

/// A base class for parsers that go through some representation
/// of code to parse blocks from it.
///
/// This object accumulates data in its fields as the parsing progresses.
abstract class AbstractFoldableBlockParser {
  /// Valid blocks by the end of the parsing.
  final blocks = <FoldableBlock>[];

  /// Invalid blocks by the end of the parsing.
  /// These can be used for error highlighting.
  final invalidBlocks = <InvalidFoldableBlock>[];

  /// The stack of blocks open at any moment as the parsing progresses.
  final _startedBlocks = <_StartedFoldableBlock>[];

  /// A semantics for each line.
  /// Used when grouping sequential imports and single line comments.
  final _linesWithSemantics = <_LineWithSemantics>[];

  void parse({
    required Result highlighted,
    required Set<Object?> serviceCommentsSources,
    required CodeLines lines,
  });

  /// Records that a block has started at [line].
  @protected
  void startBlock(int line, FoldableBlockType type) {
    _startedBlocks.add(
      _StartedFoldableBlock(line: line, type: type),
    );
  }

  /// Checks if the block has started and it is its turn to terminate at [line].
  /// Creates a [FoldableBlock] if alright and [InvalidFoldableBlock] otherwise.
  @protected
  void endBlock(int line, FoldableBlockType type) {
    final started = _startedBlocks.lastOrNull;

    if (started == null || started.type != type) {
      invalidBlocks.add(
        InvalidFoldableBlock(
          endLine: line,
          type: type,
        ),
      );
      return;
    }

    if (line != started.line) {
      blocks.add(
        FoldableBlock(
          firstLine: started.line,
          lastLine: line,
          type: type,
        ),
      );
    }

    _startedBlocks.removeLast();
  }

  /// Records the semantic for the given line.
  /// Must be called in ascending order for lines.
  @protected
  void submitLine(int index, LineSemantics semantics) {
    _linesWithSemantics.add(
      _LineWithSemantics(
        index: index,
        semantics: semantics,
      ),
    );
  }

  /// Terminates a sequence of import lines if one was started above.
  ///
  /// An import block is a block that:
  /// - Starts with import or possibleImport line.
  /// - Ends with import or possibleImport line.
  /// - Has at least one import line.
  /// - Only can have import, possibleImport, blank, singleLineComment lines.
  ///
  /// [lineIndex] is the current line that does not have import statements.
  /// So the latest possible import line is [lineIndex] - 1.
  @protected
  void endImportSequenceIfAny(int lineIndex) {
    // We can have many possibleImport lines that add to the block range,
    // but at least one true import line is required for the block.
    bool importFound = false;
    int? first; // Min line index of the block.
    int? last; // Max line index of the block.

    // Called if the block upper bound is found. Adds if it is a valid block.
    void addIfFound() {
      if (first == null || !importFound || last == first) {
        return;
      }

      blocks.add(
        FoldableBlock(
          firstLine: first,
          lastLine: last!,
          type: FoldableBlockType.imports,
        ),
      );
    }

    int i = lineIndex;

    for (final line in _linesWithSemantics.reversed) {
      if (line.index != --i) {
        // A gap in submitted lines. This happens with uninterpreted blocks.
        // They should break the block.
        addIfFound();
        return;
      }

      if (line.semantics == LineSemantics.import) {
        importFound = true;
      }

      switch (line.semantics) {
        case LineSemantics.import:
        case LineSemantics.possibleImport:
          first = line.index;
          last ??= line.index;
          break;

        case LineSemantics.singleLineCommentAndImportTerminator:
          addIfFound();
          return;

        case LineSemantics.blank:
        case LineSemantics.singleLineComment:
        case LineSemantics.singleLineCommentTerminator:
          break; // no op
      }
    }

    addIfFound();
  }

  /// Terminates a single-line comment sequence if one was started above.
  ///
  /// A single-line comment block is a block that:
  /// - Starts and ends with lines with [LineSemantics.singleLineComment].
  /// - Can only contain [LineSemantics.singleLineComment]
  ///   and [LineSemantics.blank] inside.
  ///
  /// [lineIndex] is the current line that is not
  /// [LineSemantics.singleLineComment].
  /// So the latest possible block line is [lineIndex] - 1.
  @protected
  void endCommentSequenceIfAny(int lineIndex) {
    int? first; // Min line index of the block.
    int? last; // Max line index of the block.

    // Called if the block upper bound is found. Adds if it is a valid block.
    void addIfFound() {
      if (first == null || last == first) {
        return;
      }

      blocks.add(
        FoldableBlock(
          firstLine: first,
          lastLine: last!,
          type: FoldableBlockType.singleLineComment,
        ),
      );
    }

    int i = lineIndex;

    for (final line in _linesWithSemantics.reversed) {
      if (line.index != --i) {
        // A gap in submitted lines. This happens with uninterpreted blocks.
        // They should break the block.
        addIfFound();
        return;
      }

      switch (line.semantics) {
        case LineSemantics.singleLineComment:
          first = line.index;
          last ??= line.index;
          break;

        case LineSemantics.blank:
          break;

        default: // ignore: no_default_cases
          addIfFound();
          return;
      }
    }

    addIfFound();
  }

  /// Terminates all open blocks.
  /// Called when the parsing is otherwise finished.
  @protected
  void finalize() {
    final lastLinePlusOne = (_linesWithSemantics.lastOrNull?.index ?? 0) + 1;
    endCommentSequenceIfAny(lastLinePlusOne);
    endImportSequenceIfAny(lastLinePlusOne);

    for (final started in _startedBlocks) {
      invalidBlocks.add(
        InvalidFoldableBlock(
          startLine: started.line,
          type: started.type,
        ),
      );
    }
    _startedBlocks.clear();

    blocks.sortByStartLine();
    blocks.joinIntersecting();
    invalidBlocks.sortByStartOrEndLine();
  }
}

class _StartedFoldableBlock {
  final int line;
  final FoldableBlockType type;

  const _StartedFoldableBlock({
    required this.line,
    required this.type,
  });
}

class _LineWithSemantics {
  final int index;
  final LineSemantics semantics;

  const _LineWithSemantics({
    required this.index,
    required this.semantics,
  });
}
