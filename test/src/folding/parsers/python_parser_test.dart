import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/code/code_line_builder.dart';
import 'package:flutter_code_editor/src/folding/parsers/python.dart';
import 'package:flutter_code_editor/src/service_comment_filter/service_comment_filter.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comment_parser.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comments.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/python.dart';

void main() {
  group('Python. Foldable blocks', () {
    test('parses spaces', () {
      const examples = [
        _Example(
          'Python. Empty string',
          code: '',
          expected: [],
        ),
        //
        _Example(
          'Python. Nesting with multiline list',
          code: '''
class Mapping:
    def __init__(self, iterable):
        self.items_list = []
        self.__update(iterable)

    def update(self, iterable):
        for item in iterable:
            self.items_list.append(item)

        a = [
            5,
            6,
            7,
            8
        ]''',
          expected: [
            _FB(startLine: 0, endLine: 14, type: FoldableBlockType.indent),
            _FB(startLine: 1, endLine: 3, type: FoldableBlockType.indent),
            _FB(startLine: 5, endLine: 14, type: FoldableBlockType.indent),
            _FB(startLine: 6, endLine: 7, type: FoldableBlockType.indent),
            _FB(startLine: 9, endLine: 14, type: FoldableBlockType.brackets),
          ],
        ),
        //
        _Example(
          'Python. Invalid code',
          code: '''
class Mapping:
    def __init__(self, iterable)
        self.items_list = []
        self.__update(iterable)

    def update(self, iterable)
        for item in iterable
            self.items_list.append(item)

        a = [
            5,
            6,
            7,
            8
        ]''',
          expected: [
            _FB(startLine: 0, endLine: 14, type: FoldableBlockType.indent),
            _FB(startLine: 1, endLine: 3, type: FoldableBlockType.indent),
            _FB(startLine: 5, endLine: 14, type: FoldableBlockType.indent),
            _FB(startLine: 6, endLine: 7, type: FoldableBlockType.indent),
            _FB(startLine: 9, endLine: 14, type: FoldableBlockType.brackets),
          ],
        ),
        //
        _Example(
          'Python. Nesting list',
          code: '''
class Mapping:
    def __init__(self, iterable):
        a = [
            [
                5,
                6
            ],
            [
                7,
                8
            ]
        ]''',
          expected: [
            _FB(startLine: 0, endLine: 11, type: FoldableBlockType.indent),
            _FB(startLine: 1, endLine: 11, type: FoldableBlockType.indent),
            _FB(startLine: 2, endLine: 11, type: FoldableBlockType.brackets),
            _FB(startLine: 3, endLine: 6, type: FoldableBlockType.brackets),
            _FB(startLine: 7, endLine: 10, type: FoldableBlockType.brackets),
          ],
        ),
        //
        _Example(
          'Python. Single-line comments',
          code: '''
class Mapping:
    def __init__(self, iterable):
        a = [
            [
              # comment
              # another comment
              # third comment
                5,
                6
            ],
            [
                7,
                8
            ]
        ]''',
          expected: [
            _FB(startLine: 0, endLine: 14, type: FoldableBlockType.indent),
            _FB(startLine: 1, endLine: 14, type: FoldableBlockType.indent),
            _FB(startLine: 2, endLine: 14, type: FoldableBlockType.brackets),
            _FB(startLine: 3, endLine: 9, type: FoldableBlockType.brackets),
            _FB(
              startLine: 4,
              endLine: 6,
              type: FoldableBlockType.singleLineComment,
            ),
            _FB(startLine: 10, endLine: 13, type: FoldableBlockType.brackets),
          ],
        ),
        //
        _Example(
          'Python. Pair characters in literals are ignored',
          code: '''
a = "{[(";
b = ")]}";
''',
          expected: [],
        ),
        //
        _Example(
          'Python. Named comments',
          code: '''
class Mapping:
    def __init__(self, iterable):
        # [START section1]
        # [END section1]
        a = 5''',
          expected: [
            _FB(startLine: 0, endLine: 4, type: FoldableBlockType.indent),
            _FB(startLine: 1, endLine: 4, type: FoldableBlockType.indent),
          ],
        ),
      ];

      for (final example in examples) {
        highlight.registerLanguage('language', python);
        final highlighted = highlight.parse(example.code, language: 'language');

        final sequences = SingleLineComments.byMode[python] ?? [];

        final commentParser = SingleLineCommentParser.parseHighlighted(
          text: example.code,
          highlighted: highlighted,
          singleLineCommentSequences: sequences,
        );

        final serviceComments = ServiceCommentFilter.filter(
          commentParser.comments,
          namedSectionParser: const BracketsStartEndNamedSectionParser(),
        );

        final codeLines = CodeLineBuilder.textToCodeLines(
          text: example.code,
          highlighted: highlighted,
          commentsByLines: commentParser.getCommentsByLines(),
        );

        final pythonParser = PythonFoldableBlockParser().parse(highlighted,
            serviceComments.map((e) => e.source).toSet(), codeLines);

        expect(
          pythonParser,
          example.expected,
          reason: '${example.name}, valid blocks',
        );
      }
    });
  });
}

class _Example {
  final String name;
  final String code;
  final List<FoldableBlock> expected;

  const _Example(
    this.name, {
    required this.code,
    required this.expected,
  });
}

/// Shorter alias for [FoldableBlock] to avoid line breaks.
typedef _FB = FoldableBlock;

/// Shorter alias for [FoldableBlockType] to avoid line breaks.
typedef _T = FoldableBlockType;
