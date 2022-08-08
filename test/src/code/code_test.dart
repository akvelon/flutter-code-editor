import 'dart:ui';

import 'package:code_text_field/src/code/code.dart';
import 'package:code_text_field/src/code/code_line.dart';
import 'package:code_text_field/src/named_sections/parsers/brackets_start_end.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/angelscript.dart';
import 'package:highlight/languages/java.dart';

final _language = java;
const _text = '''
1 Lorem ipsum dolor sit amet,
2 consectetur adipiscing elit,
3 sed do eiusmod tempor incididunt ut labore et dolore magna.
4 Ut enim ad minim veniam,
5 quis nostrud exercitation ullamco laboris nisi
6 ut aliquip
7 ex

9 ea commodo consequat.
10 Duis aute irure dolor in
11 reprehenderit in voluptate velit esse cillum dolore
12 eu fugiat nulla pariatur.
13 Excepteur sint occaecat cupidatat
14 non proident,
15 sunt in culpa qui officia deserunt mollit anim id est laborum.''';

void main() {
  group('Code. Lines.', () {
    test('Parses single line', () {
      const texts = ['', 'no-newline'];

      for (final text in texts) {
        final code = Code(text: text, language: _language);

        expect(
          const ListEquality().equals(
            code.lines,
            [
              CodeLine(
                text: text,
                textRange: TextRange(start: 0, end: text.length),
                isReadOnly: false, // ignore: avoid_redundant_argument_values
              ),
            ],
          ),
          true,
        );
      }
    });

    test('Parses lines', () {
      final code = Code(text: _text, language: _language);

      expect(
        code.lines,
        [
          // 30
          CodeLine.fromTextAndStart(
            '1 Lorem ipsum dolor sit amet,\n',
            0,
          ),

          // 31
          CodeLine.fromTextAndStart(
            '2 consectetur adipiscing elit,\n',
            30,
          ),

          // 62
          CodeLine.fromTextAndStart(
            '3 sed do eiusmod tempor incididunt ut labore et dolore magna.\n',
            61,
          ),

          // 27
          CodeLine.fromTextAndStart(
            '4 Ut enim ad minim veniam,\n',
            123,
          ),

          // 49
          CodeLine.fromTextAndStart(
            '5 quis nostrud exercitation ullamco laboris nisi\n',
            150,
          ),

          // 13
          CodeLine.fromTextAndStart(
            '6 ut aliquip\n',
            199,
          ),

          // 5
          CodeLine.fromTextAndStart(
            '7 ex\n',
            212,
          ),

          // 1
          CodeLine.fromTextAndStart(
            '\n',
            217,
          ),

          // 24
          CodeLine.fromTextAndStart(
            '9 ea commodo consequat.\n',
            218,
          ),

          // 28
          CodeLine.fromTextAndStart(
            '10 Duis aute irure dolor in\n',
            242,
          ),

          // 55
          CodeLine.fromTextAndStart(
            '11 reprehenderit in voluptate velit esse cillum dolore\n',
            270,
          ),

          // 29
          CodeLine.fromTextAndStart(
            '12 eu fugiat nulla pariatur.\n',
            325,
          ),

          // 37
          CodeLine.fromTextAndStart(
            '13 Excepteur sint occaecat cupidatat\n',
            354,
          ),

          // 17
          CodeLine.fromTextAndStart(
            '14 non proident,\n',
            391,
          ),

          // 65
          CodeLine.fromTextAndStart(
            '15 sunt in culpa qui officia deserunt mollit anim id est laborum.',
            408,
          ),
        ],
      );
      expect(code.lines.last.textRange.end, 473);
    });

    test('characterIndexToLineIndex', () {
      const tails = ['', '\n'];
      for (final tail in tails) {
        final textWithTail = _text + tail;
        final code = Code(
          text: textWithTail,
          language: _language,
        );

        final map = {
          0: 0,
          29: 0,
          30: 1,
          60: 1,
          61: 2,
          122: 2,
          123: 3,
          149: 3,
          150: 4,
          198: 4,
          199: 5,
          211: 5,
          212: 6,
          216: 6,
          217: 7,
          218: 8,
          241: 8,
          242: 9,
          269: 9,
          270: 10,
          324: 10,
          325: 11,
          353: 11,
          354: 12,
          390: 12,
          391: 13,
          407: 13,
          408: 14,
          473: 14, // Equal to length without tail
          if (tail == '\n') 474: 15, // Equal to length with tail
        };

        for (final entry in map.entries) {
          final line = code.characterIndexToLineIndex(entry.key);

          expect(
            line,
            entry.value,
            reason: 'Position: ${entry.key}, Tail: "$tail"',
          );
        }

        expect(() => code.characterIndexToLineIndex(-1), throwsRangeError);
        expect(
          () => code.characterIndexToLineIndex(textWithTail.length + 1),
          throwsRangeError,
          reason: 'Tail: "$tail"',
        );
      }
    });

    test('characterIndexToLineIndex on a single line', () {
      const texts = ['', 'no-newline'];
      for (final text in texts) {
        final code = Code(text: text, language: _language);

        for (int i = 0; i <= texts.length; i++) {
          expect(code.characterIndexToLineIndex(i), 0, reason: '"$text" at $i');
        }
      }
    });
  });

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
        for (int i = code.lines.length; --i >= 0;) {
          expect(code.lines[i].isReadOnly, readonly[i], reason: 'Line #$i');
        }
      }
    });

    test(
      'Does not parse an unsupported language',
      () {
        const textWithReadonly = 'end of line // readonly';
        final code = Code(text: textWithReadonly, language: angelscript);
        expect(code.lines.first.isReadOnly, false);
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
        code.lines.map((line) => line.isReadOnly),
        expected,
      );
    });
  });
}
