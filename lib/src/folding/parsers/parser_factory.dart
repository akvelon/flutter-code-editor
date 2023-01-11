import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';

import 'abstract.dart';
import 'highlight.dart';
import 'java.dart';
import 'python.dart';

class FoldableBlockParserFactory {
  static AbstractFoldableBlockParser provideParser(Mode mode) {
    if (mode == python) {
      return PythonFoldableBlockParser();
    }
    if (mode == java) {
      return JavaFoldableBlockParser();
    }
    return HighlightFoldableBlockParser();
  }
}
