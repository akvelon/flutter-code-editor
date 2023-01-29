import 'dart:ui';

import 'package:flutter_code_editor/flutter_code_editor.dart';

Issue issueFromJson(Map<String, dynamic> json) {
  final type = mapIssueType(json['kind']);
  return Issue(
    line: json['line'] - 1,
    message: json['message'],
    position: TextRange(
      start: json['charStart'],
      // ignore: avoid_dynamic_calls
      end: json['charStart'] + json['charLength'],
    ),
    type: type,
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
