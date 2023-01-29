import 'package:flutter/material.dart';

import 'issue_type.dart';

class Issue implements Comparable<Issue> {
  final int line;
  final String message;
  final TextRange position;
  final IssueType type;
  final String? suggestion;
  final String? url;

  const Issue({
    required this.line,
    required this.message,
    required this.position,
    required this.type,
    this.suggestion,
    this.url,
  });

  @override
  int compareTo(Issue other) {
    if (line > other.line) return 1;
    if (line == other.line) return 0;
    return -1;
  }
}
