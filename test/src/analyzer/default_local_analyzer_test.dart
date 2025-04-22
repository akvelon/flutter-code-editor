import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

class TestCode implements Code {
  final Code _inner;
  final List<InvalidFoldableBlock> _mockedInvalidBlocks;

  TestCode({
    required String text,
    required List<InvalidFoldableBlock> mockedInvalidBlocks,
  })  : _mockedInvalidBlocks = mockedInvalidBlocks,
        _inner = Code(text: text); // use the factory constructor

  @override
  List<InvalidFoldableBlock> get invalidBlocks => _mockedInvalidBlocks;

  // Forward everything else to the inner Code instance.
  @override
  dynamic noSuchMethod(Invocation invocation) => Function.apply(
        _inner.noSuchMethod,
        <dynamic>[invocation],
      );
}

void main() {
  group('DefaultLocalAnalyzer', () {
    test('returns issues from overridden invalidBlocks', () async {
      final InvalidFoldableBlock block1 = InvalidFoldableBlock(
        type: FoldableBlockType.braces,
        startLine: 1,
      );

      final InvalidFoldableBlock block2 = InvalidFoldableBlock(
        type: FoldableBlockType.brackets,
        endLine: 3,
      );

      final TestCode code = TestCode(
        text: 'fake',
        mockedInvalidBlocks: <InvalidFoldableBlock>[block1, block2],
      );

      const DefaultLocalAnalyzer analyzer = DefaultLocalAnalyzer();
      final AnalysisResult result = await analyzer.analyze(code);

      expect(result.issues.length, 2);
      expect(result.issues[0], equals(block1.issue));
      expect(result.issues[1].line, equals(3));
    });

    test('returns empty issues when invalidBlocks is empty', () async {
      final TestCode code = TestCode(
        text: 'clean',
        mockedInvalidBlocks: <InvalidFoldableBlock>[],
      );

      const DefaultLocalAnalyzer analyzer = DefaultLocalAnalyzer();
      final AnalysisResult result = await analyzer.analyze(code);

      expect(result.issues, isEmpty);
    });
  });
}
