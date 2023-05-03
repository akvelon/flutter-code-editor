import 'package:flutter_code_editor/src/code/code.dart';
import 'package:flutter_code_editor/src/code_field/code_controller.dart';
import 'package:flutter_code_editor/src/search/controller.dart';
import 'package:flutter_code_editor/src/search/result.dart';
import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCodeController extends Mock implements CodeController {}

void main() {
  final codeController = _MockCodeController();

  setUp(() {
    when(() => codeController.code).thenReturn(Code.empty);
  });

  group('SearchController', () {
    test('enalbe/disable', () {
      final controller = CodeSearchController(
        codeController: codeController,
      );

      expect(controller.shouldShow, false);
      controller.showSearch();
      expect(controller.shouldShow, true);
      controller.hideSearch(returnFocusToCodeField: false);
      expect(controller.shouldShow, false);
    });

    test('Disabled controller returns empty result on search()', () {
      final controller = CodeSearchController(
        codeController: codeController,
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
    test('enable/disable', () {
      final controller = CodeController();

      controller.showSearch();
      expect(controller.searchController.shouldShow, true);

      controller.dismiss();
      expect(controller.searchController.shouldShow, false);
    });
  });
}
