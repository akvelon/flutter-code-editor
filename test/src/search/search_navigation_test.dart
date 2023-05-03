import 'package:flutter/cupertino.dart';
import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/create_app.dart';

void main() {
  group('SearchNavigationController', () {
    group(
        'Search advances the current match index '
        'to the first one that is after the selection ', () {
      const examples = [
        //
        _Example(
          'All matches are after selection',
          text: 'Aa',
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
          'All matches are before selection',
          text: 'AaBbBb',
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
          final controller = await pumpController(wt, example.text);
          controller.selection = example.selection;

          controller.showSearch();

          controller.searchController.settingsController.value =
              example.settings;

          expect(
            controller
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
{
{
c
}
}
}
}''';
      final controller = await pumpController(wt, text);
      controller.foldAt(0);
      controller.foldAt(1);
      controller.foldAt(2);
      controller.foldAt(3);

      expect(controller.text, '{');

      controller.showSearch();

      controller.searchController.settingsController.value =
          const SearchSettings(
        isCaseSensitive: false,
        isRegExp: false,
        pattern: 'c',
      );

      expect(controller.text, text);
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
