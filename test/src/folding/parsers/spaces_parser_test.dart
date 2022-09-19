import 'package:flutter_code_editor/src/folding/foldable_block.dart';
import 'package:flutter_code_editor/src/folding/foldable_block_type.dart';
import 'package:flutter_code_editor/src/folding/parsers/spaces_foldable_block_parser.dart';
import 'package:flutter_code_editor/src/named_sections/parsers/abstract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpacesFoldableBlockParser', () {
    test('parses spaces', () {
      const examples = [
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
            _FB(startLine: 0, endLine: 3, type: _T.spaces),
            _FB(startLine: 1, endLine: 3, type: _T.spaces),
          ],
        ),
        _Example(
          'Python. Several nesting',
          code: '''
class Mapping:
    def __init__(self, iterable):
        self.items_list = []
        self.__update(iterable)

    def update(self, iterable):
        for item in iterable:
            self.items_list.append(item)''',
          expected: [
            _FB(startLine: 0, endLine: 7, type: _T.spaces),
            _FB(startLine: 1, endLine: 3, type: _T.spaces),
            _FB(startLine: 5, endLine: 7, type: _T.spaces),
            _FB(startLine: 6, endLine: 7, type: _T.spaces),
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
            _FB(startLine: 0, endLine: 14, type: _T.spaces),
            _FB(startLine: 2, endLine: 6, type: _T.spaces),
            _FB(startLine: 9, endLine: 14, type: _T.spaces),
            _FB(startLine: 12, endLine: 14, type: _T.spaces),
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
            _FB(startLine: 2, endLine: 9, type: _T.spaces),
            _FB(startLine: 3, endLine: 5, type: _T.spaces),
            _FB(startLine: 7, endLine: 9, type: _T.spaces),
            _FB(startLine: 8, endLine: 9, type: _T.spaces),
          ],
        ),
      ];

      for (final example in examples) {
        final parser = SpacesFoldableBlockParser();
        parser.parse(example.code);
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
  final AbstractNamedSectionParser? namedSectionParser;

  const _Example(
    this.name, {
    required this.code,
    required this.expected,
    this.namedSectionParser,
  });
}

/// Shorter alias for [FoldableBlock] to avoid line breaks.
typedef _FB = FoldableBlock;

/// Shorter alias for [FoldableBlockType] to avoid line breaks.
typedef _T = FoldableBlockType;
