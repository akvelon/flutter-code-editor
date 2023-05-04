import 'package:flutter/services.dart';
import 'package:flutter_code_editor/src/search/match.dart';
import 'package:flutter_code_editor/src/search/result.dart';
import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/create_app.dart';

void main() {
  group('CodeController', () {
    testWidgets('CTRL + F shows search, Escape hides', (wt) async {
      const text = 'AaAa';
      final controller = await pumpController(wt, text);

      expect(controller.searchController.shouldShow, false);

      await wt.sendKeyDownEvent(LogicalKeyboardKey.control);
      await wt.sendKeyEvent(LogicalKeyboardKey.keyF);
      await wt.sendKeyUpEvent(LogicalKeyboardKey.control);

      expect(controller.searchController.shouldShow, true);

      await wt.sendKeyEvent(LogicalKeyboardKey.escape);

      expect(controller.searchController.shouldShow, false);
    });

    testWidgets('Change generates new search result', (wt) async {
      const settings = SearchSettings(
        isCaseSensitive: true,
        isRegExp: false,
        pattern: 'a',
      );
      const initialText = 'Aa';
      const initialResult = SearchResult(
        matches: [
          SearchMatch(start: 1, end: 2),
        ],
      );

      const changedText = 'Aaa';
      const resultAfterChange = SearchResult(
        matches: [
          SearchMatch(start: 1, end: 2),
          SearchMatch(start: 2, end: 3),
        ],
      );

      final controller = await pumpController(wt, initialText);

      controller.showSearch();
      controller.searchController.settingsController.value = settings;

      expect(controller.fullSearchResult, initialResult);

      controller.value = const TextEditingValue(text: changedText);

      expect(controller.fullSearchResult, resultAfterChange);

      await wt.pumpAndSettle();
    });
  });
}
