import 'package:flutter_code_editor/src/hidden_ranges/hidden_range.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_ranges_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HiddenRangesBuilder.', () {
    group('Merges ranges.', () {
      test('Overlapping', () {
        const ranges = {
          int: {
            1: HiddenRange(
              1,
              3,
              firstLine: 1,
              lastLine: 2,
              wholeFirstLine: false,
            ),
            0: HiddenRange(
              0,
              2,
              firstLine: 0,
              lastLine: 1,
              wholeFirstLine: false,
            ),
          },
        };
        final builder = HiddenRangesBuilder.fromMaps(ranges, textLength: 10);

        expect(
          builder.ranges.ranges,
          const [
            HiddenRange(0, 3, firstLine: 0, lastLine: 2, wholeFirstLine: false),
          ],
        );
      });

      test('Touching', () {
        const ranges = {
          int: {
            'a': HiddenRange(
              4,
              5,
              firstLine: 8,
              lastLine: 10,
              wholeFirstLine: false,
            ),
            'b': HiddenRange(
              1,
              2,
              firstLine: 1,
              lastLine: 2,
              wholeFirstLine: true,
            ),
          },
          double: {
            'c': HiddenRange(
              2,
              4,
              firstLine: 4,
              lastLine: 5,
              wholeFirstLine: false,
            ),
          },
        };
        final builder = HiddenRangesBuilder.fromMaps(ranges, textLength: 10);

        expect(
          builder.ranges.ranges,
          const [
            HiddenRange(1, 5, firstLine: 1, lastLine: 10, wholeFirstLine: true),
          ],
        );
      });

      test('Nesting', () {
        const ranges = {
          int: {
            'a': HiddenRange(
              6,
              7,
              firstLine: 10,
              lastLine: 20,
              wholeFirstLine: true,
            ),
            'b': HiddenRange(
              1,
              2,
              firstLine: -10,
              lastLine: -5,
              wholeFirstLine: true,
            ),
          },
          double: {
            'c': HiddenRange(
              5,
              9,
              firstLine: 5,
              lastLine: 15,
              wholeFirstLine: false,
            ),
          },
        };
        final builder = HiddenRangesBuilder.fromMaps(ranges, textLength: 10);

        expect(
          builder.ranges.ranges,
          const [
            HiddenRange(
              1,
              2,
              firstLine: -10,
              lastLine: -5,
              wholeFirstLine: true,
            ),
            HiddenRange(
              5,
              9,
              firstLine: 5,
              lastLine: 15,
              wholeFirstLine: false,
            ),
          ],
        );
      });

      test('Preserves separate', () {
        const ranges = {
          int: {
            1: HiddenRange(
              7,
              9,
              firstLine: 1,
              lastLine: 2,
              wholeFirstLine: true,
            ),
            2: HiddenRange(
              1,
              2,
              firstLine: 3,
              lastLine: 4,
              wholeFirstLine: false,
            ),
          },
          double: {
            'a': HiddenRange(
              4,
              6,
              firstLine: 5,
              lastLine: 6,
              wholeFirstLine: true,
            ),
          },
          String: <Object, HiddenRange>{},
        };
        final builder = HiddenRangesBuilder.fromMaps(ranges, textLength: 10);

        expect(
          builder.ranges.ranges,
          const [
            HiddenRange(1, 2, firstLine: 3, lastLine: 4, wholeFirstLine: false),
            HiddenRange(4, 6, firstLine: 5, lastLine: 6, wholeFirstLine: true),
            HiddenRange(7, 9, firstLine: 1, lastLine: 2, wholeFirstLine: true),
          ],
        );
      });
    });

    test('copyWithRange, copyWithoutRange', () {
      const ranges = {
        int: {
          'b': HiddenRange(
            5,
            7,
            firstLine: 1,
            lastLine: 2,
            wholeFirstLine: true,
          ),
          'a': HiddenRange(
            1,
            3,
            firstLine: 3,
            lastLine: 4,
            wholeFirstLine: false,
          ),
        },
      };
      final builder = HiddenRangesBuilder.fromMaps(ranges, textLength: 10);

      final resultWith = builder.copyWithRange(
        'key',
        const HiddenRange(
          6,
          9,
          firstLine: 5,
          lastLine: 6,
          wholeFirstLine: false,
        ),
      );
      final resultWithout = builder.copyWithoutRange('key');

      expect(
        resultWith.ranges.ranges,
        const [
          HiddenRange(1, 3, firstLine: 3, lastLine: 4, wholeFirstLine: false),
          HiddenRange(5, 9, firstLine: 1, lastLine: 6, wholeFirstLine: true),
        ],
      );
      expect(
        resultWithout.ranges.ranges,
        const [
          HiddenRange(1, 3, firstLine: 3, lastLine: 4, wholeFirstLine: false),
          HiddenRange(5, 7, firstLine: 1, lastLine: 2, wholeFirstLine: true),
        ],
      );
    });
  });
}
