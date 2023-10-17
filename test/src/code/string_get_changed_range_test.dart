import 'dart:ui';

import 'package:flutter_code_editor/src/code/string.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('String.getChangedRange', () {
    const examples = [
      //
      _Example(
        'Empty vs empty',
        str1: '',
        str2: '',
        expectedSingle: TextRange.empty,
      ),

      _Example(
        'Same',
        str1: 'abc',
        str2: 'abc',
        expectedSingle: TextRange.empty,
      ),

      _Example(
        'Adding: Empty vs non-empty',
        str1: '',
        str2: 'abc',
        expectedSingle: TextRange(start: 0, end: 3),
      ),

      _Example(
        'Adding: Common prefix',
        str1: 'abc',
        str2: 'abc123',
        expectedSingle: TextRange(start: 3, end: 6),
      ),

      _Example(
        'Adding: Common suffix',
        str1: 'abc',
        str2: '123abc',
        expectedSingle: TextRange(start: 0, end: 3),
      ),

      _Example(
        'Adding duplicate',
        str1: 'abc',
        str2: 'abc1abc',
        expected: [TextRange(start: 0, end: 4), TextRange(start: 3, end: 7)],
      ),

      _Example(
        'Removing: Non-empty vs empty',
        str1: 'abc',
        str2: '',
        expectedSingle: TextRange(start: 0, end: 0),
      ),

      _Example(
        'Removing: Common prefix',
        str1: 'abc123',
        str2: 'abc',
        expectedSingle: TextRange(start: 3, end: 3),
      ),

      _Example(
        'Removing a duplicate on a side',
        str1: 'abc1abc',
        str2: 'abc',
        expected: [TextRange(start: 0, end: 0), TextRange(start: 3, end: 3)],
      ),

      _Example(
        'Replacing',
        str1: 'abc123def',
        str2: 'abc3210def',
        expectedSingle: TextRange(start: 3, end: 7),
      ),

      _Example(
        'Removed a duplicate in the middle',
        str1: 'abccde',
        str2: 'abcde',
        expected: [TextRange(start: 2, end: 2), TextRange(start: 3, end: 3)],
      ),
    ];
    const affinities = [TextAffinity.upstream, TextAffinity.downstream];

    for (final example in examples) {
      for (int affinityIndex = 0; affinityIndex < 2; affinityIndex++) {
        final affinity = affinities[affinityIndex];
        final reason = '${example.name}, $affinity';

        expect(
          () => example.str2.getChangedRange(
            example.str1,
            attributeChangeTo: affinity,
          ),
          returnsNormally,
          reason: reason,
        );

        final range = example.str2.getChangedRange(
          example.str1,
          attributeChangeTo: affinity,
        );

        expect(
          range,
          example.expectedSingle ?? example.expected![affinityIndex],
          reason: reason,
        );
      }
    }
  });
}

class _Example {
  final String name;
  final String str1;
  final String str2;
  final List<TextRange>? expected;
  final TextRange? expectedSingle;

  const _Example(
    this.name, {
    required this.str1,
    required this.str2,
    this.expected,
    this.expectedSingle,
  });
}
