import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/scala.dart';

import '../../common/snippets.dart';

final builtinLanguages = {
  'go': go,
  'java': java,
  'python': python,
  'scala': scala,
  'dart': dart,
};

final codeControllers = {
  'go': CodeController(
    language: go,
    namedSectionParser: const BracketsStartEndNamedSectionParser(),
    text: javaFactorialSnippet,
  ),
  'java': CodeController(
    language: java,
    namedSectionParser: const BracketsStartEndNamedSectionParser(),
    text: javaFactorialSnippet,
  ),
  'python': CodeController(
    language: python,
    namedSectionParser: const BracketsStartEndNamedSectionParser(),
    text: javaFactorialSnippet,
  ),
  'scala': CodeController(
    language: scala,
    namedSectionParser: const BracketsStartEndNamedSectionParser(),
    text: javaFactorialSnippet,
  ),
  'dart': CodeController(
    language: dart,
    namedSectionParser: const BracketsStartEndNamedSectionParser(),
    text: javaFactorialSnippet,
  ),
};

const languageList = <String>[
  'java',
  'go',
  'python',
  'scala',
  'dart',
];

const themeList = <String>[
  'monokai-sublime',
  'a11y-dark',
  'an-old-hope',
  'vs2015',
  'vs',
  'atom-one-dark',
];
