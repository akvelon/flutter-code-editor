import 'package:flutter_code_editor/src/code/code_lines_builder.dart';
import 'package:flutter_code_editor/src/folding/foldable_block.dart';
import 'package:flutter_code_editor/src/folding/foldable_block_type.dart';
import 'package:flutter_code_editor/src/folding/parsers/python.dart';
import 'package:flutter_code_editor/src/named_sections/parsers/brackets_start_end.dart';
import 'package:flutter_code_editor/src/service_comment_filter/service_comment_filter.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comment_parser.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comments.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/python.dart';

void main() {
  group('Python. Foldable blocks', () {
    test('parses spaces', () {
      const examples = [
        //
        _Example(
          'Python. Empty string',
          code: '',
          expected: [],
        ),

        _Example(
          'Python. Nesting with multiline list',
          code: '''
class Mapping:                      # 0
 def __init__(self, iterable):      # 1
  self.items_list = []              # 2
  self.__update(iterable)           # 3

 def update(self, iterable):        # 5
  for item in iterable:             # 6
    self.items_list.append(item)    # 7

  a = [                             # 9
       5,                           # 10
       6,                           # 11
       7,                           # 12
       8                            # 13
  ]                                 # 14''',
          expected: [
            _FB(firstLine: 0, lastLine: 14, type: _T.indent),
            _FB(firstLine: 1, lastLine: 3, type: _T.indent),
            _FB(firstLine: 5, lastLine: 14, type: _T.indent),
            _FB(firstLine: 6, lastLine: 7, type: _T.indent),
            _FB(firstLine: 9, lastLine: 14, type: _T.brackets),
          ],
        ),

        _Example(
          '''Python. Invalid code. Removed ':' symbols''',
          code: '''
class Mapping:                                   # 0
    def __init__(self, iterable)                 # 1
        self.items_list = []                     # 2
        self.__update(iterable)                  # 3

    def update(self, iterable)                   # 5
        for item in iterable                     # 6
            self.items_list.append(item)         # 7

        a = [                                    # 9 
            5,                                   # 10
            6,                                   # 11
            7,                                   # 12
            8,
        ]                                        # 14''',
          expected: [
            _FB(firstLine: 0, lastLine: 14, type: _T.indent),
            _FB(firstLine: 1, lastLine: 3, type: _T.indent),
            _FB(firstLine: 5, lastLine: 14, type: _T.indent),
            _FB(firstLine: 6, lastLine: 7, type: _T.indent),
            _FB(firstLine: 9, lastLine: 14, type: _T.brackets),
          ],
        ),

        _Example(
          'Python. Nesting list',
          code: '''
class Mapping:                               # 0
    def __init__(self, iterable):            # 1
        a = [                                # 2
            [                                # 3
                5,                           # 4
                6,                           # 5
            ],                               # 6
            [                                # 7
                7,                           # 8
                8,                           # 9
            ],                               # 10
            ]                                # 11''',
          expected: [
            _FB(firstLine: 0, lastLine: 11, type: _T.indent),
            _FB(firstLine: 1, lastLine: 11, type: _T.indent),
            _FB(firstLine: 2, lastLine: 11, type: _T.brackets),
            _FB(firstLine: 3, lastLine: 6, type: _T.brackets),
            _FB(firstLine: 7, lastLine: 10, type: _T.brackets),
          ],
        ),

        _Example(
          'Python. Single-line comments',
          code: '''
class Mapping:                               # 0
    def __init__(self, iterable):            # 1
        a = [                                # 2
            [                                # 3
              # comment                        4
              # another comment                5
              # third comment                  6
                5,                           # 7
                6,                           # 8
            ],                               # 9
            [                                # 10
                7,                           # 11
                8                            # 12
            ],                               # 13
            [                                # 14
                9,                           # 15
                10                           # 16
                  # comment                    17
                  # another comment            18
                  # third comment              19
            ],                               # 20
        ]                                    # 21''',
          expected: [
            _FB(firstLine: 0, lastLine: 21, type: _T.indent),
            _FB(firstLine: 1, lastLine: 21, type: _T.indent),
            _FB(firstLine: 2, lastLine: 21, type: _T.brackets),
            _FB(firstLine: 3, lastLine: 9, type: _T.brackets),
            _FB(firstLine: 4, lastLine: 6, type: _T.singleLineComment),
            _FB(firstLine: 10, lastLine: 13, type: _T.brackets),
            _FB(firstLine: 14, lastLine: 20, type: _T.brackets),
            _FB(firstLine: 17, lastLine: 19, type: _T.singleLineComment),
          ],
        ),

        _Example(
          'Python. Pair characters in literals are ignored',
          code: '''
a = '{[(';
b = ")]}";
''',
          expected: [],
        ),

        _Example(
          'Python. Service comments do not form blocks',
          code: '''
class Mapping:
    def __init__(self, iterable):
        # [START section1]
        # [END section1]
        a = 5''',
          expected: [
            _FB(firstLine: 0, lastLine: 4, type: _T.indent),
            _FB(firstLine: 1, lastLine: 4, type: _T.indent),
          ],
        ),

        _Example(
          'Python. One-liners expressions do not form blocks',
          code: '''
def printAgeType(age):                         # 0
    type = "Minor" if age < 18 else "Adult"    # 1
    print(type)                                # 2

def squareNumbers(numbers):                    # 4
    squaredNumbers = [x**2 for x in numbers]   # 5
    print(squaredNumbers)                      # 6

printAgeType(19)                               # 8
squareNumbers([1, 2, 3, 4, 5])                 # 9''',
          expected: [
            _FB(firstLine: 0, lastLine: 2, type: _T.indent),
            _FB(firstLine: 4, lastLine: 6, type: _T.indent),
          ],
        ),

        _Example(
          'Python. Return only highlight blocks if it does not contain indents',
          code: '''
numbers = [1, 
2,
3, 
4, 
5
]
squaredNumbers = [x**2 for x in numbers]
print(squaredNumbers)''',
          expected: [_FB(firstLine: 0, lastLine: 5, type: _T.brackets)],
        ),

        _Example(
          'Python. Imports form foldable block',
          code: '''
import math
from math import sqrt
from flutter import dart as language

import foo
import bar

pie = math.pi
print("The value of pi is : ",pie)''',
          expected: [
            _FB(firstLine: 0, lastLine: 5, type: _T.imports),
          ],
        ),

        _Example(
          'Python. Single line comments at start of file',
          code: '''
# This is a comment                   # 0
# This is another comment             # 1
# This is a third comment             # 2

import math                           # 4
from math import sqrt                 # 5
from flutter import dart as language  # 6
import foo                            # 7
import bar                            # 8

pie = math.pi                         # 10
print("The value of pi is : ",pie)    # 11''',
          expected: [
            _FB(firstLine: 0, lastLine: 2, type: _T.singleLineComment),
            _FB(firstLine: 4, lastLine: 8, type: _T.imports),
          ],
        ),

        _Example(
          'Python. Nested blocks opened at the same row joined into one',
          code: '''
a = [[
  5
  ]
]''',
          expected: [
            _FB(firstLine: 0, lastLine: 3, type: _T.union),
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

        final codeLines = CodeLinesBuilder.textToCodeLines(
          text: example.code,
          readonlyCommentsByLine: commentParser.getIfReadonlyCommentByLine(),
        );

        final pythonParser = PythonFoldableBlockParser().parse(
          highlighted: highlighted,
          serviceCommentsSources: serviceComments.map((e) => e.source).toSet(),
          lines: codeLines,
        );

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
