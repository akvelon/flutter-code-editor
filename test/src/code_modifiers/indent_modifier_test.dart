import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Indent modifier test', () {
    const examples = [
      //
      _Example(
        r'`:` is right before `\n`',
        initialValue: TextEditingValue(
          text: '''
aaa:
''',
          selection: TextSelection.collapsed(offset: 4),
        ),
        editedValue: TextEditingValue(
          text: '''
aaa:

''',
          selection: TextSelection.collapsed(offset: 5),
        ),
        expected: TextEditingValue(
          text: '''
aaa:
  
''',
          selection: TextSelection.collapsed(offset: 7),
        ),
      ),

      _Example(
        '`:` is in the middle of the line',
        initialValue: TextEditingValue(
          text: '''
{'a' : 'a'}
''',
          selection: TextSelection.collapsed(offset: 11),
        ),
        editedValue: TextEditingValue(
          text: '''
{'a' : 'a'}

''',
          selection: TextSelection.collapsed(offset: 12),
        ),
        expected: TextEditingValue(
          text: '''
{'a' : 'a'}

''',
          selection: TextSelection.collapsed(offset: 12),
        ),
      ),

      _Example(
        r'`{` is right before `\n`',
        initialValue: TextEditingValue(
          text: '''
a{
''',
          selection: TextSelection.collapsed(offset: 2),
        ),
        editedValue: TextEditingValue(
          text: '''
a{

''',
          selection: TextSelection.collapsed(offset: 3),
        ),
        expected: TextEditingValue(
          text: '''
a{
  
''',
          selection: TextSelection.collapsed(offset: 5),
        ),
      ),

      _Example(
        '`{` char is in the middle of the line',
        initialValue: TextEditingValue(
          text: '''
a{a
''',
          selection: TextSelection.collapsed(offset: 3),
        ),
        editedValue: TextEditingValue(
          text: '''
a{a

''',
          selection: TextSelection.collapsed(offset: 4),
        ),
        expected: TextEditingValue(
          text: '''
a{a

''',
          selection: TextSelection.collapsed(offset: 4),
        ),
      ),

      _Example(
        r'There are spaces between `:` and `\n`',
        initialValue: TextEditingValue(
          text: '''
a:  
''',
          selection: TextSelection.collapsed(offset: 4),
        ),
        editedValue: TextEditingValue(
          text: '''
a:  

''',
          selection: TextSelection.collapsed(offset: 5),
        ),
        expected: TextEditingValue(
          text: '''
a:  
  
''',
          selection: TextSelection.collapsed(offset: 7),
        ),
      ),

      _Example(
        r'There are spaces between `{` and `\n`',
        initialValue: TextEditingValue(
          text: '''
a{  
''',
          selection: TextSelection.collapsed(offset: 4),
        ),
        editedValue: TextEditingValue(
          text: '''
a{  

''',
          selection: TextSelection.collapsed(offset: 5),
        ),
        expected: TextEditingValue(
          text: '''
a{  
  
''',
          selection: TextSelection.collapsed(offset: 7),
        ),
      ),

      _Example(
        r'`:` and `{` are on the same line `\n`',
        initialValue: TextEditingValue(
          text: '''
a{:  
''',
          selection: TextSelection.collapsed(offset: 5),
        ),
        editedValue: TextEditingValue(
          text: '''
a{:  

''',
          selection: TextSelection.collapsed(offset: 6),
        ),
        expected: TextEditingValue(
          text: '''
a{:  
  
''',
          selection: TextSelection.collapsed(offset: 8),
        ),
      ),

      _Example(
        'Preserves indentation of the previous line',
        initialValue: TextEditingValue(
          text: '''
  a
''',
          selection: TextSelection.collapsed(offset: 3),
        ),
        editedValue: TextEditingValue(
          text: '''
  a

''',
          selection: TextSelection.collapsed(offset: 4),
        ),
        expected: TextEditingValue(
          text: '''
  a
  
''',
          selection: TextSelection.collapsed(offset: 6),
        ),
      ),

      _Example(
        'Indentation for `:` is added to the previous indentation',
        initialValue: TextEditingValue(
          text: '''
  a:
''',
          selection: TextSelection.collapsed(offset: 4),
        ),
        editedValue: TextEditingValue(
          text: '''
  a:

''',
          selection: TextSelection.collapsed(offset: 5),
        ),
        expected: TextEditingValue(
          text: '''
  a:
    
''',
          selection: TextSelection.collapsed(offset: 9),
        ),
      ),

      _Example(
        'Indentation for `{` is added to the previous indentation',
        initialValue: TextEditingValue(
          text: '''
  a{
''',
          selection: TextSelection.collapsed(offset: 4),
        ),
        editedValue: TextEditingValue(
          text: '''
  a{

''',
          selection: TextSelection.collapsed(offset: 5),
        ),
        expected: TextEditingValue(
          text: '''
  a{
    
''',
          selection: TextSelection.collapsed(offset: 9),
        ),
      ),
    ];

    for (final example in examples) {
      final controller = CodeController();
      controller.value = example.initialValue;

      controller.value = example.editedValue;

      expect(
        controller.value,
        example.expected,
        reason: example.name,
      );
    }
  });
}

class _Example {
  final String name;
  final TextEditingValue initialValue;
  final TextEditingValue editedValue;
  final TextEditingValue expected;

  const _Example(
    this.name, {
    required this.initialValue,
    required this.editedValue,
    required this.expected,
  });
}
