import 'package:flutter_code_editor/src/folding/foldable_block.dart';
import 'package:flutter_code_editor/src/folding/foldable_block_type.dart';
import 'package:flutter_code_editor/src/folding/invalid_foldable_block.dart';
import 'package:flutter_code_editor/src/folding/parsers/highlight.dart';
import 'package:flutter_code_editor/src/named_sections/parsers/brackets_start_end.dart';
import 'package:flutter_code_editor/src/service_comment_filter/service_comment_filter.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comment_parser.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comments.dart';
import 'package:flutter_code_editor/src/single_line_comments/single_line_comment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/scala.dart';

void main() {
  _testJava();
  _testScala();
}

void _testJava() {
  group('HighlightFoldableBlockParser for Java.', () {
    test('Java. Empty string.', () {
      _parseAndCheck(mode: java, code: '', expected: []);
    });

    test('Java. Multiline pair-character blocks', () {
      const code = '''
public class MyClass {
public static void main(
  String[
  ] args) {
  }
}''';
      const expectedBlocks = [
        _FB(startLine: 0, endLine: 5, type: _T.braces),
        _FB(startLine: 1, endLine: 3, type: _T.parentheses),
        _FB(startLine: 2, endLine: 3, type: _T.brackets),
        _FB(startLine: 3, endLine: 4, type: _T.braces),
      ];
      _parseAndCheck(mode: java, code: code, expected: expectedBlocks);
    });

    test('Java. Single-line pair-character blocks are ignored.', () {
      const code = '''
public class MyClass {
    public static void main(String[] args) {}
}''';
      const expected = [
        _FB(startLine: 0, endLine: 2, type: _T.braces),
      ];
      _parseAndCheck(mode: java, code: code, expected: expected);
    });

    test('Java. Blocks with missing pair characters.', () {
      const code = '''
public class MyClass }
public static void main)String][ args( }
  String][ str;
{
{''';
      final expectedInvalid = [
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
      ];
      _parseAndCheck(
        mode: java,
        code: code,
        expected: [],
        invalid: expectedInvalid,
      );
    });

    test('Java. Pair characters in literals are ignored.', () {
      const code = '''
String a = "{[(";
String b = ")]}";''';
      _parseAndCheck(mode: java, code: code, expected: []);
    });

    test('Java. Pair characters in comments are ignored.', () {
      const code = '''
public class MyClass {
/// {[(                  1
/*                       2
  )]}                    3
*/                       4
/// {                    5
}''';
      const expected = [
        _FB(startLine: 0, endLine: 6, type: _T.braces),
        _FB(startLine: 2, endLine: 4, type: _T.multilineComment),
      ];
      _parseAndCheck(mode: java, code: code, expected: expected);
    });

    test('Java. Single line comments in a row.', () {
      const code = '''
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
// Single                                             15''';
      const expected = [
        _FB(startLine: 0, endLine: 1, type: _T.singleLineComment),
        _FB(startLine: 2, endLine: 13, type: _T.braces),
        _FB(startLine: 4, endLine: 6, type: _T.singleLineComment),
        _FB(startLine: 14, endLine: 15, type: _T.singleLineComment),
      ];
      _parseAndCheck(mode: java, code: code, expected: expected);
    });

    test('Java. Imports at beginning.', () {
      const code = '''
package com.akvelon.temp;

import java.util.Arrays;

/* */
/* */
import java.util.Date;

/*
*/
import java.lang.Math;

public class MyClass {}''';
      const expected = [
        _FB(startLine: 0, endLine: 6, type: _T.imports),
        _FB(startLine: 4, endLine: 5, type: _T.singleLineComment),
        _FB(startLine: 8, endLine: 9, type: _T.multilineComment),
      ];
      _parseAndCheck(mode: java, code: code, expected: expected);
    });

    test('Java. Imports at mid and the end, no newline in the end.', () {
      final mode = java;
      const code = '''
//
import java.util.Arrays;
import java.util.Date;
public class MyClass {}
import java.lang.Math;
import java.lang.Exception;''';
      const expected = [
        _FB(startLine: 1, endLine: 2, type: _T.imports),
        _FB(startLine: 4, endLine: 5, type: _T.imports),
      ];
      _parseAndCheck(mode: mode, code: code, expected: expected);
    });

    test('Java. Comment after a closing brace.', () {
      const code = '''
class MyClass {
void method() {
}// comment
// comment
}''';
      const expected = [
        _FB(startLine: 0, endLine: 4, type: _T.braces),
        _FB(startLine: 1, endLine: 2, type: _T.braces),
      ];
      _parseAndCheck(mode: java, code: code, expected: expected);
    });

    test('Java. Service comment sequences do not form a foldable block.', () {
      final mode = java;
      const code = '''
class MyClass {
// [START section1]
// [END section2]
}''';
      const expected = [
        _FB(startLine: 0, endLine: 3, type: _T.braces),
      ];
      _parseAndCheck(mode: mode, code: code, expected: expected);
    });
  });
}

void _testScala() {
  group('HighlightFoldableBlockParser for Scala', () {
    test('Scala. Empty file.', () {
      _parseAndCheck(mode: scala, code: '', expected: []);
    });

    test('Scala. Multiline pair-character block', () {
      const code = '''
class MyClass(var myVar1: Int,
              var myVar2: String
             ) {
  def main(main1: Int,
           main2: Int
  ) = {
    println("h")
  }
}''';
      const expected = [
        _FB(startLine: 0, endLine: 2, type: _T.parentheses),
        _FB(startLine: 2, endLine: 8, type: _T.braces),
        _FB(startLine: 3, endLine: 5, type: _T.parentheses),
        _FB(startLine: 5, endLine: 7, type: _T.braces),
      ];
      _parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Scala. Single-line pair-character blocks are ignored.', () {
      const code = '''
class MyClass() {
  def main() = {}
}''';
      const expected = [
        _FB(startLine: 0, endLine: 2, type: _T.braces),
      ];
      _parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Scala. Blocks with missing pair character.', () {
      const code = '''
class MyClass() }
''';
      final expectedInvalid = [
        InvalidFoldableBlock(endLine: 0, type: _T.braces),
      ];
      _parseAndCheck(
        mode: scala,
        code: code,
        expected: [],
        invalid: expectedInvalid,
      );
    });

    test('Scala. Pair characters in literals are ignored.', () {
      const code = '''
val a = "{[("
val b = ")]}"''';
      _parseAndCheck(mode: scala, code: code, expected: []);
    });

    test('Scala. Pair characters in comments are ignored.', () {
      const code = '''
class MyClass() {
/// {[(                  1
/*                       2
  )]}                    3
*/                       4
/// {                    5
}''';
      const expected = [
        _FB(startLine: 0, endLine: 6, type: _T.braces),
        _FB(startLine: 2, endLine: 4, type: _T.multilineComment),
      ];
      _parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Scala. Single line comments in a row.', () {
      const code = '''
// License                                            0
// License                                            1
class MyClass() {

/// Method                                            4

/// Method                                            6

def method() = {} // Not the only thing in the line   8
// Single                                             9
def method2 // Not the only thing in the line        10
// Single                                            11
() = {}
}
// Single                                            14
// Single                                            15''';
      const expected = [
        _FB(startLine: 0, endLine: 1, type: _T.singleLineComment),
        _FB(startLine: 2, endLine: 13, type: _T.braces),
        _FB(startLine: 4, endLine: 6, type: _T.singleLineComment),
        _FB(startLine: 14, endLine: 15, type: _T.singleLineComment),
      ];
      _parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Scala. Imports at the beginning.', () {
      const code = '''
package users
/* */
import users._  // import everything from the users package                      2
/*                                                                               3
  awesome multiline comment                                                      4
*/
import users.User  // import the class User                                      6
import users.{User, UserPreferences}  // Only imports selected members           7
import users.{UserPreferences => UPrefs} // import and rename for convenience    8

class MyClass() {} //                                                           10 ''';
      const expected = [
        _FB(startLine: 0, endLine: 2, type: _T.imports),
        _FB(startLine: 3, endLine: 5, type: _T.multilineComment),
        _FB(startLine: 6, endLine: 8, type: _T.imports),
      ];
      _parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Scala. Imports at mid and the end, no newline in the end.', () {
      const code = '''
//
package users
import users._  // import everything from the users package
class MyClass() {}
import users.User  // import the class User
import users.{User, UserPreferences}  // Only imports selected members''';
      const expected = [
        _FB(startLine: 1, endLine: 2, type: _T.imports),
        _FB(startLine: 4, endLine: 5, type: _T.imports),
      ];
      _parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Scala. Comment after a closing brace.', () {
      const code = '''
class MyClass() {
def method() = {
}// comment
// comment
}''';
      const expected = [
        _FB(startLine: 0, endLine: 4, type: _T.braces),
        _FB(startLine: 1, endLine: 2, type: _T.braces),
      ];
      _parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Scala. Service comment sequences do not form a foldable block.', () {
      const code = '''
class MyClass() {
// [START section1]
// [END section2]
}''';
      const expected = [
        _FB(startLine: 0, endLine: 3, type: _T.braces),
      ];
      _parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Scala. Objects form block.', () {
      const code = '''
object IdFactory {
  private var counter = 0
  def create(): Int = {
    counter += 1
    counter
  }
}''';
      const expected = [
        _FB(startLine: 0, endLine: 6, type: _T.braces),
        _FB(startLine: 2, endLine: 5, type: _T.braces),
      ];
      _parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Scala. One line functions do not form block.', () {
      const code = '''
object Main {
  def main(args: Array[String]): Unit =
    println("Hello, Scala developer!")
}''';
      const expected = [
        _FB(startLine: 0, endLine: 3, type: _T.braces),
      ];
      _parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Scala. Multiline list form block.', () {
      const code = '''
val list: List[Any] = List(
  "a string",
  732,  // an integer
  'c',  // a character
  true, // a boolean value
  () => "an anonymous function returning a string"
)''';
      const expected = [
        _FB(startLine: 0, endLine: 6, type: _T.parentheses),
      ];
      _parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Scala. Match function form block.', () {
      const code = '''
def matchTest(x: Int): String = x match {
  case 1 => "one"
  case 2 => "two"
  case _ => "other"
}''';
      const expected = [
        _FB(startLine: 0, endLine: 4, type: _T.braces),
      ];
      _parseAndCheck(mode: scala, code: code, expected: expected);
    });
  });
}

void _parseAndCheck({
  required Mode mode,
  required String code,
  required List<FoldableBlock> expected,
  List<InvalidFoldableBlock> invalid = const [],
}) {
  highlight.registerLanguage('language', mode);
  final highlighted = highlight.parse(code, language: 'language');
  final parser = HighlightFoldableBlockParser();

  final sequences = SingleLineComments.byMode[mode] ?? [];

  final commentParser = SingleLineCommentParser.parseHighlighted(
    text: code,
    highlighted: highlighted,
    singleLineCommentSequences: sequences,
  );

  final serviceComments = ServiceCommentFilter.filter(
    commentParser.comments,
    namedSectionParser: const BracketsStartEndNamedSectionParser(),
  );

  parser.parse(
    highlighted: highlighted,
    serviceCommentsSources: serviceComments.sources,
  );

  expect(parser.blocks, expected);
  expect(parser.invalidBlocks, invalid);
}

/// Shorter alias for [FoldableBlock] to avoid line breaks.
typedef _FB = FoldableBlock;

/// Shorter alias for [FoldableBlockType] to avoid line breaks.
typedef _T = FoldableBlockType;
