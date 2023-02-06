import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:mocktail/mocktail.dart';

class TestAnalyzer extends Mock implements Analyzer {}

void main() {
  group('CodeController.analyzer', () {
    late TestAnalyzer testAnalyzer;
    late DefaultLocalAnalyzer defaultAnalyzer;

    setUp(() {
      defaultAnalyzer = const DefaultLocalAnalyzer();
      testAnalyzer = TestAnalyzer();

      registerFallbackValue(Code.empty);
      // ignore: discarded_futures
      when(() => testAnalyzer.analyze(any())).thenAnswer(
        (_) async => const AnalysisResult(
          issues: [],
          analyzedCode: Code.empty,
        ),
      );
    });

    test('Set analyzer to Default Analyzer', () async {
      final controller = CodeController(
        analyzer: testAnalyzer,
      );

      expect(controller.analyzer, same(testAnalyzer));

      controller.analyzer = defaultAnalyzer;

      expect(controller.analyzer, same(defaultAnalyzer));
    });

    test('Passing an analyzer to the controller with the language', () {
      final controller = CodeController(
        analyzer: testAnalyzer,
        language: java,
      );

      expect(controller.analyzer, same(testAnalyzer));
    });

    test('Setting a language changes analyzer to Default analyzer', () {
      final controller = CodeController(
        analyzer: testAnalyzer,
        language: java,
      );

      expect(controller.analyzer, same(testAnalyzer));

      controller.language = python;

      expect(controller.analyzer.runtimeType, DefaultLocalAnalyzer);
    });

    test('Set analyzer calls analyze method', () async {
      final controller = CodeController(
        language: java,
      );

      controller.analyzer = testAnalyzer;

      expect(controller.analyzer, same(testAnalyzer));
      await Future.delayed(const Duration(seconds: 1));
      verify(() => testAnalyzer.analyze(any())).called(1);
    });

    test('Set language with analyzer', () {
      final controller = CodeController();

      controller.setLanguage(java, analyzer: testAnalyzer);

      expect(controller.language, java);
      expect(controller.analyzer, same(testAnalyzer));
    });
  });
}
