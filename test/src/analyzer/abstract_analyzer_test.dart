import 'package:flutter_code_editor/flutter_code_editor.dart'
    show AbstractAnalyzer;
import 'package:flutter_code_editor/src/analyzer/models/analysis_result.dart'
    show AnalysisResult;
import 'package:flutter_code_editor/src/analyzer/models/issue.dart' show Issue;
import 'package:flutter_code_editor/src/code/code.dart' show Code;
import 'package:flutter_test/flutter_test.dart';

class DummyAnalyzer extends AbstractAnalyzer {
  const DummyAnalyzer();

  @override
  Future<AnalysisResult> analyze(Code code) async {
    return const AnalysisResult(issues: <Issue>[]);
  }
}

void main() {
  group('AbstractAnalyzer', () {
    test('dispose() can be called safely', () {
      const DummyAnalyzer analyzer = DummyAnalyzer();
      analyzer.dispose();
    });

    test('analyze() should return AnalysisResult with no issues', () async {
      const DummyAnalyzer analyzer = DummyAnalyzer();
      final AnalysisResult result = await analyzer.analyze(Code(text: ''));
      expect(result, isA<AnalysisResult>());
      expect(result.issues, isEmpty);
    });
  });
}
