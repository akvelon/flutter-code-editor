import 'package:flutter_code_editor/src/folding/foldable_block.dart';
import 'package:flutter_test/flutter_test.dart';

import 'parsers/test_executor.dart';

void main() {
  group('Foldable block test', () {
    test('Join intersected blocks in empty list will not throw exception', () {
      const blocks = <FoldableBlock>[];

      final actual = blocks.deepCopy()..joinIntersecting();

      expect(actual, blocks);
    });

    test('Join blocks in list with one block will not throw exception', () {
      const blocks = [
        FoldableBlock(startLine: 0, endLine: 1, type: FBT.braces),
      ];

      final actual = blocks.deepCopy()..joinIntersecting();

      expect(actual, blocks);
    });

    test('Join intersecting blocks in list with two intersecting blocks', () {
      const blocks = [
        FoldableBlock(startLine: 0, endLine: 1, type: FBT.braces),
        FoldableBlock(startLine: 1, endLine: 2, type: FBT.braces),
      ];
      const matcher = [
        FoldableBlock(startLine: 0, endLine: 2, type: FBT.union),
      ];

      final actual = blocks.deepCopy()..joinIntersecting();

      expect(actual, matcher);
    });

    test('Join intersecting blocks in list with two not intersecting blocks',
        () {
      const blocks = [
        FoldableBlock(startLine: 0, endLine: 1, type: FBT.braces),
        FoldableBlock(startLine: 2, endLine: 3, type: FBT.braces),
      ];

      final actual = blocks.deepCopy()..joinIntersecting();

      expect(actual, blocks);
    });

    test('Multiple not intersected blocks will not join', () {
      const blocks = [
        FB(startLine: 0, endLine: 3, type: FBT.braces),
        FB(startLine: 4, endLine: 5, type: FBT.imports),
        FB(startLine: 8, endLine: 10, type: FBT.parentheses),
      ];

      final actual = blocks.deepCopy()..joinIntersecting();

      expect(actual, blocks);
    });

    test('Multiple intersected blocks will join', () {
      const blocks = [
        FB(startLine: 0, endLine: 3, type: FBT.braces),
        FB(startLine: 2, endLine: 5, type: FBT.imports),
        FB(startLine: 4, endLine: 10, type: FBT.parentheses),
      ];
      const matcher = [
        FB(startLine: 0, endLine: 10, type: FBT.union),
      ];

      final actual = blocks.deepCopy()..joinIntersecting();

      expect(actual, matcher);
    });

    test('Mixed blocks will join correctly', () {
      const blocks = [
        FB(startLine: 0, endLine: 3, type: FBT.braces),
        FB(startLine: 2, endLine: 5, type: FBT.imports),
        FB(startLine: 6, endLine: 10, type: FBT.parentheses),
      ];
      const matcher = [
        FB(startLine: 0, endLine: 5, type: FBT.union),
        FB(startLine: 6, endLine: 10, type: FBT.parentheses),
      ];

      final actual = blocks.deepCopy()..joinIntersecting();

      expect(actual, matcher);
    });

    test('Nested intersected blocks will join', () {
      const blocks = [
        FB(startLine: 0, endLine: 5, type: FBT.braces),
        FB(startLine: 1, endLine: 3, type: FBT.imports),
        FB(startLine: 3, endLine: 5, type: FBT.parentheses),
      ];
      const matcher = [
        FB(startLine: 0, endLine: 5, type: FBT.braces),
        FB(startLine: 1, endLine: 5, type: FBT.union),
      ];

      final actual = blocks.deepCopy()..joinIntersecting();

      expect(actual, matcher);
    });

    test('Unsorted intersected blocks will not join', () {
      const blocks = [
        FB(startLine: 3, endLine: 5, type: FBT.braces),
        FB(startLine: 8, endLine: 10, type: FBT.imports),
        FB(startLine: 1, endLine: 3, type: FBT.imports),
      ];

      final actual = blocks.deepCopy()..joinIntersecting();

      expect(actual, blocks);
    });

    test('Containing children blocks will not join', () {
      const blocks = [
        FB(startLine: 0, endLine: 6, type: FBT.braces),
        FB(startLine: 1, endLine: 3, type: FBT.parentheses),
        FB(startLine: 4, endLine: 5, type: FBT.parentheses),
        FB(startLine: 6, endLine: 12, type: FBT.braces),
        FB(startLine: 7, endLine: 9, type: FBT.parentheses),
        FB(startLine: 10, endLine: 11, type: FBT.parentheses),
      ];

      final actual = blocks.deepCopy()..joinIntersecting();

      expect(actual, blocks);
    });
  });
}

extension _FoldableBlockList on List<FoldableBlock> {
  List<FoldableBlock> deepCopy() {
    final result = List<FoldableBlock>.from(this);
    for (int i = 0; i < length; i++) {
      result[i] = this[i].copy();
    }
    return result;
  }
}
