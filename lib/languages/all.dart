import 'go.dart';
import 'java.dart';
import 'python.dart';
import 'scala.dart';
import 'dart.dart';

final builtinLanguages = {
  'go': go,
  'java': java,
  'python': python,
  'scala': scala,
  'dart': dart,
};
final allLanguages = {...builtinLanguages};
