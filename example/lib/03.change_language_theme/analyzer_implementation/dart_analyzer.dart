// ignore_for_file: avoid_dynamic_calls
import 'dart:convert';

import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:http/http.dart' as http;

import 'json_converter.dart';

// Example for implementation of Analyzer for Dart.
class DartAnalyzer extends Analyzer {
  @override
  Future<AnalysisResult> analyze(Code code) async {
    final client = http.Client();
    const url = 'https:/stable.api.dartpad.dev/api/dartservices/v2/analyze';
    final response = await client.post(
      Uri.parse(url),
      body: json.encode({
        'source': code.text,
      }),
      encoding: utf8,
    );

    final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    final issueMaps = decodedResponse['issues'];

    if (issueMaps is! Iterable || (issueMaps.isEmpty)) {
      throw Exception(
        '[issues] field must be an iterable of Map<String, dynamic>',
      );
    }

    final issues = issueMaps
        .cast<Map<String, dynamic>>()
        .map(issueFromJson)
        .toList(growable: false);
    return AnalysisResult(issues: issues);
  }
}
