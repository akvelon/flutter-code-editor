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
  });

  final CodeController codeController;
  final LineNumberStyle style;

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
      for (int i = 1; i <= code.lines.length; i++)
        TableRow(
          children: [
            Text(
              '$i',
              style: style.textStyle,
              textAlign: style.textAlign,
            ),
            const SizedBox(),
            const SizedBox(),
          ],
        ),
    ];

    for (final issue in code.issues) {
      final lineIndex = _lineIndexToTableRowIndex(issue.line);
      tableRows[lineIndex].children![_issueColumn] = const GutterErrorWidget();
    }

    for (final block in code.foldableBlocks) {
      final lineIndex = _lineIndexToTableRowIndex(block.firstLine);
      final isFolded = code.foldedBlocks.contains(block);

      tableRows[lineIndex].children![_foldingColumn] = FoldToggle(
        color: style.textStyle?.color,
        isFolded: isFolded,
        onTap: isFolded
            ? () => codeController.unfoldAt(block.firstLine)
            : () => codeController.foldAt(block.firstLine),
      );
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

  int _lineIndexToTableRowIndex(int line) {
    // TODO(alexeyinkin): Adjust for hidden lines if any, https://github.com/akvelon/flutter-code-editor/issues/58
    return line;
  }
}
