// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables,
// reason: to enable mutation on the objects later on.

import 'package:flutter/material.dart';

import '../code_field/code_controller.dart';
import 'error.dart';
import 'fold_toggle.dart';
import 'gutter_style.dart';

const _issueColumnWidth = 16.0;
const _foldingColumnWidth = 16.0;

const _padding = 5.0;

const _lineNumberColumn = 0;
const _issueColumn = 1;
const _foldingColumn = 2;

class GutterWidget extends StatelessWidget {
  const GutterWidget({
    required this.codeController,
    required this.style,
  });

  final CodeController codeController;
  final GutterStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: codeController,
      builder: _buildOnChange,
    );
  }

  Widget _buildOnChange(BuildContext context, Widget? child) {
    final code = codeController.code;

    final tableRows = List.generate(
      code.hiddenLineRanges.visibleLineNumbers.length,
      (i) => TableRow(
        children: [
          SizedBox(),
          SizedBox(),
          SizedBox(),
        ],
      ),
    );

    _fillLineNumbers(tableRows);

    if (style.showErrors) {
      _fillIssues(tableRows);
    }
    if (style.showFoldingHandles) {
      _fillFoldToggles(tableRows);
    }

    final gutterWidth = style.width -
        (style.showErrors ? 0 : _issueColumnWidth) -
        (style.showFoldingHandles ? 0 : _foldingColumnWidth);

    final issueColumnWidth = style.showErrors ? _issueColumnWidth : _padding;
    final foldingColumnWidth =
        style.showFoldingHandles ? _foldingColumnWidth : _padding;

    return Container(
      padding: EdgeInsets.only(top: 12, bottom: 12, right: style.margin),
      width: style.showLineNumbers ? gutterWidth : null,
      child: Table(
        columnWidths: {
          _lineNumberColumn: const FlexColumnWidth(),
          _issueColumn: FixedColumnWidth(issueColumnWidth),
          _foldingColumn: FixedColumnWidth(foldingColumnWidth),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRows,
      ),
    );
  }

  void _fillLineNumbers(List<TableRow> tableRows) {
    final code = codeController.code;

    for (final i in code.hiddenLineRanges.visibleLineNumbers) {
      final lineIndex = _lineIndexToTableRowIndex(i);

      if (lineIndex == null) {
        continue;
      }

      tableRows[lineIndex].children![_lineNumberColumn] = Text(
        style.showLineNumbers ? '${i + 1}' : ' ',
        style: style.textStyle,
        textAlign: style.textAlign,
      );
    }
  }

  void _fillIssues(List<TableRow> tableRows) {
    final code = codeController.code;

    for (final issue in code.issues) {
      final lineIndex = _lineIndexToTableRowIndex(issue.line);
      if (lineIndex == null) {
        continue;
      }

      tableRows[lineIndex].children![_issueColumn] = const GutterErrorWidget();
    }
  }

  void _fillFoldToggles(List<TableRow> tableRows) {
    final code = codeController.code;

    for (final block in code.foldableBlocks) {
      final lineIndex = _lineIndexToTableRowIndex(block.firstLine);
      if (lineIndex == null) {
        continue;
      }

      final isFolded = code.foldedBlocks.contains(block);

      tableRows[lineIndex].children![_foldingColumn] = FoldToggle(
        color: style.textStyle?.color,
        isFolded: isFolded,
        onTap: isFolded
            ? () => codeController.unfoldAt(block.firstLine)
            : () => codeController.foldAt(block.firstLine),
      );
    }
  }

  int? _lineIndexToTableRowIndex(int line) {
    return codeController.code.hiddenLineRanges.cutLineIndexIfVisible(line);
  }
}
