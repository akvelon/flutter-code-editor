// ignore_for_file: avoid_dynamic_calls

import 'package:flutter_code_editor/flutter_code_editor.dart';

// Converts json to Issue object for the DartAnalyzer.
Issue issueFromJson(Map<String, dynamic> json) {
  final type = mapIssueType(json['kind']);
  return Issue(
    line: json['line'] - 1,
    message: json['message'],
    suggestion: json['correction'],
    type: type,
    url: json['url'],
  );
}

IssueType mapIssueType(String type) {
  switch (type) {
    case 'error':
      return IssueType.error;
    case 'warning':
      return IssueType.warning;
    case 'info':
      return IssueType.info;
    default:
      return IssueType.warning;
  }
}
