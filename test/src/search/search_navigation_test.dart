import 'package:flutter/cupertino.dart';
import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/create_app.dart';

void main() {
  group('SearchNavigationController', () {
    group(
        'Search advances the current match index '
        'to the first one that is after the selection '
        'and changes selection of a codeController.', () {
      const examples = [
        //
        _Example(
          'Selection is before all matches',
          text: 'Aa',
          //     \ initial selection
          //     \\ expected selection
          settings: SearchSettings(
            isCaseSensitive: false,
            isRegExp: false,
            pattern: 'a',
          ),
          selection: TextSelection.collapsed(offset: 0),
          expectedSelection: TextSelection(baseOffset: 0, extentOffset: 1),
          expectedCurrentMatchIndex: 0,
        ),

        _Example(
          'Selection is inbetween matches',
          text: 'AaBbAa',
          //        \ initial selection
          //         \\ expected selection
          settings: SearchSettings(
            isCaseSensitive: false,
            isRegExp: false,
            pattern: 'a',
          ),
          selection: TextSelection.collapsed(offset: 3),
          expectedSelection: TextSelection(baseOffset: 4, extentOffset: 5),
          expectedCurrentMatchIndex: 2,
        ),

        _Example(
          'Selection is after all matches',
          text: 'AaBbBb',
          //         \ initial selection
          //      \\ expected selection
          settings: SearchSettings(
            isCaseSensitive: false,
            isRegExp: false,
            pattern: 'a',
          ),
          selection: TextSelection.collapsed(offset: 4),
          expectedSelection: TextSelection(baseOffset: 1, extentOffset: 2),
          expectedCurrentMatchIndex: 1,
        ),
      ];

      for (final example in examples) {
        testWidgets(example.name, (wt) async {
          final codeController = await pumpController(wt, example.text);
          codeController.selection = example.selection;

          codeController.showSearch();

          codeController.searchController.settingsController.value =
              example.settings;

          expect(
            codeController
                .searchController.navigationController.value.currentMatchIndex,
            example.expectedCurrentMatchIndex,
            reason: example.name,
          );

          await wt.pump(const Duration(seconds: 10));
        });
      }
    });

    testWidgets(
        'Navigation to a match that is inside of a folded block '
        'unfolds the block', (wt) async {
      const text = '''
{
{
c
}
}
{
d
}''';
      final codeController = await pumpController(wt, text);
      codeController.foldAt(1);
      codeController.foldAt(0);
      codeController.foldAt(5);

      expect(codeController.text, isNot(contains('c')));

      codeController.showSearch();

      codeController.searchController.settingsController.value =
          const SearchSettings(
        isCaseSensitive: false,
        isRegExp: false,
        pattern: 'c',
      );

      final foldedBlocks = codeController.code.foldedBlocks.map(
        (block) => block.first,
      );

      expect(foldedBlocks, contains(5));
      expect(foldedBlocks, isNot(contains(0)));
      expect(foldedBlocks, isNot(contains(1)));

      await wt.pumpAndSettle();
    });

    testWidgets('moveNext()', (wt) async {
      const text = 'Aaa';
      final codeController = await pumpController(wt, text);
      codeController.selection = const TextSelection.collapsed(offset: 0);

      codeController.showSearch();

      final navigationController =
          codeController.searchController.navigationController;

      codeController.searchController.settingsController.value =
          const SearchSettings(
        isCaseSensitive: false,
        isRegExp: false,
        pattern: 'a',
      );

      expect(navigationController.value.currentMatchIndex, 0);
      expect(navigationController.value.totalMatchCount, 3);
      expect(
        codeController.selection,
        const TextSelection(baseOffset: 0, extentOffset: 1),
      );

      navigationController.moveNext();

      expect(navigationController.value.currentMatchIndex, 1);
      expect(navigationController.value.totalMatchCount, 3);
      expect(
        codeController.selection,
        const TextSelection(baseOffset: 1, extentOffset: 2),
      );

      navigationController.moveNext();

      expect(navigationController.value.currentMatchIndex, 2);
      expect(navigationController.value.totalMatchCount, 3);
      expect(
        codeController.selection,
        const TextSelection(baseOffset: 2, extentOffset: 3),
      );

      navigationController.moveNext();

      expect(navigationController.value.currentMatchIndex, 0);
      expect(navigationController.value.totalMatchCount, 3);
      expect(
        codeController.selection,
        const TextSelection(baseOffset: 0, extentOffset: 1),
      );

      await wt.pumpAndSettle();
    });

    testWidgets('movePrevious()', (wt) async {
      const text = 'Aaa';
      final codeController = await pumpController(wt, text);
      codeController.selection = const TextSelection.collapsed(offset: 0);

      codeController.showSearch();

      final navigationController =
          codeController.searchController.navigationController;

      codeController.searchController.settingsController.value =
          const SearchSettings(
        isCaseSensitive: false,
        isRegExp: false,
        pattern: 'a',
      );

      expect(navigationController.value.currentMatchIndex, 0);
      expect(navigationController.value.totalMatchCount, 3);
      expect(
        codeController.selection,
        const TextSelection(baseOffset: 0, extentOffset: 1),
      );

      navigationController.movePrevious();

      expect(navigationController.value.currentMatchIndex, 2);
      expect(navigationController.value.totalMatchCount, 3);
      expect(
        codeController.selection,
        const TextSelection(baseOffset: 2, extentOffset: 3),
      );

      navigationController.movePrevious();

      expect(navigationController.value.currentMatchIndex, 1);
      expect(navigationController.value.totalMatchCount, 3);
      expect(
        codeController.selection,
        const TextSelection(baseOffset: 1, extentOffset: 2),
      );

      navigationController.movePrevious();

      expect(navigationController.value.currentMatchIndex, 0);
      expect(navigationController.value.totalMatchCount, 3);
      expect(
        codeController.selection,
        const TextSelection(baseOffset: 0, extentOffset: 1),
      );

      await wt.pumpAndSettle();
    });

    testWidgets(
        'Changing CodeController with '
        'non-null current match', (wt) async {
      const text = 'Aa';
      final controller = await pumpController(wt, text);
      controller.selection = const TextSelection.collapsed(offset: 0);

      controller.showSearch();

      controller.searchController.settingsController.value =
          const SearchSettings(
        isCaseSensitive: false,
        isRegExp: false,
        pattern: 'a',
      );
      expect(
        controller
            .searchController.navigationController.value.currentMatchIndex,
        0,
      );

      controller.selection = const TextSelection.collapsed(offset: 1);
      expect(
        controller
            .searchController.navigationController.value.currentMatchIndex,
        0,
      );

      controller.insertStr('a');
      expect(
        controller
            .searchController.navigationController.value.currentMatchIndex,
        null,
      );
    });
  });
}

class _Example {
  final String name;
  final String text;
  final TextSelection selection;
  final SearchSettings settings;
  final int expectedCurrentMatchIndex;
  final TextSelection expectedSelection;

  const _Example(
    this.name, {
    required this.text,
    required this.settings,
    required this.selection,
    required this.expectedSelection,
    required this.expectedCurrentMatchIndex,
  });
}
