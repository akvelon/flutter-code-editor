import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:mocktail/mocktail.dart';

class TestAnalyzer extends Mock implements AbstractAnalyzer {}

void main() {
  group('CodeController.analyzer', () {
    TestAnalyzer testAnalyzer = TestAnalyzer();

    setUp(() {
      testAnalyzer = TestAnalyzer();

      registerFallbackValue(Code.empty);
      // ignore: discarded_futures
      when(() => testAnalyzer.analyze(any())).thenAnswer(
        (_) async => const AnalysisResult(issues: []),
      );
    });

    test('Initialize', () async {
      final languages = [null, java];
      final analyzers = [testAnalyzer, testAnalyzer];

      for (int i = 0; i < languages.length; i++) {
        final controller =
            CodeController(language: languages[i], analyzer: analyzers[i]);

        expect(controller.analyzer, same(analyzers[i]));
        expect(controller.language, same(languages[i]));

        verify(() => testAnalyzer.analyze(any())).called(1);
      }

      final controller = CodeController(language: java);
      expect(controller.analyzer.runtimeType, DefaultLocalAnalyzer);
    });

    test('Change with set analyzer', () async {
      final languages = [null, java];

      for (final language in languages) {
        final controller = CodeController(language: language);
        expect(controller.analyzer.runtimeType, DefaultLocalAnalyzer);

        controller.analyzer = testAnalyzer;
        expect(controller.analyzer, same(testAnalyzer));
        verify(() => testAnalyzer.analyze(any())).called(1);
      }
    });

    test('Change with setLanguage', () async {
      final languages = [null, java];
      final changedLanguage = python;

      for (final language in languages) {
        final controller = CodeController(language: language);
        expect(controller.analyzer.runtimeType, DefaultLocalAnalyzer);

        controller.setLanguage(changedLanguage, analyzer: testAnalyzer);
        expect(controller.language, changedLanguage);
        expect(controller.analyzer, same(testAnalyzer));
        verify(() => testAnalyzer.analyze(any())).called(1);
      }
    });

    test('Set language resets analyzer', () {
      final languages = [python, null];
      for (final language in languages) {
        final controller =
            CodeController(language: java, analyzer: testAnalyzer);
        expect(controller.analyzer, same(testAnalyzer));

        controller.language = language;
        expect(controller.analyzer.runtimeType, DefaultLocalAnalyzer);
      }
    });
  });
}
