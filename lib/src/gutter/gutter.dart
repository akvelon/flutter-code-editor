import 'package:flutter/material.dart';

import '../code_field/code_controller.dart';
import 'error.dart';
import 'fold_toggle.dart';
import 'gutter_style.dart';

const _issueColumnWidth = 16.0;
const _foldingColumnWidth = 16.0;

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
    //     [
    //   for (final i in code.hiddenLineRanges.visibleLineNumbers)
    //     const TableRow(
    //       children: [
    //         // Text(
    //         //   '${i + 1}',
    //         //   style: style.textStyle,
    //         //   textAlign: style.textAlign,
    //         // ),
    //         SizedBox(),
    //         SizedBox(),
    //         SizedBox(),
    //       ],
    //     ),
    // ];

    _fillLineNumbers(tableRows, style.showLineNumbers);

    if (style.showErrors) {
      _fillIssues(tableRows);
    }
    if (style.showFoldingHandles) {
      _fillFoldToggles(tableRows);
    }

    return Container(
      padding: EdgeInsets.only(top: 12, bottom: 12, right: style.margin),
      width: style.width,
      child: Table(
        columnWidths: const {
          _lineNumberColumn: FlexColumnWidth(),
          _issueColumn: FixedColumnWidth(_issueColumnWidth),
          _foldingColumn: FixedColumnWidth(_foldingColumnWidth),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRows,
      ),
    );
  }

  void _fillLineNumbers(List<TableRow> tableRows, bool showLineNumbers) {
    final code = codeController.code;

    for (final i in code.hiddenLineRanges.visibleLineNumbers) {
      final lineIndex = _lineIndexToTableRowIndex(i);

      if (lineIndex == null) {
        continue;
      }

      tableRows[lineIndex].children![_lineNumberColumn] = Text(
        showLineNumbers ? '${i + 1}' : ' ',
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
