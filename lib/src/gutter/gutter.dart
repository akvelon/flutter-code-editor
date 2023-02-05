import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../code_field/code_controller.dart';
import '../line_numbers/gutter_style.dart';
import 'error.dart';
import 'fold_toggle.dart';

class _GutterRowBuilder {
  final GutterStyle style;
  final int lineNumber;
  final bool isWrappedLine;

  Widget? errorWidget;
  Widget? foldingWidget;

  _GutterRowBuilder({
    required this.style,
    required this.lineNumber,
    this.isWrappedLine = false,
  });

  TableRow build(BuildContext context) {
    final text =
        (isWrappedLine || !style.showLineNumbers) ? '' : '${lineNumber + 1}';
    return TableRow(
      children: [
        Text(
          text,
          style: style.textStyle,
          textAlign: style.textAlign,
        ),
        if (style.showErrors && errorWidget != null)
          errorWidget!
        else
          const SizedBox(),
        if (style.showFoldingHandles && foldingWidget != null)
          foldingWidget!
        else
          const SizedBox(),
      ],
    );
  }
}

class GutterWidget extends StatelessWidget {
  const GutterWidget({
    required this.codeController,
    required this.style,
    required this.linesInParagraps,
  });

  final CodeController codeController;
  final GutterStyle style;
  final List<int> linesInParagraps;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: codeController,
      builder: _buildOnChange,
    );
  }

  Widget _buildOnChange(BuildContext context, Widget? child) {
    final code = codeController.code;

    // build rows
    final List<_GutterRowBuilder> tableRowBuilders = [];
    final visibleLineNumbers =
        code.hiddenLineRanges.visibleLineNumbers.toList();
    for (var i = 0; i < visibleLineNumbers.length; ++i) {
      final lineNumber = visibleLineNumbers[i];
      tableRowBuilders.add(
        _GutterRowBuilder(
          style: style,
          lineNumber: lineNumber,
        ),
      );
      // line wrap cache and folding cache may temporarily be out of sync while
      // rebuilding layouts, as the line wrap cache is built while creating the
      // layout and the folding cache when the text changes
      if (i < linesInParagraps.length) {
        for (var l = 1; l < linesInParagraps[i]; ++l) {
          // wrapped lines
          tableRowBuilders.add(
            _GutterRowBuilder(
              style: style,
              lineNumber: lineNumber,
              isWrappedLine: true,
            ),
          );
        }
      }
    }

    if (style.showErrors) {
      _fillIssues(tableRowBuilders);
    }
    if (style.showFoldingHandles) {
      _fillFoldToggles(tableRowBuilders);
    }
    return Container(
      padding: EdgeInsets.only(top: 12, bottom: 12, right: style.margin),
      width: style.showLineNumbers ? style.totalWidth() : null,
      child: Table(
        columnWidths: {
          0: const FlexColumnWidth(),
          1: FixedColumnWidth(style.errorColumnWidth()),
          2: FixedColumnWidth(style.foldingColumnWidth()),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRowBuilders.map((e) => e.build(context)).toList(),
      ),
    );
  }

  void _fillIssues(List<_GutterRowBuilder> tableRowBuilders) {
    for (final issue in codeController.issues) {
      final row = tableRowBuilders.firstWhereOrNull(
        (element) => element.lineNumber == issue.line && !element.isWrappedLine,
      );
      if (row != null) {
        row.errorWidget = GutterErrorWidget(
          issue,
          style.errorPopupTextStyle ??
              (throw Exception('Error popup style should never be null')),
        );
      }
    }
  }

  void _fillFoldToggles(List<_GutterRowBuilder> tableRowBuilders) {
    final code = codeController.code;

    for (final block in code.foldableBlocks) {
      final lineIndex = block.firstLine;
      final row = tableRowBuilders.firstWhereOrNull(
        (element) => element.lineNumber == lineIndex && !element.isWrappedLine,
      );
      if (row != null) {
        final isFolded = code.foldedBlocks.contains(block);
        row.foldingWidget = FoldToggle(
          color: style.textStyle?.color,
          isFolded: isFolded,
          onTap: isFolded
              ? () => codeController.unfoldAt(block.firstLine)
              : () => codeController.foldAt(block.firstLine),
        );
      }
    }
  }
}
