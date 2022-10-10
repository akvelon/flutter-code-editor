import 'package:flutter_code_editor/src/folding/invalid_foldable_block.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';

import 'test_executor.dart';

typedef _Tester = HighlightParserTestExecutor;

void main() {
  group('HighlightFoldableBlockParser for Java.', () {
    test('Empty string.', () {
      _Tester.parseAndCheck(mode: java, code: '', expected: []);
    });

    test('Multiline pair-character blocks', () {
      const code = '''
public class MyClass {
public static void main(
  String[
  ] args) {
  }
}''';
      const expectedBlocks = [
        FB(startLine: 0, endLine: 5, type: FBT.braces),
        FB(startLine: 1, endLine: 4, type: FBT.union),
      ];
      _Tester.parseAndCheck(mode: java, code: code, expected: expectedBlocks);
    });

    test('Single-line pair-character blocks are ignored.', () {
      const code = '''
public class MyClass {
    public static void main(String[] args) {}
}''';
      const expected = [
        FB(startLine: 0, endLine: 2, type: FBT.braces),
      ];
      _Tester.parseAndCheck(mode: java, code: code, expected: expected);
    });

    test('Blocks with missing pair characters.', () {
      const code = '''
public class MyClass }
public static void main)String][ args( }
  String][ str;
{
{''';
      final expectedInvalid = [
        InvalidFoldableBlock(endLine: 0, type: FBT.braces),
        InvalidFoldableBlock(endLine: 1, type: FBT.parentheses),
        InvalidFoldableBlock(endLine: 1, type: FBT.brackets),
        InvalidFoldableBlock(endLine: 1, type: FBT.braces),
        InvalidFoldableBlock(startLine: 1, type: FBT.brackets),
        InvalidFoldableBlock(startLine: 1, type: FBT.parentheses),
        InvalidFoldableBlock(endLine: 2, type: FBT.brackets),
        InvalidFoldableBlock(startLine: 2, type: FBT.brackets),
        InvalidFoldableBlock(startLine: 3, type: FBT.braces),
        InvalidFoldableBlock(startLine: 4, type: FBT.braces),
      ];
      _Tester.parseAndCheck(
        mode: java,
        code: code,
        expected: [],
        invalid: expectedInvalid,
      );
    });

    test('Pair characters in literals are ignored.', () {
      const code = '''
String a = "{[(";
String b = ")]}";''';
      _Tester.parseAndCheck(mode: java, code: code, expected: []);
    });

    test('Pair characters in comments are ignored.', () {
      const code = '''
public class MyClass {
/// {[(                  1
/*                       2
  )]}                    3
*/                       4
/// {                    5
}''';
      const expected = [
        FB(startLine: 0, endLine: 6, type: FBT.braces),
        FB(startLine: 2, endLine: 4, type: FBT.multilineComment),
      ];
      _Tester.parseAndCheck(mode: java, code: code, expected: expected);
    });

    test('Single line comments in a row.', () {
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
        FB(startLine: 0, endLine: 1, type: FBT.singleLineComment),
        FB(startLine: 2, endLine: 13, type: FBT.braces),
        FB(startLine: 4, endLine: 6, type: FBT.singleLineComment),
        FB(startLine: 14, endLine: 15, type: FBT.singleLineComment),
      ];
      _Tester.parseAndCheck(mode: java, code: code, expected: expected);
    });

    test('Imports at beginning.', () {
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
        FB(startLine: 0, endLine: 6, type: FBT.imports),
        FB(startLine: 4, endLine: 5, type: FBT.singleLineComment),
        FB(startLine: 8, endLine: 9, type: FBT.multilineComment),
      ];
      _Tester.parseAndCheck(mode: java, code: code, expected: expected);
    });

    test('Imports at mid and the end, no newline in the end.', () {
      final mode = java;
      const code = '''
//
import java.util.Arrays;
import java.util.Date;
public class MyClass {}
import java.lang.Math;
import java.lang.Exception;''';
      const expected = [
        FB(startLine: 1, endLine: 2, type: FBT.imports),
        FB(startLine: 4, endLine: 5, type: FBT.imports),
      ];
      _Tester.parseAndCheck(mode: mode, code: code, expected: expected);
    });

    test('Comment after a closing brace.', () {
      const code = '''
class MyClass {
void method() {
}// comment
// comment
}''';
      const expected = [
        FB(startLine: 0, endLine: 4, type: FBT.braces),
        FB(startLine: 1, endLine: 2, type: FBT.braces),
      ];
      _Tester.parseAndCheck(mode: java, code: code, expected: expected);
    });

    test('Service comment sequences do not form a foldable block.', () {
      final mode = java;
      const code = '''
class MyClass {
// [START section1]
// [END section2]
}''';
      const expected = [
        FB(startLine: 0, endLine: 3, type: FBT.braces),
      ];
      _Tester.parseAndCheck(mode: mode, code: code, expected: expected);
    });
  });
}
