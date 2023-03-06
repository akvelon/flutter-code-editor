import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/src/code/code.dart';
import 'package:flutter_code_editor/src/code/code_edit_result.dart';
import 'package:flutter_code_editor/src/named_sections/parsers/brackets_start_end.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart';

const _languageName = 'java';
final _language = java;

const _fullText1 = '''
public class MyClass {
  public void main() { // [START section1]
  }
  // [END section1]
  // [START section2]
  void method() {
  }
  // [END section2]
}
''';

// Each blank line has two spaces here:
const _visibleText1 = '''
public class MyClass {
  public void main() { 
  }
  
  
  void method() {
  }
  
}
''';

void main() {
  test('Code. getEditResult', () {
    const examples = [
      //
      _Example(
        'Empty -> Something',
        fullTextBefore: '',
        visibleValueAfter: TextEditingValue(text: _visibleText1),
        expected: CodeEditResult(
          fullTextAfter: _visibleText1,
          linesChanged: TextRange(start: 0, end: 0),
        ),
      ),

      _Example(
        'Something -> Empty',
        fullTextBefore: _fullText1,
        visibleValueAfter: TextEditingValue.empty,
        expected: CodeEditResult(
          fullTextAfter: '',
          linesChanged: TextRange(start: 0, end: 8), // Empty line 9 is intact.
        ),
      ),

      _Example(
        'Change not touching hidden range borders',
        fullTextBefore: _fullText1,
        visibleValueAfter: TextEditingValue(
          // Each blank line has two spaces here:
          text: '''
public class MyClass {
  public void main() { 
  }
  
  
  method(int a) {{
  }}
  
}
''',
        ),
        expected: CodeEditResult(
          fullTextAfter: '''
public class MyClass {
  public void main() { // [START section1]
  }
  // [END section1]
  // [START section2]
  method(int a) {{
  }}
  // [END section2]
}
''',
          linesChanged: TextRange(start: 5, end: 6),
        ),
      ),

      _Example(
        'Insertion at a range collapse - Inserts before the range',
        fullTextBefore: _fullText1,
        visibleValueAfter: TextEditingValue(
          // Each blank line has two spaces here:
          text: '''
public class MyClass {
  public void main() { 
  }
  
  
  void method() {
  }
  ;
}
''',
        ),
        expected: CodeEditResult(
          fullTextAfter: '''
public class MyClass {
  public void main() { // [START section1]
  }
  // [END section1]
  // [START section2]
  void method() {
  }
  ;// [END section2]
}
''',
          linesChanged: TextRange.collapsed(7),
        ),
      ),

      _Example(
        'Removing a block that is both before and after a hidden range - '
        'Removes it before',
        fullTextBefore: '''
{
//[START section1]
}
''',
        visibleValueAfter: TextEditingValue(
          text: '''
{
}
''',
        ),
        expected: CodeEditResult(
          fullTextAfter: '''
{//[START section1]
}
''',
          linesChanged: TextRange(start: 0, end: 1),
        ),
      ),

      _Example(
        'Replacing between ranges keeps the ranges - '
        'Keeps the range after, Deletes the range before',
        fullTextBefore: '''
{//[START section1]
;//[END section1]
}
''',
        visibleValueAfter: TextEditingValue(
          text: '''
{()
}
''',
        ),
        expected: CodeEditResult(
          fullTextAfter: '''
{()//[END section1]
}
''',
          linesChanged: TextRange(start: 0, end: 1),
        ),
      ),

      _Example(
        'If all text is a single hidden range, insert before it',
        fullTextBefore: '//[START section1]',
        visibleValueAfter: TextEditingValue(
          text: ';',
        ),
        expected: CodeEditResult(
          fullTextAfter: ';//[START section1]',
          linesChanged: TextRange(start: 0, end: 0),
        ),
      ),
    ];

    for (final example in examples) {
      final highlighted = highlight.parse(
        example.fullTextBefore,
        language: _languageName,
      );

      final code = Code(
        text: example.fullTextBefore,
        highlighted: highlighted,
        language: _language,
        namedSectionParser: const BracketsStartEndNamedSectionParser(),
      );

      final selections = [
        for (int n = code.visibleText.length; --n >= -1;)
          TextSelection.collapsed(offset: n),
      ];

      for (final selection in selections) {
        expect(
          () => code.getEditResult(selection, example.visibleValueAfter),
          returnsNormally,
          reason: example.name,
        );

        final result = code.getEditResult(selection, example.visibleValueAfter);
        expect(
          result,
          example.expected,
          reason: example.name,
        );
      }
    }
  });
}

class _Example {
  final String name;
  final String fullTextBefore;
  final TextEditingValue visibleValueAfter;
  final CodeEditResult? expected;

  const _Example(
    this.name, {
    required this.fullTextBefore,
    required this.visibleValueAfter,
    this.expected,
  });
}
