import 'package:flutter_code_editor/flutter_code_editor.dart' show Issue;
import 'package:flutter_code_editor/src/analyzer/models/issue.dart'
    show issueLineComparator;
import 'package:flutter_code_editor/src/analyzer/models/issue_type.dart'
    show IssueType;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Issue Model Tests',
    () {
      test(
        'should create an Issue with required fields',
        () {
          const Issue issue = Issue(
            line: 5,
            message: 'Unexpected semicolon',
            type: IssueType.warning,
          );

          expect(issue.line, 5);
          expect(issue.message, 'Unexpected semicolon');
          expect(issue.type, IssueType.warning);
          expect(issue.suggestion, isNull);
          expect(issue.url, isNull);
        },
      );

      test(
        'should create an Issue with all fields',
        () {
          const Issue issue = Issue(
            line: 10,
            message: 'Missing return type',
            type: IssueType.error,
            suggestion: 'Add a return type',
            url: 'https://example.com/return-type',
          );

          expect(issue.line, 10);
          expect(issue.message, 'Missing return type');
          expect(issue.type, IssueType.error);
          expect(issue.suggestion, 'Add a return type');
          expect(issue.url, 'https://example.com/return-type');
        },
      );
    },
  );

  group(
    'issueLineComparator',
    () {
      test(
        'should compare issues by line number',
        () {
          const Issue issue1 =
              Issue(line: 3, message: '', type: IssueType.info);
          const Issue issue2 =
              Issue(line: 5, message: '', type: IssueType.info);
          const Issue issue3 =
              Issue(line: 1, message: '', type: IssueType.info);

          final List<Issue> issues = <Issue>[issue1, issue2, issue3];
          issues.sort(issueLineComparator);

          expect(issues[0].line, 1);
          expect(issues[1].line, 3);
          expect(issues[2].line, 5);
        },
      );
    },
  );
}
