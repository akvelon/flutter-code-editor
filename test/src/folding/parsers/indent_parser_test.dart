import 'package:flutter_code_editor/src/code/code_lines_builder.dart';
import 'package:flutter_code_editor/src/folding/foldable_block.dart';
import 'package:flutter_code_editor/src/folding/foldable_block_type.dart';
import 'package:flutter_code_editor/src/folding/parsers/indent.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comment_parser.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comments.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/python.dart';

void main() {
  group('IndentFoldableBlockParser', () {
    test('parses indents', () {
      const examples = [
        //
        _Example(
          'Python. Empty text',
          code: '',
          expected: [],
        ),

        _Example(
          'Python. One nesting',
          code: '''
class Mapping:
    def __init__(self, iterable):
        self.items_list = []
        self.__update(iterable)''',
          expected: [
            _FB(startLine: 0, endLine: 3, type: _T.indent),
            _FB(startLine: 1, endLine: 3, type: _T.indent),
          ],
        ),

        _Example(
          'Python. Several nesting with one space indent',
          code: '''
class Mapping:
 def __init__(self, iterable):
  self.items_list = []
  self.__update(iterable)

 def update(self, iterable):
  for item in iterable:
   self.items_list.append(item)''',
          expected: [
            _FB(startLine: 0, endLine: 7, type: _T.indent),
            _FB(startLine: 1, endLine: 3, type: _T.indent),
            _FB(startLine: 5, endLine: 7, type: _T.indent),
            _FB(startLine: 6, endLine: 7, type: _T.indent),
          ],
        ),

        _Example(
          'Python. Several separators at the mid',
          code: '''
class Mapping:

    def __init__(self, iterable):

        self.items_list = []

        self.__update(iterable)


    def update(self, iterable):


        for item in iterable:

            self.items_list.append(item)''',
          expected: [
            _FB(startLine: 0, endLine: 14, type: _T.indent),
            _FB(startLine: 2, endLine: 6, type: _T.indent),
            _FB(startLine: 9, endLine: 14, type: _T.indent),
            _FB(startLine: 12, endLine: 14, type: _T.indent),
          ],
        ),

        _Example(
          'Python. Several separators at start and end',
          code: '''


class Mapping:
    def __init__(self, iterable):
        self.items_list = []
        self.__update(iterable)

    def update(self, iterable):
        for item in iterable:
            self.items_list.append(item)
            
            
''',
          expected: [
            _FB(startLine: 2, endLine: 9, type: _T.indent),
            _FB(startLine: 3, endLine: 5, type: _T.indent),
            _FB(startLine: 7, endLine: 9, type: _T.indent),
            _FB(startLine: 8, endLine: 9, type: _T.indent),
          ],
        ),

        _Example(
          'Python. Without separator lines',
          code: '''
class Mapping:
    def __init__(self, iterable):
        self.items_list = []
        self.__update(iterable)
class Foo:
    def update(self, iterable):
        for item in iterable:
            self.items_list.append(item)''',
          expected: [
            _FB(startLine: 0, endLine: 3, type: _T.indent),
            _FB(startLine: 1, endLine: 3, type: _T.indent),
            _FB(startLine: 4, endLine: 7, type: _T.indent),
            _FB(startLine: 5, endLine: 7, type: _T.indent),
            _FB(startLine: 6, endLine: 7, type: _T.indent),
          ],
        ),

        _Example(
          'Python. Invalid indent',
          code: '''
class Mapping:
    def __init__(self, iterable):
        self.items_list = []
        self.__update(iterable)
     def update(self, iterable):
         for item in iterable:
        self.items_list.append(item)''',
          expected: [
            _FB(startLine: 0, endLine: 6, type: _T.indent),
            _FB(startLine: 1, endLine: 6, type: _T.indent),
            _FB(startLine: 4, endLine: 6, type: _T.indent),
          ],
        ),

        _Example(
          'Python. Different indents',
          code: '''
class Mapping:                                # 0
 def __init__(self, iterable):                # 1
        self.items_list = []                  # 2
        self.__update(iterable)               # 3

 def update(self, iterable):                  # 5
      for item in iterable:                   # 6
        self.items_list.append(item)          # 7''',
          expected: [
            _FB(startLine: 0, endLine: 7, type: _T.indent),
            _FB(startLine: 1, endLine: 3, type: _T.indent),
            _FB(startLine: 5, endLine: 7, type: _T.indent),
            _FB(startLine: 6, endLine: 7, type: _T.indent),
          ],
        ),

        _Example(
          'Python. Multiline list',
          code: '''
numbers = [1, 
    2, 
    3, 
    4, 
    5
]''',
          expected: [_FB(startLine: 0, endLine: 4, type: _T.indent)],
        )
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

        final codeLines = CodeLinesBuilder.textToCodeLines(
          text: example.code,
          readonlyCommentsByLine: commentParser.getIfReadonlyCommentByLine(),
        );

        final parser = IndentFoldableBlockParser();
        parser.parse(lines: codeLines);
        expect(
          parser.blocks,
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
