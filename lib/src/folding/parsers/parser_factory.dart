import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/python.dart';

import 'abstract.dart';
import 'highlight.dart';
import 'python.dart';

class FoldableBlockParserFactory {
  static AbstractFoldableBlockParser provideParser(Mode mode) {
    if (mode == python) {
      return PythonFoldableBlockParser();
    }
    return HighlightFoldableBlockParser();
  }
}
