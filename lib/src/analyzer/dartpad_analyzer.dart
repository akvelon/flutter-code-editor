import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../code/code.dart';
import 'abstract.dart';
import 'models/analysis_result.dart';
import 'models/issue.dart';
import 'models/issue_type.dart';

// Example for implementation of Analyzer for Dart.
class DartPadAnalyzer extends AbstractAnalyzer {
  @visibleForTesting
  static const String url =
      'https://stable.api.dartpad.dev/api/dartservices/v2/analyze';

  final http.Client client;

  DartPadAnalyzer({http.Client? client}) : client = client ?? http.Client();

  @override
  Future<AnalysisResult> analyze(Code code) async {
    final http.Response response = await client.post(
      Uri.parse(url),
      body: json.encode(<String, String>{'source': code.text}),
      encoding: utf8,
    );

    final Map<String, dynamic> decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final dynamic issueMaps = decodedResponse['issues'];

    if (issueMaps is! Iterable<dynamic> || (issueMaps.isEmpty)) {
      return const AnalysisResult(issues: <Issue>[]);
    }

    final List<Issue> issues = issueMaps
        .cast<Map<String, dynamic>>()
        .map<Issue>(issueFromJson)
        .toList(growable: false);

    return AnalysisResult(issues: issues);
  }
}

// Converts json to Issue object for the DartAnalyzer.
Issue issueFromJson(Map<String, dynamic> json) {
  final IssueType type = mapIssueType(json['kind']);
  final int line = json['line'];
  return Issue(
    line: line - 1,
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
