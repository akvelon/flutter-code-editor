import 'package:flutter_code_editor/src/code/code.dart';
import 'package:flutter_code_editor/src/code_field/code_controller.dart';
import 'package:flutter_code_editor/src/search/controller.dart';
import 'package:flutter_code_editor/src/search/result.dart';
import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_code_editor/src/search/widget/search_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/create_app.dart';

void main() {
  group('CodeSearchController', () {
    test('showSearch(), hideSearch()', () {
      final controller = CodeSearchController(
        codeController: CodeController(),
      );

      expect(controller.shouldShow, false);
      controller.showSearch();
      expect(controller.shouldShow, true);
      controller.hideSearch(returnFocusToCodeField: false);
      expect(controller.shouldShow, false);
    });

    test('Disabled controller returns empty result on search()', () {
      final controller = CodeSearchController(
        codeController: CodeController(),
      );

      final result = controller.search(
        Code(text: 'aaa'),
        settings: const SearchSettings(
          isCaseSensitive: false,
          isRegExp: false,
          pattern: 'a',
        ),
      );

      expect(result, SearchResult.empty);
    });
  });

  group('CodeController', () {
    testWidgets('showSearch(), dismiss()', (wt) async {
      const text = '';
      final controller = await pumpController(wt, text);
      await wt.pumpAndSettle();

      expect(controller.searchController.shouldShow, false);
      expect(find.byType(SearchWidget), findsNothing);

      controller.showSearch();
      await wt.pumpAndSettle();

      expect(controller.searchController.shouldShow, true);
      expect(
        find.byType(SearchWidget),
        findsOneWidget,
      );

      controller.dismiss();
      await wt.pumpAndSettle();

      expect(controller.searchController.shouldShow, false);
      expect(
        find.byType(SearchWidget),
        findsNothing,
      );
    });
  });
}
