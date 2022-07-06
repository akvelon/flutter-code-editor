import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/scala.dart';

final builtinLanguages = {
  'go': go,
  'java': java,
  'python': python,
  'scala': scala,
  'dart': dart,
};
final allLanguages = {...builtinLanguages};
