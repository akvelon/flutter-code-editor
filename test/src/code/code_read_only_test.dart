import 'package:flutter_code_editor/src/code/code.dart';
import 'package:flutter_code_editor/src/named_sections/parsers/brackets_start_end.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/angelscript.dart';
import 'package:highlight/languages/java.dart';

final _language = java;

void main() {
  group('Code. Read-only.', () {
    test('Parse read-only lines by end comments', () {
      const dataSets = [
        {
          'text': '''
            readonly
            editable// readonly
''', //                                        Empty line inherits readonly
          'readonly': [false, true, true],
        },
        {
          'text': '''
            readonly
            readonly //readonly
            readonly // a readonly b'''
              '\n\n'
              '''
            The above line is empty but not last, so does not inherit readonly
            ''',
          'readonly': [false, true, true, false, false, false],
        },
        {
          'text': '''
            readonly
            editable// readonly
            ''', // Last after read only, but not empty, so editable.
          'readonly': [false, true, false],
        },
      ];

      for (final data in dataSets) {
        final code = Code(
          text: data['text']! as String,
          language: _language,
        );

        final readonly = data['readonly']! as List<bool>;
        for (int i = code.lines.lines.length; --i >= 0;) {
          expect(
            code.lines.lines[i].isReadOnly,
            readonly[i],
            reason: 'Line #$i',
          );
        }
      }
    });

    test(
      'Does not parse an unsupported language',
      () {
        const textWithReadonly = 'end of line // readonly';

        final code = Code(text: textWithReadonly, language: angelscript);

        expect(code.lines.lines.first.isReadOnly, false);
      },
    );

    test('Lines in read-only sections are read-only', () {
      const text = '''
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
      const expected = [
        false,
        true,
        true,
        true,
        false,
        false,
        false,
        false,
        false,
        false,
      ];

      final code = Code(
        text: text,
        namedSectionParser: const BracketsStartEndNamedSectionParser(),
        readOnlySectionNames: {'section1', 'nonexistent'},
        language: java,
      );

      expect(
        code.lines.lines.map((line) => line.isReadOnly),
        expected,
      );
    });
  });
}
