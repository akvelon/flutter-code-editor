import 'package:code_text_field/languages/main_mode.dart';

import 'dart.dart';
import 'go.dart';
import 'java.dart';
import 'python.dart';
import 'scala.dart';

final Map<String, MainMode> builtinLanguages = <String, MainMode>{
  'go': go,
  'java': java,
  'python': python,
  'scala': scala,
  'dart': dart,
};
final Map<String, MainMode> allLanguages = <String, MainMode>{...builtinLanguages};
