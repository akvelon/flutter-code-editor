// ignore_for_file: avoid_private_typedef_functions
// ignore_for_file: prefer_const_constructors

import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/code/code_lines_builder.dart';
import 'package:flutter_code_editor/src/folding/parsers/java.dart';
import 'package:flutter_code_editor/src/service_comment_filter/service_comment_filter.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comment_parser.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comments.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart';

void main() {
  test('Java Foldable Block parser (Highlight + Fallback)', () {
    final examples = [
      //
      _Example(
        'empty code',
        code: '',
        expected: [],
      ),

      _Example(
        'All types of foldable blocks are recognized',
        code: '''
/*                                                  // 0
 *                                                  // 1
*/                                                  // 2

package some.package;                               // 4

import java.util.Arrays;                            // 6
import java.util.Date;                              // 7
import java.lang.Math;                              // 8

class MyClass{                                      // 10
  public static ArrayList<String> sequences = [     // 11
    "//",                                           // 12
    "#"                                             // 13
  ];                                                // 14

  void method1(                                     // 16
    int param1,                                     // 17
    int param2                                      // 18
  ){                                                // 19
    // write the body                                  20
    // of the method here                              21
  }                                                 // 22
}                                                   // 23
''',
        expected: [
          _FB(firstLine: 0, lastLine: 2, type: _T.multilineComment),
          _FB(firstLine: 4, lastLine: 8, type: _T.imports),
          _FB(firstLine: 10, lastLine: 23, type: _T.braces),
          _FB(firstLine: 11, lastLine: 14, type: _T.brackets),
          _FB(firstLine: 16, lastLine: 22, type: _T.union),
          _FB(firstLine: 20, lastLine: 21, type: _T.singleLineComment),
        ],
      ),

      _Example(
        'Single-line pair-character blocks are ignored.',
        code: '''
public class MyClass {
    public static void main(String[] args) {}
}''',
        expected: [
          _FB(firstLine: 0, lastLine: 2, type: _T.braces),
        ],
      ),

      _Example(
        'Blocks with missing pair characters',
        code: '''
public class MyClass }
public static void main)String][ args( }
  String][ str;
{
{''',
        expected: [],
        invalidBlocks: [
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
        'Pair characters in literals are ignored.',
        code: '''
String a = "{[(/*";
String b = ")]}*/";''',
        expected: [],
      ),

      _Example(
        'Pair characters in comments are ignored.',
        code: '''
public class MyClass {
/// {[(                  1
/*                       2
  )]}                    3
*/                       4
}''',
        expected: [
          _FB(firstLine: 0, lastLine: 5, type: _T.braces),
          _FB(firstLine: 2, lastLine: 4, type: _T.multilineComment),
        ],
      ),

      _Example(
        'Single line comments in a row',
        code: '''
// License                                            0
// License                                            1
public class MyClass {

/// Comment                                           4

/// Comment                                           6

void method() {} // Not the only thing in the line    8
// Comment                                            9
void method2 // Not the only thing in the line        10
// Comment                                            11
() {}
}
// Comment                                            14
// Comment                                            15''',
        expected: [
          _FB(firstLine: 0, lastLine: 1, type: _T.singleLineComment),
          _FB(firstLine: 2, lastLine: 13, type: _T.braces),
          _FB(firstLine: 4, lastLine: 6, type: _T.singleLineComment),
          _FB(firstLine: 14, lastLine: 15, type: _T.singleLineComment),
        ],
      ),

      _Example(
        'Imports at beginning',
        code: '''
package com.akvelon.temp;

import java.util.Arrays;

/* */
/* */
import java.util.Date;

/*
*/
import java.lang.Math;

public class MyClass {}''',
        expected: [
          _FB(firstLine: 0, lastLine: 10, type: _T.imports),
          _FB(firstLine: 4, lastLine: 5, type: _T.singleLineComment),
          _FB(firstLine: 8, lastLine: 9, type: _T.multilineComment),
        ],
      ),

      _Example(
        'Imports at mid and the end, no newline in the end.',
        code: '''
//
import java.util.Arrays;
import java.util.Date;
public class MyClass {}
import java.lang.Math;
import java.lang.Exception;''',
        expected: [
          _FB(firstLine: 1, lastLine: 2, type: _T.imports),
          _FB(firstLine: 4, lastLine: 5, type: _T.imports),
        ],
      ),

      _Example(
        'Comment after a closing brace.',
        code: '''
class MyClass {
void method() {
}// comment
// comment
}''',
        expected: [
          _FB(firstLine: 0, lastLine: 4, type: _T.braces),
          _FB(firstLine: 1, lastLine: 2, type: _T.braces),
        ],
      ),

      _Example(
        'Multiline comment after a closing brace '
        'with following single line comment',
        code: '''
class MyClass {
void method() {
}/* comment */
// comment
}''',
        expected: [
          _FB(firstLine: 0, lastLine: 4, type: _T.braces),
          _FB(firstLine: 1, lastLine: 2, type: _T.braces),
        ],
      ),

      _Example(
        'A service comment sequence does not form a foldable block.',
        code: '''
class MyClass {
// [START section1]
// [END section2]
}''',
        expected: [
          _FB(firstLine: 0, lastLine: 3, type: _T.braces),
        ],
      ),

      _Example(
        'Multiline comment after a brace',
        code: '''
class MyClass{            // 0

} /*                         2
* some weird comment         3
*/                        // 4
''',
        expected: [
          _FB(firstLine: 0, lastLine: 4, type: _T.union),
        ],
      ),

      _Example(
        'Multiline comment between imports',
        code: '''
import java.util.Arrays;      // 0
import java.util.Date;        // 1
/*                               2
*/
import java.lang.Math;        // 4
import java.lang.Exception;   // 5
''',
        expected: [
          _FB(firstLine: 0, lastLine: 5, type: _T.imports),
          _FB(firstLine: 2, lastLine: 3, type: _T.multilineComment),
        ],
      ),

      _Example(
        'Multiple multiline comments',
        code: '''
/* License                                            0
 * License                                            1  */
public class MyClass {

/* Method                                             4
 *
 * Method                                             6  */

void method() {} // Not the only thing in the line    8
/* Single                                             9  */
void method2 // Not the only thing in the line        10
/* Single                                             11 */
() {}
}
/* Comment                                            14
 * Comment                                            15 */
''',
        expected: [
          _FB(firstLine: 0, lastLine: 1, type: _T.multilineComment),
          _FB(firstLine: 2, lastLine: 13, type: _T.braces),
          _FB(firstLine: 4, lastLine: 6, type: _T.multilineComment),
          _FB(firstLine: 14, lastLine: 15, type: _T.multilineComment),
        ],
      ),

      _Example(
        'Pair characters in a multiline '
        'that started at the end of a normal line',
        code: '''
class MyClass{

} /*
{

}
*/
''',
        expected: [
          _FB(firstLine: 0, lastLine: 6, type: _T.union),
        ],
      ),

      _Example(
        'Multiline comment that terminates on the same line '
        'and has non-whitespace char before it, '
        'should terminate import sequence',
        code: '''
import java.util.Arrays;      // 0
import java.util.Date;        // 1
class MyClass { } /*             2 */
                              // 3
import java.lang.Math;        // 4
import java.lang.Exception;   // 5
''',
        expected: [
          _FB(firstLine: 0, lastLine: 1, type: _T.imports),
          _FB(firstLine: 4, lastLine: 5, type: _T.imports),
        ],
      ),

      _Example(
        'Multiline comment that terminates on the same line '
        'and has non-whitespace char after it, '
        'should terminate import sequence',
        code: '''
import java.util.Arrays;      // 0
import java.util.Date;        // 1
/*                            2 */ int a;
                              // 3
import java.lang.Math;        // 4
import java.lang.Exception;   // 5
''',
        expected: [
          _FB(firstLine: 0, lastLine: 1, type: _T.imports),
          _FB(firstLine: 4, lastLine: 5, type: _T.imports),
        ],
      ),

      _Example(
        'Multiline comment that has a single-line comment after it, '
        'SHOULD NOT terminate import sequence',
        code: '''
import java.util.Arrays;      // 0
import java.util.Date;        // 1
/*                               2 */ // Comment

                              // 4
/*                               5
*/ // Comment                    6
   // Comment                    7
import java.lang.Math;        // 8
import java.lang.Exception;   // 9
''',
        expected: [
          _FB(firstLine: 0, lastLine: 9, type: _T.imports),
          _FB(firstLine: 2, lastLine: 4, type: _T.singleLineComment),
          _FB(firstLine: 5, lastLine: 7, type: _T.union),
        ],
      ),
    ];

    for (final example in examples) {
      for (final code in [example.code, example.breakingCode]) {
        highlight.registerLanguage('language', java);
        final highlighted = highlight.parse(
          code,
          language: 'language',
        );

        final sequences = SingleLineComments.byMode[java] ?? [];

        final commentParser = SingleLineCommentParser.parseHighlighted(
          text: code,
          highlighted: highlighted,
          singleLineCommentSequences: sequences,
        );

        final serviceComments = ServiceCommentFilter.filter(
          commentParser.comments,
          namedSectionParser: const BracketsStartEndNamedSectionParser(),
        );

        final codeLines = CodeLinesBuilder.textToCodeLines(
          text: code,
          readonlyCommentsByLine: commentParser.getIfReadonlyCommentByLine(),
        );

        final javaParser = JavaFoldableBlockParser()
          ..parse(
            highlighted: highlighted,
            serviceCommentsSources:
                serviceComments.map((e) => e.source).toSet(),
            lines: codeLines,
          );

        final isBreaking = code == example.breakingCode;
        expect(
          javaParser.blocks,
          example.expected,
          reason: '${example.name}, valid blocks, isBreaking: $isBreaking',
        );
        expect(
          javaParser.invalidBlocks,
          example.invalidBlocks,
          reason: '${example.name}, invalid blocks, isBreaking: $isBreaking',
        );
      }
    }
  });
}

class _Example {
  final String name;
  final String code;
  final String breakingCode;
  final List<FoldableBlock> expected;
  final List<InvalidFoldableBlock> invalidBlocks;

  const _Example(
    this.name, {
    required this.code,
    required this.expected,
    this.invalidBlocks = const [],
  }) : breakingCode = '$code\n"\n';
}

/// Shorter alias for [FoldableBlock] to avoid line breaks.
typedef _FB = FoldableBlock;

/// Shorter alias for [FoldableBlockType] to avoid line breaks.
typedef _T = FoldableBlockType;
