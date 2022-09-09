import 'package:flutter/material.dart';

import '../code/code.dart';
import '../line_numbers/line_number_style.dart';

const _foldingColumnWidth = 16.0;

const _lineNumberColumn = 0;
const _foldingColumn = 1;

class GutterWidget extends StatelessWidget {
  const GutterWidget({
    required this.code,
    required this.style,
  });

  final Code code;
  final LineNumberStyle style;

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
    ];

    for (final issue in code.issues) {
      tableRows[issue.line].children![_foldingColumn] = Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(top: 12, bottom: 12, right: style.margin),
      width: style.width,
      child: Table(
        columnWidths: const {
          _lineNumberColumn: FlexColumnWidth(),
          _foldingColumn: FixedColumnWidth(_foldingColumnWidth),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRows,
      ),
    );
  }
}
