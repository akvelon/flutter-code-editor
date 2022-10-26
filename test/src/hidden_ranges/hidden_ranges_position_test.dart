import 'dart:ui';

import 'package:flutter_code_editor/src/hidden_ranges/hidden_range.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_ranges.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

const affinities = [TextAffinity.upstream, TextAffinity.downstream];

void main() {
  group('HiddenRanges. cutPosition', () {
    test('No ranges - No changes', () {
      expect(
        HiddenRanges.empty.cutPosition(7),
        7,
      );
    });

    test('Cut with visible beginning and end', () {
      final examples = <int, int>{
        -1: -1, //    No selection does not change
        0: 0, //      Zero before the first range does not change

        19: 19, //    Range 0 just before
        20: 20, //    Range 0 collapse
        21: 20, //    Range 0 hidden
        22: 20, //    Range 0 hidden
        23: 20, //    Range 0 last hidden
        24: 21, //    Range 0 just after

        30: 27, //    Range 1 just before
        31: 28, //    Range 1 collapse
        32: 28, //    Range 1 hidden
        42: 28, //    Range 1 last hidden
        43: 29, //    Range 1 just after

        66: 52, //    Range 2 just before
        67: 53, //    Range 2 collapse
        68: 53, //    Range 2 hidden
        91: 53, //    Range 2 last hidden
        92: 54, //    Range 2 just after

        99: 61, //    Range 3 just before
        100: 62, //   Range 3 collapse
        101: 62, //   Range 3 last hidden
        102: 63, //   Range 3 just after / Range 4 collapse
        103: 63, //   Range 4 hidden
        104: 64, //   Range 4 just after / Range 5 collapse
        105: 64, //   Range 5 hidden
        106: 65, //   Range 5 just after / Range 6 collapse
        107: 65, //   Range 6 hidden
        108: 66, //   Range 6 just after / Range 7 collapse
        109: 66, //   Range 7 hidden
        110: 67, //   Range 7 just after / Range 8 collapse
        111: 67, //   Range 8 hidden
        112: 68, //   Range 8 just after / Range 9 just before
        113: 69, //   Range 9 collapse
        114: 69, //   Range 9 hidden
        123: 69, //   Range 9 last hidden
        124: 70, //   Range 9 just after

        224: 170, //  Way after all ranges
      };

      int i = 0;

      for (final example in examples.entries) {
        final input = example.key;
        final expected = example.value;

        int cutPosition() {
          return hiddenRanges.cutPosition(input);
        }

        final reason = '#$i. $input -> $expected';
        expect(cutPosition, returnsNormally, reason: reason);
        expect(cutPosition(), expected, reason: reason);

        i++;
      }
    });

    test('Cut with a single range', () {
      final hiddenRanges = HiddenRanges(
        ranges: const [
          HiddenRange(5, 10, firstLine: 0, lastLine: 0, wholeFirstLine: true),
        ],
        textLength: 140,
      );

      final examples = <int, int>{
        4: 4,
        5: 5,
        6: 5,
        7: 5,
        8: 5,
        9: 5,
        10: 5,
        11: 6,
      };
      int i = 0;

      for (final example in examples.entries) {
        final input = example.key;
        final expected = example.value;

        int cutPosition() {
          return hiddenRanges.cutPosition(input);
        }

        final reason = '#$i. $input -> $expected';
        expect(cutPosition, returnsNormally, reason: reason);
        expect(cutPosition(), expected, reason: reason);
      }

      i++;
    });
  });

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

        27: [30, 30], //   Range 1 just before
        28: [42, 31], //   Range 1 collapse
        29: [43, 43], //   Range 1 just after

        52: [66, 66], //   Range 2 just before
        53: [91, 67], //   Range 2 collapse
        54: [92, 92], //   Range 2 just after

        61: [99, 99], //   Range 3 just before
        62: [101, 100], // Range 3 collapse / Range 4 just before
        63: [103, 102], // Range 3 just after / Range 4 collapse
        64: [105, 104], // Range 4 just after / Range 5 collapse
        65: [107, 106], // Range 5 just after / Range 6 collapse
        66: [109, 108], // Range 6 just after / Range 7 collapse
        67: [111, 110], // Range 7 just after / Range 8 collapse
        68: [112, 112], // Range 8 just after

        69: [123, 113], // Range 9 collapse

        70: [124, 124], // After all ranges
      };
      int i = 0;

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

    test('Recover with a single range', () {
      final hiddenRanges = HiddenRanges(
        ranges: const [
          HiddenRange(5, 10, firstLine: 0, lastLine: 0, wholeFirstLine: true),
        ],
        textLength: 140,
      );

      final examples = <int, List<int>>{
        4: [4, 4],
        5: [10, 5],
        6: [11, 11],
      };
      int i = 0;

      for (final example in examples.entries) {
        for (int affinityIndex = 0; affinityIndex < 2; affinityIndex++) {
          final input = example.key;
          final placeHiddenRanges = affinities[affinityIndex];
          final expected = example.value[affinityIndex];

          int recoverPosition() {
            return hiddenRanges.recoverPosition(
              input,
              placeHiddenRanges: placeHiddenRanges,
            );
          }

          final reason = '#$i. $placeHiddenRanges: $input -> $expected';
          expect(recoverPosition, returnsNormally, reason: reason);
          expect(recoverPosition(), expected, reason: reason);
        }

        i++;
      }
    });
  });
}
