import 'dart:ui';

import 'package:flutter_code_editor/src/hidden_ranges/hidden_range.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_ranges.dart';
import 'package:flutter_test/flutter_test.dart';

final _hiddenRanges = HiddenRanges(
  ranges: const [
    //                How many chars hidden by the beginning of this range:
    HiddenRange(start: 20, end: 23), //    0
    HiddenRange(start: 31, end: 38), //    3
    HiddenRange(start: 38, end: 42), //   10
    HiddenRange(start: 67, end: 91), //   14
    HiddenRange(start: 100, end: 101), // 38
    HiddenRange(start: 102, end: 103), // 39
    HiddenRange(start: 104, end: 105), // 40
    HiddenRange(start: 106, end: 107), // 41
    HiddenRange(start: 108, end: 109), // 42
    HiddenRange(start: 110, end: 111), // 43
    HiddenRange(start: 113, end: 123), // 44
    //                                    54
  ],
  textLength: 140,
);

const affinities = [TextAffinity.upstream, TextAffinity.downstream];

void main() {
  group('HiddenRanges. recoverPosition.', () {
    test('No ranges - No changes', () {
      expect(
        HiddenRanges.empty.recoverPosition(
          7,
          placeHiddenRanges: TextAffinity.upstream,
        ),
        7,
      );
      expect(
        HiddenRanges.empty.recoverPosition(
          7,
          placeHiddenRanges: TextAffinity.downstream,
        ),
        7,
      );
    });

    test('Recover with visible beginning and end', () {
      final examples = <int, List<int>>{
        -1: [-1, -1], //   No selection does not change
        0: [0, 0], //      Zero before the first range does not change

        19: [19, 19], //   Range 0 just before
        20: [23, 20], //   Range 0 collapse
        21: [24, 24], //   Range 0 just after

        27: [30, 30], //   Ranges 1+2 just before
        28: [42, 31], //   Ranges 1+2 collapse
        29: [43, 43], //   Ranges 1+2 just after

        52: [66, 66], //   Range 3 just before
        53: [91, 67], //   Range 3 collapse
        54: [92, 92], //   Range 3 just after

        61: [99, 99], //   Range 4 just before
        62: [101, 100], // Range 4 collapse / Range 5 just before
        63: [103, 102], // Range 4 just after / Range 5 collapse
        64: [105, 104], // Range 5 just after / Range 6 collapse
        65: [107, 106], // Range 6 just after / Range 7 collapse
        66: [109, 108], // Range 7 just after / Range 8 collapse
        67: [111, 110], // Range 8 just after / Range 9 collapse
        68: [112, 112], // Range 9 just after

        69: [123, 113], // Range 10 collapse

        70: [124, 124], // After all ranges
      };
      int i = 1;

      for (final example in examples.entries) {
        for (int affinityIndex = 0; affinityIndex < 2; affinityIndex++) {
          final placeHiddenRanges = affinities[affinityIndex];
          final expected = example.value[affinityIndex];

          int recoverPosition() {
            return _hiddenRanges.recoverPosition(
              example.key,
              placeHiddenRanges: placeHiddenRanges,
            );
          }

          final reason = '#$i. $placeHiddenRanges: ${example.key} -> $expected';
          expect(recoverPosition, returnsNormally, reason: reason);
          expect(recoverPosition(), expected, reason: reason);
        }

        i++;
      }
    });

    test('Recover with a single range', () {
      final hiddenRanges = HiddenRanges(
        ranges: const [
          HiddenRange(start: 5, end: 10),
        ],
        textLength: 140,
      );

      final examples = <int, List<int>>{
        4: [4, 4],
        5: [10, 5],
        6: [11, 11],
      };
      int i = 1;

      for (final example in examples.entries) {
        for (int affinityIndex = 0; affinityIndex < 2; affinityIndex++) {
          final placeHiddenRanges = affinities[affinityIndex];
          final expected = example.value[affinityIndex];

          int recoverPosition() {
            return hiddenRanges.recoverPosition(
              example.key,
              placeHiddenRanges: placeHiddenRanges,
            );
          }

          final reason = '#$i. $placeHiddenRanges: ${example.key} -> $expected';
          expect(recoverPosition, returnsNormally, reason: reason);
          expect(recoverPosition(), expected, reason: reason);
        }

        i++;
      }
    });
  });
}
