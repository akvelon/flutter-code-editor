import 'package:flutter_code_editor/src/highlight/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/dart.dart';

const examples = {
  //
  'Empty': '',

  'Single line comment': '''
public class MyClass {
  public void main() { //comment
  }
}''',

  'Readonly comment': '''
public class MyClass {
  public void main() { // readonly
  }
}''',

  'Named sections': '''
class MyClass {
  void readOnlyMethod() {// [START section1]
  }// [END section1]
  // [START section2]
  void method() {
  }// [END section2]
}''',

  'Invalid code (Folded)': '''
class MyClass {
  void readOnlyMethod() {

  void method() {
}''',
};

void main() {
  group('Highlight split lines test.', () {
    examples.forEach((name, text) {
      test(name, () {
        Result? highlighted;

        final mode = dart;
        highlight.registerLanguage('language', mode);

        highlighted = highlight.parse(text, language: 'language');

        expect(
          highlighted.splitLines().nodes!.any((node) => node.hasSeveralLines()),
          false,
        );
      });
    });
  });
}

extension on Node {
  bool hasSeveralLines() {
    if (value == null) {
      return children?.any((child) => child.hasSeveralLines()) ?? false;
    }

    return value!.split('\n').where((e) => e.isNotEmpty).length > 1;
  }
}
