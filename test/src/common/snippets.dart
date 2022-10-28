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
