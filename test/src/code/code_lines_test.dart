import 'dart:ui';

import 'package:flutter_code_editor/src/code/code.dart';
import 'package:flutter_code_editor/src/code/code_line.dart';
import 'package:flutter_code_editor/src/code/code_lines.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';

import '../common/lorem_ipsum.dart';

final _language = java;

void main() {
  group('Code. Lines.', () {
    test('Parses single line', () {
      const texts = ['', 'no-newline'];

      for (final text in texts) {
        final code = Code(text: text, language: _language);

        expect(
          code.lines,
          CodeLines([
            CodeLine.fromTextAndRange(
              text: text,
              textRange: TextRange(start: 0, end: text.length),
              isReadOnly: false, // ignore: avoid_redundant_argument_values
            ),
          ]),
        );
      }
    });

    test('Parses lines', () {
      final code = Code(text: loremIpsum, language: _language);

      expect(
        code.lines,
        CodeLines([
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

          // 61
          CodeLine.fromTextAndStart(
            '3 sed do eiusmod tempor incididunt ut labore et dolore magna\n',
            61,
          ),

          // 35
          CodeLine.fromTextAndStart(
            '4 aliqua. Ut enim ad minim veniam,\n',
            122,
          ),

          // 49
          CodeLine.fromTextAndStart(
            '5 quis nostrud exercitation ullamco laboris nisi\n',
            157,
          ),

          // 13
          CodeLine.fromTextAndStart(
            '6 ut aliquip\n',
            206,
          ),

          // 5
          CodeLine.fromTextAndStart(
            '7 ex\n',
            219,
          ),

          // 1
          CodeLine.fromTextAndStart(
            '\n',
            224,
          ),

          // 24
          CodeLine.fromTextAndStart(
            '9 ea commodo consequat.\n',
            225,
          ),

          // 28
          CodeLine.fromTextAndStart(
            '10 Duis aute irure dolor in\n',
            249,
          ),

          // 55
          CodeLine.fromTextAndStart(
            '11 reprehenderit in voluptate velit esse cillum dolore\n',
            277,
          ),

          // 29
          CodeLine.fromTextAndStart(
            '12 eu fugiat nulla pariatur.\n',
            332,
          ),

          // 37
          CodeLine.fromTextAndStart(
            '13 Excepteur sint occaecat cupidatat\n',
            361,
          ),

          // 17
          CodeLine.fromTextAndStart(
            '14 non proident,\n',
            398,
          ),

          // 65
          CodeLine.fromTextAndStart(
            '15 sunt in culpa qui officia deserunt mollit anim id est laborum.',
            415,
          ),
        ]),
      );
      expect(code.lines.lines.last.textRange.end, 480);
    });

    test('characterIndexToLineIndex', () {
      const tails = ['', '\n'];
      for (final tail in tails) {
        final textWithTail = loremIpsum + tail;
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
          121: 2,
          132: 3,
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
          final line = code.lines.characterIndexToLineIndex(entry.key);

          expect(
            line,
            entry.value,
            reason: 'Position: ${entry.key}, Tail: "$tail"',
          );
        }

        expect(
          () => code.lines.characterIndexToLineIndex(-1),
          throwsRangeError,
        );
        expect(
          () => code.lines.characterIndexToLineIndex(textWithTail.length + 1),
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
          expect(
            code.lines.characterIndexToLineIndex(i),
            0,
            reason: '"$text" at $i',
          );
        }
      }
    });
  });
}
