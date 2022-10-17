import 'package:flutter_code_editor/src/hidden_ranges/hidden_range.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_ranges_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HiddenRangesBuilder.', () {
    group('Merges ranges.', () {
      test('Overlapping', () {
        const ranges = {
          int: {
            1: HiddenRange(start: 1, end: 3),
            0: HiddenRange(start: 0, end: 2),
          },
        };
        final builder = HiddenRangesBuilder.fromMaps(ranges, textLength: 10);

        expect(
          builder.ranges.ranges,
          const [
            HiddenRange(start: 0, end: 3),
          ],
        );
      });

      test('Touching', () {
        const ranges = {
          int: {
            'a': HiddenRange(start: 4, end: 5),
            'b': HiddenRange(start: 1, end: 2),
          },
          double: {
            'c': HiddenRange(start: 2, end: 4),
          },
        };
        final builder = HiddenRangesBuilder.fromMaps(ranges, textLength: 10);

        expect(
          builder.ranges.ranges,
          const [
            HiddenRange(start: 1, end: 5),
          ],
        );
      });

      test('Nesting', () {
        const ranges = {
          int: {
            'a': HiddenRange(start: 6, end: 7),
            'b': HiddenRange(start: 1, end: 2),
          },
          double: {
            'c': HiddenRange(start: 5, end: 9),
          },
        };
        final builder = HiddenRangesBuilder.fromMaps(ranges, textLength: 10);

        expect(
          builder.ranges.ranges,
          const [
            HiddenRange(start: 1, end: 2),
            HiddenRange(start: 5, end: 9),
          ],
        );
      });

      test('Preserves separate', () {
        const ranges = {
          int: {
            1: HiddenRange(start: 7, end: 9),
            2: HiddenRange(start: 1, end: 2),
          },
          double: {
            'a': HiddenRange(start: 4, end: 6),
          },
          String: <Object, HiddenRange>{},
        };
        final builder = HiddenRangesBuilder.fromMaps(ranges, textLength: 10);

        expect(
          builder.ranges.ranges,
          const [
            HiddenRange(start: 1, end: 2),
            HiddenRange(start: 4, end: 6),
            HiddenRange(start: 7, end: 9),
          ],
        );
      });
    });

    test('copyWithRange, copyWithoutRange', () {
      const ranges = {
        int: {
          'b': HiddenRange(start: 5, end: 7),
          'a': HiddenRange(start: 1, end: 3),
        },
      };
      final builder = HiddenRangesBuilder.fromMaps(ranges, textLength: 10);

      final resultWith = builder.copyWithRange(
        'key',
        const HiddenRange(start: 6, end: 9),
      );
      final resultWithout = builder.copyWithoutRange('key');

      expect(
        resultWith.ranges.ranges,
        const [
          HiddenRange(start: 1, end: 3),
          HiddenRange(start: 5, end: 9),
        ],
      );
      expect(
        resultWithout.ranges.ranges,
        const [
          HiddenRange(start: 1, end: 3),
          HiddenRange(start: 5, end: 7),
        ],
      );
    });
  });
}
