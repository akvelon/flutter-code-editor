import 'package:flutter/widgets.dart';
import 'package:highlight/highlight.dart';

import '../wip/TooltipTextSpan.dart';
import '../wip/getErrorsMap.dart';

class LineNumberController extends TextEditingController {
  final TextSpan Function(int, TextStyle?)? lineNumberBuilder;
  Mode? language;
  String codeFieldText;

  LineNumberController(
    this.lineNumberBuilder,
    this.language,
    this.codeFieldText,
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    final children = <InlineSpan>[];
    final list = text.split("\n");
    Map<int, String> errors = getErrorsMap(codeFieldText, language);

    for (int k = 0; k < list.length; k++) {
      final el = list[k];
      final number = int.parse(el);
      var textSpan = TextSpan(text: el, style: style);

      if (lineNumberBuilder != null) {
        textSpan = lineNumberBuilder!(number, style);
      }

      if (errors.containsKey(number)) {
        children.add(
          TooltipTextSpan(
            message: errors[number]!,
            number: el,
            style: style,
          ),
        );
        continue;
      }

      children.add(textSpan);
      if (k < list.length - 1) {
        children.add(TextSpan(text: "\n"));
      }
    }
    children.add(TextSpan(text: "\n "));

    return TextSpan(children: children, style: style);
  }
}
