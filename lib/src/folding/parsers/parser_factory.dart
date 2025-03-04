import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/yaml.dart';

import 'abstract.dart';
import 'highlight.dart';
import 'indent.dart';
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

    if (mode == yaml) {
      return IndentFoldableBlockParser();
    }

    return HighlightFoldableBlockParser();
  }
}
