// ignore_for_file: avoid_dynamic_calls
import 'dart:convert';

import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:http/http.dart' as http;

import 'json_converter.dart';

// Example for implementation of Analyzer for Dart
class DartAnalyzer extends Analyzer {
  @override
  Future<List<Issue>> analyze(Code code) async {
    final client = http.Client();

    final response = await client.post(
      Uri.https(
        'stable.api.dartpad.dev',
        '/api/dartservices/v2/analyze',
      ),
      body: json.encode({
        'source': code.text,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
      encoding: utf8,
    );
    final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

    if (decodedResponse['issues']?.length == 0 ||
        decodedResponse['issues'] == null) {
      return [];
    }

    final issues = <Issue>[];

    for (final issue in decodedResponse['issues']) {
      final instance = issueFromJson(issue);
      issues.add(instance);
    }
    return issues;
  }
}
