import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/analyzer/impl/default_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:mocktail/mocktail.dart';

class TestAnalyzer extends Mock implements Analyzer {}

void main() {
  group('CodeController.analyzer', () {
    late TestAnalyzer analyzer;

    setUp(() {
      analyzer = TestAnalyzer();
      registerFallbackValue(Code.empty);
      // ignore: discarded_futures
      when(() => analyzer.analyze(any()))
          .thenAnswer((_) async => const AnalysisResult(issues: []));
    });

    test('Reset analyzer sets analyzer to default', () async {
      final controller = CodeController(
        analyzer: analyzer,
      );

      expect(controller.analyzer.runtimeType, TestAnalyzer);

      controller.resetAnalyzer();

      expect(controller.analyzer.runtimeType, DefaultAnalyzer);
    });

    test('Passing an analyzer to the controller with the language', () {
      final controller = CodeController(
        analyzer: analyzer,
        language: java,
      );

      expect(controller.analyzer.runtimeType, TestAnalyzer);
    });

    test('Setting a language changes analyzer to Default analyzer', () {
      final controller = CodeController(
        analyzer: analyzer,
        language: java,
      );

      expect(controller.analyzer.runtimeType, TestAnalyzer);

      controller.language = python;

      expect(controller.analyzer.runtimeType, DefaultAnalyzer);
    });

    test('Set analyzer calls analyze method', () async {
      final controller = CodeController(
        language: java,
      );

      controller.analyzer = analyzer;

      expect(controller.analyzer.runtimeType, TestAnalyzer);
      await Future.delayed(const Duration(seconds: 1));
      verify(() => analyzer.analyze(any())).called(greaterThan(0));
    });

    test('Set language with analyzer', () {
      final controller = CodeController();

      controller.setLanguageWithAnalyzer(java, analyzer);

      expect(controller.language, java);
      expect(controller.analyzer.runtimeType, TestAnalyzer);
    });
  });
}
