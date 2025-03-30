import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/search/match.dart';
import 'package:flutter_code_editor/src/search/result.dart';
import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/create_app.dart';

void main() {
  group('CodeController, Search-related functionality', () {
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

  /// Requested to add at {@link https://github.com/akvelon/flutter-code-editor/pull/231}
  group('CodeController-related formatting checks [Default params]', () {
    /// tests insertion of existing modifiers into the code controller
    /// at the defined index
    void testInsertionAtIndex(
      CodeController controller,
      String initialText,
      String insertedStart,
      String insertedEnd,
      int insertionIndex,
    ) {
      final selection = TextSelection(
        baseOffset: insertionIndex,
        extentOffset: insertionIndex,
      );
      // to move selection of textEditingValue at defined place
      controller.value = TextEditingValue(
        text: initialText,
        selection: selection,
      );

      final textWithInsertedStart = initialText.replaceRange(
        insertionIndex,
        insertionIndex,
        insertedStart,
      );
      controller.value = TextEditingValue(
        text: textWithInsertedStart,
        selection: selection,
      );

      final expectedText = initialText.replaceRange(
        insertionIndex,
        insertionIndex,
        '$insertedStart$insertedEnd',
      );
      expect(controller.value.text, expectedText);
    }

    /// tests insertion at the start, middle and end of the initial text
    Future<void> testInsertion(
      WidgetTester wt,
      String insertedStart, {
      String? insertedEnd,
    }) async {
      insertedEnd ??= insertedStart;

      const initialText = 'Hello';
      final controller = await pumpController(wt, initialText);

      testInsertionAtIndex(
        controller,
        initialText,
        insertedStart,
        insertedEnd,
        0,
      );
      testInsertionAtIndex(
        controller,
        initialText,
        insertedStart,
        insertedEnd,
        2,
      );
      testInsertionAtIndex(
        controller,
        initialText,
        insertedStart,
        insertedEnd,
        initialText.length,
      );
    }

    testWidgets('controller handles insertion of backticks', (wt) async {
      await testInsertion(wt, '`');
    });

    testWidgets('controller handles insertion of single quotes', (wt) async {
      await testInsertion(wt, '\'');
    });

    testWidgets('controller handles insertion of double quotes', (wt) async {
      await testInsertion(wt, '"');
    });

    testWidgets('controller handles insertion of parentheses', (wt) async {
      await testInsertion(wt, '(', insertedEnd: ')');
    });

    testWidgets('controller handles insertion of braces', (wt) async {
      await testInsertion(wt, '{', insertedEnd: '}');
    });

    testWidgets('controller handles insertion of square brackets', (wt) async {
      await testInsertion(wt, '[', insertedEnd: ']');
    });
  });
}
