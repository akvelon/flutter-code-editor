import 'package:flutter_code_editor/flutter_code_editor.dart' show Issue;
import 'package:flutter_code_editor/src/analyzer/models/analysis_result.dart'
    show AnalysisResult;
import 'package:flutter_code_editor/src/analyzer/models/issue_type.dart'
    show IssueType;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalysisResult', () {
    test('should create an AnalysisResult with a list of issues', () {
      final List<Issue> issues = <Issue>[
        const Issue(line: 1, message: 'Test', type: IssueType.info),
      ];

      final AnalysisResult result = AnalysisResult(issues: issues);

      expect(result.issues, hasLength(1));
      expect(result.issues.first.message, 'Test');
    });
  });
}
