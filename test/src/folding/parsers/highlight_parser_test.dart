import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/service_comment_filter/service_comment_filter.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comment_parser.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comments.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/java.dart';

void main() {
  group('HighlightFoldableBlockParser', () {
    test('parses', () {
      final examples = [
        //
        _Example(
          'Java. Empty string',
          code: '',
          mode: java,
          expected: const [],
          expectedInvalid: const [],
        ),

        _Example(
          'Java. Multiline pair-character blocks',
          code: '''
public class MyClass {
  public static void main(
    String[
    ] args) {
    }
}
''',
          mode: java,
          expected: const [
            _FB(startLine: 0, endLine: 5, type: _T.braces),
            _FB(startLine: 1, endLine: 3, type: _T.parentheses),
            _FB(startLine: 2, endLine: 3, type: _T.brackets),
            _FB(startLine: 3, endLine: 4, type: _T.braces),
          ],
          expectedInvalid: const [],
        ),

        _Example(
          'Java. Single-line pair-character blocks are ignored',
          code: '''
public class MyClass {
  public static void main(String[] args) {}
}
''',
          mode: java,
          expected: const [
            _FB(startLine: 0, endLine: 2, type: _T.braces),
          ],
          expectedInvalid: const [],
        ),

        _Example(
          'Java. Blocks with missing pair characters',
          code: '''
public class MyClass }
  public static void main)String][ args( }
    String][ str;
  {
{
''',
          mode: java,
          expected: const [],
          expectedInvalid: [
            InvalidFoldableBlock(endLine: 0, type: _T.braces),
            InvalidFoldableBlock(endLine: 1, type: _T.parentheses),
            InvalidFoldableBlock(endLine: 1, type: _T.brackets),
            InvalidFoldableBlock(endLine: 1, type: _T.braces),
            InvalidFoldableBlock(startLine: 1, type: _T.brackets),
            InvalidFoldableBlock(startLine: 1, type: _T.parentheses),
            InvalidFoldableBlock(endLine: 2, type: _T.brackets),
            InvalidFoldableBlock(startLine: 2, type: _T.brackets),
            InvalidFoldableBlock(startLine: 3, type: _T.braces),
            InvalidFoldableBlock(startLine: 4, type: _T.braces),
          ],
        ),

        _Example(
          'Java. Pair characters in literals are ignored',
          code: '''
String a = "{[(";
String b = ")]}";
''',
          mode: java,
          expected: const [],
          expectedInvalid: const [],
        ),

        _Example(
          'Java. Pair characters in comments are ignored',
          code: '''
public class MyClass {
  /// {[(                  1
  /*                       2
    )]}                    3
  */                       4
  /// {                    5
}
''',
          mode: java,
          expected: const [
            _FB(startLine: 0, endLine: 6, type: _T.braces),
            _FB(startLine: 2, endLine: 4, type: _T.multilineComment),
          ],
          expectedInvalid: const [],
        ),

        _Example(
          'Java. Single line comments in a row',
          code: '''
// License                                            0
// License                                            1
public class MyClass {

  /// Method                                          4

  /// Method                                          6

  void method() {} // Not the only thing in the line  8
  // Single                                           9
  void method2 // Not the only thing in the line      10
  // Single                                           11
  () {}
}
// Single                                             14
// Single                                             15
''',
          mode: java,
          expected: const [
            _FB(startLine: 0, endLine: 1, type: _T.singleLineComment),
            _FB(startLine: 2, endLine: 13, type: _T.braces),
            _FB(startLine: 4, endLine: 6, type: _T.singleLineComment),
            _FB(startLine: 14, endLine: 15, type: _T.singleLineComment),
          ],
          expectedInvalid: const [],
        ),

        _Example(
          'Java. Imports at beginning',
          code: '''
package com.akvelon.temp;

import java.util.Arrays;

/* */
/* */
import java.util.Date;

/*
*/
import java.lang.Math;

public class MyClass {}
''',
          mode: java,
          expected: const [
            _FB(startLine: 0, endLine: 6, type: _T.imports),
            _FB(startLine: 4, endLine: 5, type: _T.singleLineComment),
            _FB(startLine: 8, endLine: 9, type: _T.multilineComment),
          ],
          expectedInvalid: const [],
        ),

        _Example(
          'Java. Imports at mid and the end, no newline in the end',
          code: '''
//
import java.util.Arrays;
import java.util.Date;
public class MyClass {}
import java.lang.Math;
import java.lang.Exception;''',
          mode: java,
          expected: const [
            _FB(startLine: 1, endLine: 2, type: _T.imports),
            _FB(startLine: 4, endLine: 5, type: _T.imports),
          ],
          expectedInvalid: const [],
        ),
        _Example(
          'Java. Comment after close brace',
          code: '''
class MyClass {
  void method() {
  }// comment
  // comment
}''',
          mode: java,
          expected: const [
            _FB(startLine: 0, endLine: 4, type: _T.braces),
            _FB(startLine: 1, endLine: 2, type: _T.braces),
          ],
          expectedInvalid: const [],
          namedSectionParser: const BracketsStartEndNamedSectionParser(),
        ),
        _Example(
          'Java. Named comments',
          code: '''
class MyClass {
  // [START section1]
  // [END section2]
}''',
          mode: java,
          expected: const [
            _FB(startLine: 0, endLine: 3, type: _T.braces),
          ],
          expectedInvalid: const [],
          namedSectionParser: const BracketsStartEndNamedSectionParser(),
        ),
      ];

      for (final example in examples) {
        highlight.registerLanguage('language', example.mode);
        final highlighted = highlight.parse(example.code, language: 'language');
        final parser = HighlightFoldableBlockParser();

        final sequences = SingleLineComments.byMode[example.mode] ?? [];

        final commentParser = SingleLineCommentParser.parseHighlighted(
          text: example.code,
          highlighted: highlighted,
          singleLineCommentSequences: sequences,
        );

        final serviceComments = ServiceCommentFilter.filter(
          commentParser.comments,
          namedSectionParser: example.namedSectionParser,
        );

        parser.parse(highlighted, serviceComments.map((e) => e.source).toSet());

        expect(
          parser.blocks,
          example.expected,
          reason: '${example.name}, valid blocks',
        );
        expect(
          parser.invalidBlocks,
          example.expectedInvalid,
          reason: '${example.name}, invalid blocks',
        );
      }
    });
  });
}

class _Example {
  final String name;
  final String code;
  final Mode mode;
  final List<FoldableBlock> expected;
  final List<InvalidFoldableBlock> expectedInvalid;
  final AbstractNamedSectionParser? namedSectionParser;

  const _Example(
    this.name, {
    required this.code,
    required this.mode,
    required this.expected,
    required this.expectedInvalid,
    this.namedSectionParser,
  });
}

/// Shorter alias for [FoldableBlock] to avoid line breaks.
typedef _FB = FoldableBlock;

/// Shorter alias for [FoldableBlockType] to avoid line breaks.
typedef _T = FoldableBlockType;
