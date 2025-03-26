import 'dart:convert';

import 'package:flutter_code_editor/flutter_code_editor.dart'
    show DartPadAnalyzer;
import 'package:flutter_code_editor/src/analyzer/models/analysis_result.dart'
    show AnalysisResult;
import 'package:flutter_code_editor/src/analyzer/models/issue.dart' show Issue;
import 'package:flutter_code_editor/src/analyzer/models/issue_type.dart'
    show IssueType;
import 'package:flutter_code_editor/src/code/code.dart' show Code;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../../mocks/general_mocks.mocks.dart' show MockClient;

void main() {
  group('DartPadAnalyzer', () {
    late MockClient mockClient;
    late DartPadAnalyzer analyzer;

    setUp(() {
      mockClient = MockClient();
      analyzer = DartPadAnalyzer(client: mockClient);
    });

    test('returns empty issues when response is empty or invalid', () async {
      when<Future<http.Response>>(
        mockClient.post(
          Uri.parse(DartPadAnalyzer.url),
          body: anyNamed('body'),
          encoding: anyNamed('encoding'),
        ),
      ).thenAnswer(
        (Invocation _) async => http.Response('{}', 200),
      );

      final AnalysisResult result = await analyzer.analyze(Code(text: ''));

      expect(result.issues, isEmpty);
    });

    test('parses issues correctly from response', () async {
      final Map<String, dynamic> mockResponse = <String, dynamic>{
        'issues': <Map<String, dynamic>>[
          <String, dynamic>{
            'line': 2,
            'message': 'Avoid using print',
            'kind': 'warning',
            'correction': 'Remove the print statement',
            'url': 'https://example.com/print',
          },
        ],
      };

      when<Future<http.Response>>(
        mockClient.post(
          Uri.parse(DartPadAnalyzer.url),
          body: anyNamed('body'),
          encoding: anyNamed('encoding'),
        ),
      ).thenAnswer(
        (Invocation _) async => http.Response(jsonEncode(mockResponse), 200),
      );

      final AnalysisResult result =
          await analyzer.analyze(Code(text: 'print("hi");'));

      expect(result.issues.length, 1);
      final Issue issue = result.issues.first;
      expect(issue.message, 'Avoid using print');
      expect(issue.type, IssueType.warning);
      expect(issue.line, 1); // 2 - 1
    });
  });
}
