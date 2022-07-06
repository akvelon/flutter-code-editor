import '../../constants/constants.dart';
import '../../language_syntax/brackets_counting.dart';
import '../../language_syntax/golang_syntax.dart';
import '../../language_syntax/java_dart_syntax.dart';
import '../../language_syntax/python_syntax.dart';
import '../../language_syntax/scala_syntax.dart';

Map<int, String> getErrorsMap(String text, String language) {
  Map<int, String> errors = {};
  errors.addAll(countingBrackets(text));

  switch (language) {
    case java:
    case dart:
      errors.addAll(findJavaDartErrors(text));
      break;
    case go:
      errors.addAll(findGolangErrors(text));
      break;
    case python:
      errors.addAll(findPythonErrorTabs(text));
      break;
    case scala:
      errors.addAll(findScalaErrors(text));
      break;
  }

  return errors;
}
