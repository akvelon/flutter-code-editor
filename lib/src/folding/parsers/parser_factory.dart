import 'package:highlight/highlight.dart';
import 'package:highlight/languages/python.dart';

import '../../../flutter_code_editor.dart';
import 'abstract.dart';
import 'python.dart';

class FoldableBlockParserFactory {
  static AbstractFoldableBlockParser provideParser(Mode mode) {
    if (mode == python) {
      return PythonFoldableBlockParser();
    }
    return HighlightFoldableBlockParser();
  }
}
