// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: prefer_const_constructors

import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/src/code_field/text_selection.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_ranges.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

const affinities = [TextAffinity.upstream, TextAffinity.downstream];

void main() {
  group('HiddenRanges. cutSelection, recoverSelection', () {
    test('No ranges - No changes', () {
      const selections = [
        TextSelection.collapsed(offset: -1),
        TextSelection.collapsed(offset: 0),
        TextSelection(
          baseOffset: 5,
          extentOffset: 10,
          affinity: TextAffinity.downstream,
          isDirectional: true,
        ),
        TextSelection(
          baseOffset: 5,
          extentOffset: 10,
          affinity: TextAffinity.upstream,
          isDirectional: true,
        ),
        TextSelection(
          baseOffset: 5,
          extentOffset: 10,
          affinity: TextAffinity.downstream,
          isDirectional: false,
        ),
        TextSelection(
          baseOffset: 5,
          extentOffset: 10,
          affinity: TextAffinity.upstream,
          isDirectional: false,
        ),
      ];

      for (final selection in selections) {
        expect(
          HiddenRanges.empty.cutSelection(selection),
          selection,
        );
        expect(
          HiddenRanges.empty.cutSelection(selection.reversed),
          selection.reversed,
        );

        expect(
          HiddenRanges.empty.recoverSelection(selection),
          selection,
        );
        expect(
          HiddenRanges.empty.recoverSelection(selection.reversed),
          selection.reversed,
        );
      }
    });

    test('With visible beginning and end', () {
      const examples = [
        //
        _Example.nonDestructive(
          'Collapsed before ranges',
          full: TextRange.empty,
          cut: TextRange.empty,
        ),

        _Example.nonDestructive(
          'Collapsed before ranges',
          full: TextRange.collapsed(7),
          cut: TextRange.collapsed(7),
        ),

        _Example.nonDestructive(
          'Collapsed at a hidden range collapse point',
          full: TextRange.collapsed(7),
          cut: TextRange.collapsed(7),
        ),

        _Example.transit(
          'Collapsed at a hidden range collapse point',
          full: TextRange.collapsed(32),
          cut: TextRange.collapsed(28),
          recovered: TextRange.collapsed(31),
        ),

        _Example.nonDestructive(
          'Collapsed after ranges',
          full: TextRange.collapsed(124),
          cut: TextRange.collapsed(70),
        ),

        _Example.nonDestructive(
          'Spanning. Before ranges',
          full: TextRange(start: 5, end: 10),
          cut: TextRange(start: 5, end: 10),
        ),

        _Example.nonDestructive(
          'Spanning. After ranges',
          full: TextRange(start: 124, end: 134),
          cut: TextRange(start: 70, end: 80),
        ),

        _Example.nonDestructive(
          'Spanning across 2 ranges',
          full: TextRange(start: 15, end: 60),
          cut: TextRange(start: 15, end: 46),
        ),

        _Example.transit(
          'Spanning between visible and hidden',
          full: TextRange(start: 50, end: 70),
          cut: TextRange(start: 36, end: 53),
          recovered: TextRange(start: 50, end: 67),
        ),
      ];

      for (final e in examples) {
        for (final affinity in affinities) {
          for (final isDirectional in [true, false]) {
            if (e.cutInput != null || e.cutExpected != null) {
              final full = TextSelection(
                baseOffset: e.cutInput!.start,
                extentOffset: e.cutInput!.end,
                affinity: affinity,
                isDirectional: isDirectional,
              );
              final out = TextSelection(
                baseOffset: e.cutExpected!.start,
                extentOffset: e.cutExpected!.end,
                affinity: affinity,
                isDirectional: isDirectional,
              );

              expect(hiddenRanges.cutSelection(full), out);
              expect(hiddenRanges.cutSelection(full.reversed), out.reversed);
            }

            if (e.recoverInput != null || e.recoverExpected != null) {
              final cut = TextSelection(
                baseOffset: e.recoverInput!.start,
                extentOffset: e.recoverInput!.end,
                affinity: affinity,
                isDirectional: isDirectional,
              );
              final out = TextSelection(
                baseOffset: e.recoverExpected!.start,
                extentOffset: e.recoverExpected!.end,
                affinity: affinity,
                isDirectional: isDirectional,
              );

              expect(hiddenRanges.recoverSelection(cut), out);
              expect(hiddenRanges.recoverSelection(cut.reversed), out.reversed);
            }
          }
        }
      }
    });
  });
}

class _Example {
  final String name;
  final TextRange? cutInput;
  final TextRange? cutExpected;
  final TextRange? recoverInput;
  final TextRange? recoverExpected;

  const _Example.nonDestructive(
    this.name, {
    required TextRange full,
    required TextRange cut,
  })  : cutInput = full,
        cutExpected = cut,
        recoverInput = cut,
        recoverExpected = full;

  const _Example.transit(
    this.name, {
    required TextRange full,
    required TextRange cut,
    required TextRange recovered,
  })  : cutInput = full,
        cutExpected = cut,
        recoverInput = cut,
        recoverExpected = recovered;
}
