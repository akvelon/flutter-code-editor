import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart';

class MethodSnippet {
  static const full = '''
class MyClass {
  void method() {// [START section1]
  }// [END section1]
}
''';

  static const visible = '''
class MyClass {
  void method() {
  }
}
''';

  static const visibleFolded1 = '''
class MyClass {
  void method() {
}
''';
}

class TwoMethodsSnippet {
  static Mode get mode => java;

  static const full = '''
private class MyClass {
  void method1() {
    if (false) {// [START section1]
      return;
    }// [END section1]
  }

  void method2() {// [START section2]
    return;
  }// [END section2]
}
''';
}

class CommentImportSnippet {
  static const full = '''
// comment1
///comment2

package mypackage;
import java.util.Arrays;

{
}
''';

  static String get visible => full;
}
