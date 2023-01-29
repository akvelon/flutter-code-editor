import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

import 'json_converter.dart';

class AnalyzerImpl extends Analyzer {
  @override
  Future<List<Issue>> analyze(Code code) async {
    final client = Dio();
    const path = 'https://stable.api.dartpad.dev/api/dartservices/v2/analyze';

    client.options.headers.addAll(
      {
        'Content-Type': 'application/json',
      },
    );

    final response = await client.post(
      path,
      data: {
        'source': code.text,
      },
    );

    if (response.data['issues']?.length == 0 ||
        response.data['issues'] == null) {
      return [];
    }

    // ignore: avoid_dynamic_calls
    final issues = <Issue>[];

    for (final issue in response.data['issues']) {
      final instance = issueFromJson(issue);
      issues.add(instance);
    }
    print('Analyze');
    return issues;
  }
}
