import 'package:flutter/material.dart';

import '../code_field/code_controller.dart';
import '../line_numbers/line_number_style.dart';
import 'error.dart';
import 'fold_toggle.dart';

const _issueColumnWidth = 16.0;
const _foldingColumnWidth = 16.0;

const _lineNumberColumn = 0;
const _issueColumn = 1;
const _foldingColumn = 2;

class GutterWidget extends StatelessWidget {
  const GutterWidget({
    required this.codeController,
    required this.style,
    required this.showErrors,
    required this.showNumbers,
  });

  final CodeController codeController;
  final LineNumberStyle style;
  final bool showErrors;
  final bool showNumbers;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: codeController,
      builder: _buildOnChange,
    );
  }

  Widget _buildOnChange(BuildContext context, Widget? child) {
    final code = codeController.code;

    final tableRows = [
      for (final i in code.hiddenLineRanges.visibleLineNumbers)
        TableRow(
          children: [
            Text(
              showNumbers ? '${i + 1}' : '',
              style: style.textStyle,
              textAlign: style.textAlign,
            ),
            const SizedBox(),
            const SizedBox(),
          ],
        ),
    ];
    if (showErrors) {
      _fillIssues(tableRows);
    }
    _fillFoldToggles(tableRows);

    return Container(
      padding: EdgeInsets.only(top: 12, bottom: 12, right: style.margin),
      width: style.width,
      child: Table(
        columnWidths: {
          _lineNumberColumn:
              showNumbers ? const FlexColumnWidth() : const FixedColumnWidth(0),
          _issueColumn: FixedColumnWidth(showErrors ? _issueColumnWidth : 0),
          _foldingColumn: const FixedColumnWidth(_foldingColumnWidth),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRows,
      ),
    );
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
