import 'dart:core';

import 'issue_type.dart';

class Issue {
  final int line;
  final String message;
  final IssueType type;
  final String? suggestion;
  final String? url;

  const Issue({
    required this.line,
    required this.message,
    required this.type,
    this.suggestion,
    this.url,
  });
}

Comparator<Issue> issueLineComparator = (Issue issue1, Issue issue2) {
  return issue1.line - issue2.line;
};
