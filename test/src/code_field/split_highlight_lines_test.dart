import 'package:flutter_code_editor/src/highlight/node.dart';
import 'package:flutter_code_editor/src/highlight/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/dart.dart';

const examples = {
  //
  'Empty': _Example(text: '', expected: '{value: \'\', children: empty}\n'),

  'Readonly comment': _Example(
    text: '''
public class MyClass {
  public void main() { // readonly
  }
}''',
    expected: '''
{value: 'public ', children: empty}
{className: class}
  {value: '', children: empty}
  {className: keyword}
    {value: 'class', children: empty}
  {value: ' ', children: empty}
  {className: title}
    {value: 'MyClass', children: empty}
  {value: ' ', children: empty}
{value: '{\n', children: empty}
{value: '  public ', children: empty}
{className: keyword}
  {value: 'void', children: empty}
{value: ' main() { ', children: empty}
{className: comment}
  {value: '// readonly', children: empty}
{value: '\n', children: empty}
{value: '  }\n', children: empty}
{value: '}', children: empty}
''',
  ),

  'Named sections': _Example(
    text: '''
class MyClass {
  void someMethod() {// [START section1]
  }// [END section1]
  // [START section2]
  void method() {
  }// [END section2]
}''',
    expected: '''
{value: '', children: empty}
{className: class}
  {value: '', children: empty}
  {className: keyword}
    {value: 'class', children: empty}
  {value: ' ', children: empty}
  {className: title}
    {value: 'MyClass', children: empty}
  {value: ' ', children: empty}
{value: '{\n', children: empty}
{value: '  ', children: empty}
{className: keyword}
  {value: 'void', children: empty}
{value: ' someMethod() {', children: empty}
{className: comment}
  {value: '// [START section1]', children: empty}
{value: '\n', children: empty}
{value: '  }', children: empty}
{className: comment}
  {value: '// [END section1]', children: empty}
{value: '\n', children: empty}
{value: '  ', children: empty}
{className: comment}
  {value: '// [START section2]', children: empty}
{value: '\n', children: empty}
{value: '  ', children: empty}
{className: keyword}
  {value: 'void', children: empty}
{value: ' method() {\n', children: empty}
{value: '  }', children: empty}
{className: comment}
  {value: '// [END section2]', children: empty}
{value: '\n', children: empty}
{value: '}', children: empty}
''',
  ),

  'Invalid code (Folded)': _Example(
    text: '''
class MyClass {
  void readOnlyMethod() {

  void method() {
}''',
    expected: '''
{value: '', children: empty}
{className: class}
  {value: '', children: empty}
  {className: keyword}
    {value: 'class', children: empty}
  {value: ' ', children: empty}
  {className: title}
    {value: 'MyClass', children: empty}
  {value: ' ', children: empty}
{value: '{\n', children: empty}
{value: '  ', children: empty}
{className: keyword}
  {value: 'void', children: empty}
{value: ' readOnlyMethod() {\n', children: empty}
{value: '\n', children: empty}
{value: '  ', children: empty}
{className: keyword}
  {value: 'void', children: empty}
{value: ' method() {\n', children: empty}
{value: '}', children: empty}
''',
  ),
};

void main() {
  group('Highlight split lines test.', () {
    highlight.registerLanguage('language', dart);
    examples.forEach((name, example) {
      test(name, () {
        final highlighted = highlight.parse(example.text, language: 'language');

        final splitLines = highlighted.splitLines();
        final stringResult = splitLines.nodes
            ?.map((element) => element.toStringRecursive())
            .join();

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
