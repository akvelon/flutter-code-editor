import 'package:flutter_code_editor/src/folding/foldable_block.dart';
import 'package:flutter_test/flutter_test.dart';

import 'parsers/test_executor.dart';

void main() {
  group('FoldableBlockList.joinIntersecting', () {
    test('Empty -> Empty', () {
      const blocks = <FoldableBlock>[];

      final actual = [...blocks]..joinIntersecting();

      expect(actual, blocks);
    });

    test('Single -> Single', () {
      const blocks = [
        FoldableBlock(startLine: 0, endLine: 1, type: FBT.braces),
      ];

      final actual = [...blocks]..joinIntersecting();

      expect(actual, blocks);
    });


    test('Not intersected blocks do not join', () {
      const blocks = [
        FB(startLine: 0, endLine: 3, type: FBT.braces),
        FB(startLine: 4, endLine: 5, type: FBT.imports),
        FB(startLine: 8, endLine: 10, type: FBT.parentheses),
      ];

      final actual = [...blocks]..joinIntersecting();

      expect(actual, blocks);
    });


    test('Mixed blocks join correctly', () {
      const blocks = [
        FB(startLine: 0, endLine: 3, type: FBT.braces),
        FB(startLine: 2, endLine: 5, type: FBT.imports),
        FB(startLine: 6, endLine: 10, type: FBT.parentheses),
      ];
      const expected = [
        FB(startLine: 0, endLine: 5, type: FBT.union),
        FB(startLine: 6, endLine: 10, type: FBT.parentheses),
      ];

      final actual = [...blocks]..joinIntersecting();

      expect(actual, expected);
    });

    test('Multiple intersected blocks will join in single', () {
      const blocks = [
        FB(startLine: 0, endLine: 3, type: FBT.braces),
        FB(startLine: 2, endLine: 5, type: FBT.imports),
        FB(startLine: 4, endLine: 10, type: FBT.parentheses),
      ];
      const expected = [
        FB(startLine: 0, endLine: 10, type: FBT.union),
      ];

      final actual = [...blocks]..joinIntersecting();

      expect(actual, expected);
    });

    test('Nested intersected blocks will join', () {
      const blocks = [
        FB(startLine: 0, endLine: 5, type: FBT.braces),
        FB(startLine: 1, endLine: 3, type: FBT.imports),
        FB(startLine: 3, endLine: 5, type: FBT.parentheses),
      ];
      const expected = [
        FB(startLine: 0, endLine: 5, type: FBT.braces),
        FB(startLine: 1, endLine: 5, type: FBT.union),
      ];

      final actual = [...blocks]..joinIntersecting();

      expect(actual, expected);
    });

    // TODO(Malarg): fix this. It's not desired behavior
    // This test represents situation, shown on diagram below:
    //    0 1 2 3 4 5
    //  0 |
    //  1 | |
    //  2 | |
    //  3 | |
    //  4 |   |
    //  5 |   |
    //  6 |     |
    //  7       | |
    //  8       | |
    //  9       | |
    // 10       |   |
    // 11       |   |
    // 12       |
    //
    // blocks[0] and blocks[3] should be joined, but they aren't.
    test('Containing children blocks will not join', () {
      const blocks = [
        FB(startLine: 0, endLine: 6, type: FBT.braces), // 0
        FB(startLine: 1, endLine: 3, type: FBT.parentheses), // 1
        FB(startLine: 4, endLine: 5, type: FBT.parentheses), // 2
        FB(startLine: 6, endLine: 12, type: FBT.braces), // 3
        FB(startLine: 7, endLine: 9, type: FBT.parentheses), // 4
        FB(startLine: 10, endLine: 11, type: FBT.parentheses), // 5
      ];

      // 0 intersects with 3, not detected.
      final actual = [...blocks]..joinIntersecting();

      expect(actual, blocks);
    });
  });
}
