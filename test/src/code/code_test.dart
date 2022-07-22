import 'dart:ui';

import 'package:code_text_field/src/code/code.dart';
import 'package:code_text_field/src/code/code_line.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

const singleLineComments = ['//', '#'];

const text = '''
1 Lorem ipsum dolor sit amet,
2 consectetur adipiscing elit,
3 sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
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
  group('Code', () {
    test('parses single line', () {
      const texts = ['', 'no-newline'];

      for (final text in texts) {
        final code = Code(text: text, singleLineComments: singleLineComments);

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

    test('parses lines', () {
      final code = Code(text: text, singleLineComments: singleLineComments);

      expect(
        const ListEquality().equals(
          code.lines,
          [
            CodeLine.fromTextAndStart('1 Lorem ipsum dolor sit amet,\n', 0), // 30
            CodeLine.fromTextAndStart('2 consectetur adipiscing elit,\n', 30), // 31
            CodeLine.fromTextAndStart('3 sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n', 61), // 69
            CodeLine.fromTextAndStart('4 Ut enim ad minim veniam,\n', 130), // 27
            CodeLine.fromTextAndStart('5 quis nostrud exercitation ullamco laboris nisi\n', 157), // 49
            CodeLine.fromTextAndStart('6 ut aliquip\n', 206), // 13
            CodeLine.fromTextAndStart('7 ex\n', 219), // 5
            CodeLine.fromTextAndStart('\n', 224), // 1
            CodeLine.fromTextAndStart('9 ea commodo consequat.\n', 225), // 24
            CodeLine.fromTextAndStart('10 Duis aute irure dolor in\n', 249), // 28
            CodeLine.fromTextAndStart('11 reprehenderit in voluptate velit esse cillum dolore\n', 277), // 55
            CodeLine.fromTextAndStart('12 eu fugiat nulla pariatur.\n', 332), // 29
            CodeLine.fromTextAndStart('13 Excepteur sint occaecat cupidatat\n', 361), // 37
            CodeLine.fromTextAndStart('14 non proident,\n', 398), // 17
            CodeLine.fromTextAndStart('15 sunt in culpa qui officia deserunt mollit anim id est laborum.', 415), // 65
          ],
        ),
        true,
      );
      expect(code.lines.last.textRange.end, 480);
    });

    test('characterIndexToLineIndex', () {
      const tails = ['', '\n'];
      for (final tail in tails) {
        final textWithTail = text + tail;
        final code = Code(
          text: textWithTail,
          singleLineComments: singleLineComments,
        );

        final map = {
          0: 0,
          29: 0,
          30: 1,
          60: 1,
          61: 2,
          129: 2,
          130: 3,
          156: 3,
          157: 4,
          205: 4,
          206: 5,
          218: 5,
          219: 6,
          223: 6,
          224: 7,
          225: 8,
          248: 8,
          249: 9,
          276: 9,
          277: 10,
          331: 10,
          332: 11,
          360: 11,
          361: 12,
          397: 12,
          398: 13,
          414: 13,
          415: 14,
          480: 14, // Equal to length without tail
          if (tail == '\n') 481: 15, // Equal to length with tail
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

    test('characterIndexToLineIndex on signe line', () {
      const texts = ['', 'no-newline'];
      for (final text in texts) {
        final code = Code(text: text, singleLineComments: singleLineComments);

        for (int i = 0; i <= texts.length; i++) {
          expect(code.characterIndexToLineIndex(i), 0, reason: '"$text" at $i');
        }
      }
    });

    test('parse read-only lines by end comments', () {
      const dataSets = [
        {
          'text': '''
            readonly
            editable// readonly
''',                                        // Empty line inherits readonly
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
          singleLineComments: singleLineComments,
        );

        final readonly = data['readonly']! as List<bool>;
        for (int i = code.lines.length; --i >= 0;) {
          expect(code.lines[i].isReadOnly, readonly[i], reason: 'Line #$i');
        }
      }
    });
  });
}
