import 'package:flutter_code_editor/src/highlight/node.dart';
import 'package:flutter_code_editor/src/highlight/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/dart.dart';

const examples = {
  //
  'Empty': _Example(text: '', expected: '{value: \'\'}'),

  'Single line comment': _Example(
    text: '''
public class MyClass {
  public void main() { //comment
  }
}''',
    expected: 
'''
{value: 'public '}
{className: class, children: ({value: ''}, {className: keyword, children: ({value: 'class'})}, {value: ' '}, {className: title, children: ({value: 'MyClass'})}, {value: ' '})}
{value: '{
'}
{value: '  public '}
{className: keyword, children: ({value: 'void'})}
{value: ' main() { '}
{className: comment, children: ({value: '//comment'})}
{value: '
'}
{value: '  }
'}
{value: '}'}''',
  ),

  'Readonly comment': _Example(
    text: '''
public class MyClass {
  public void main() { // readonly
  }
}''',
    expected: '''
{value: 'public '}
{className: class, children: ({value: ''}, {className: keyword, children: ({value: 'class'})}, {value: ' '}, {className: title, children: ({value: 'MyClass'})}, {value: ' '})}
{value: '{
'}
{value: '  public '}
{className: keyword, children: ({value: 'void'})}
{value: ' main() { '}
{className: comment, children: ({value: '// readonly'})}
{value: '
'}
{value: '  }
'}
{value: '}'}''',
  ),

  'Named sections': _Example(
    text: '''
class MyClass {
  void readOnlyMethod() {// [START section1]
  }// [END section1]
  // [START section2]
  void method() {
  }// [END section2]
}''',
    expected: '''
{value: ''}
{className: class, children: ({value: ''}, {className: keyword, children: ({value: 'class'})}, {value: ' '}, {className: title, children: ({value: 'MyClass'})}, {value: ' '})}
{value: '{
'}
{value: '  '}
{className: keyword, children: ({value: 'void'})}
{value: ' readOnlyMethod() {'}
{className: comment, children: ({value: '// [START section1]'})}
{value: '
'}
{value: '  }'}
{className: comment, children: ({value: '// [END section1]'})}
{value: '
'}
{value: '  '}
{className: comment, children: ({value: '// [START section2]'})}
{value: '
'}
{value: '  '}
{className: keyword, children: ({value: 'void'})}
{value: ' method() {
'}
{value: '  }'}
{className: comment, children: ({value: '// [END section2]'})}
{value: '
'}
{value: '}'}''',
  ),

  'Invalid code (Folded)': _Example(
    text: '''
class MyClass {
  void readOnlyMethod() {

  void method() {
}''',
    expected: '''
{value: ''}
{className: class, children: ({value: ''}, {className: keyword, children: ({value: 'class'})}, {value: ' '}, {className: title, children: ({value: 'MyClass'})}, {value: ' '})}
{value: '{
'}
{value: '  '}
{className: keyword, children: ({value: 'void'})}
{value: ' readOnlyMethod() {
'}
{value: '
'}
{value: '  '}
{className: keyword, children: ({value: 'void'})}
{value: ' method() {
'}
{value: '}'}''',
  ),
};

void main() {
  group('Highlight split lines test.', () {
    examples.forEach((name, example) {
      test(name, () {
        Result? highlighted;
        final mode = dart;
        highlight.registerLanguage('language', mode);
        highlighted = highlight.parse(example.text, language: 'language');

        final splitLines = highlighted.splitLines();
        final stringResult = splitLines.nodes
            ?.map((element) => element.toStringRecursive())
            .join('\n');

        expect(
          stringResult,
          example.expected,
          reason: name,
        );
      });
    });
  });
}

class _Example {
  final String text;
  final String expected;

  const _Example({required this.text, required this.expected});
}
