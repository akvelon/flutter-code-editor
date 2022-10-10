import 'package:flutter_code_editor/src/folding/invalid_foldable_block.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/scala.dart';

import 'test_executor.dart';

typedef _Tester = HighlightParserTestExecutor;

void main() {
  group('HighlightFoldableBlockParser for Scala', () {
    test('Empty file.', () {
      _Tester.parseAndCheck(mode: scala, code: '', expected: []);
    });

    test('Multiline pair-character block', () {
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
        FB(startLine: 0, endLine: 8, type: FBT.union),
        FB(startLine: 3, endLine: 7, type: FBT.union),
      ];
      _Tester.parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Single-line pair-character blocks are ignored.', () {
      const code = '''
class MyClass() {
  def main() = {}
}''';
      const expected = [
        FB(startLine: 0, endLine: 2, type: FBT.braces),
      ];
      _Tester.parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Blocks with missing pair character.', () {
      const code = '''
class MyClass() }
''';
      final expectedInvalid = [
        InvalidFoldableBlock(endLine: 0, type: FBT.braces),
      ];
      _Tester.parseAndCheck(
        mode: scala,
        code: code,
        expected: [],
        invalid: expectedInvalid,
      );
    });

    test('Pair characters in literals are ignored.', () {
      const code = '''
val a = "{[("
val b = ")]}"''';
      _Tester.parseAndCheck(mode: scala, code: code, expected: []);
    });

    test('Pair characters in comments are ignored.', () {
      const code = '''
class MyClass() {
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
      _Tester.parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Single line comments in a row.', () {
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
        FB(startLine: 0, endLine: 1, type: FBT.singleLineComment),
        FB(startLine: 2, endLine: 13, type: FBT.braces),
        FB(startLine: 4, endLine: 6, type: FBT.singleLineComment),
        FB(startLine: 14, endLine: 15, type: FBT.singleLineComment),
      ];
      _Tester.parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Imports at the beginning.', () {
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
        FB(startLine: 0, endLine: 2, type: FBT.imports),
        FB(startLine: 3, endLine: 5, type: FBT.multilineComment),
        FB(startLine: 6, endLine: 8, type: FBT.imports),
      ];
      _Tester.parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Imports at mid and the end, no newline in the end.', () {
      const code = '''
//
package users
import users._  // import everything from the users package
class MyClass() {}
import users.User  // import the class User
import users.{ User, UserPreferences}  // Only imports selected members''';
      const expected = [
        FB(startLine: 1, endLine: 2, type: FBT.imports),
        FB(startLine: 4, endLine: 5, type: FBT.imports),
      ];
      _Tester.parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Multiline imports form braces foldable block', () {
      //TODO(Malarg): handle scala multiline blocks
      //https://github.com/akvelon/flutter-code-editor/issues/78.
      const code = '''
import users.User  // import the class User
import users.{ 
  User, 
  UserPreferences
}  // Only imports selected members''';
      const expected = [
        FB(startLine: 0, endLine: 4, type: FBT.union),
      ];
      _Tester.parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Comment after a closing brace.', () {
      const code = '''
class MyClass() {
def method() = {
}// comment
// comment
}''';
      const expected = [
        FB(startLine: 0, endLine: 4, type: FBT.braces),
        FB(startLine: 1, endLine: 2, type: FBT.braces),
      ];
      _Tester.parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Service comment sequences do not form a foldable block.', () {
      const code = '''
class MyClass() {
// [START section1]
// [END section2]
}''';
      const expected = [
        FB(startLine: 0, endLine: 3, type: FBT.braces),
      ];
      _Tester.parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Objects form block.', () {
      const code = '''
object IdFactory {
  private var counter = 0
  def create(): Int = {
    counter += 1
    counter
  }
}''';
      const expected = [
        FB(startLine: 0, endLine: 6, type: FBT.braces),
        FB(startLine: 2, endLine: 5, type: FBT.braces),
      ];
      _Tester.parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('One line functions do not form block.', () {
      const code = '''
object Main {
  def main(args: Array[String]): Unit =
    println("Hello, Scala developer!")
}''';
      const expected = [
        FB(startLine: 0, endLine: 3, type: FBT.braces),
      ];
      _Tester.parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Multiline lists form block.', () {
      const code = '''
val list: List[Any] = List(
  "a string",
  732,  // an integer
  'c',  // a character
  true, // a boolean value
  () => "an anonymous function returning a string"
)''';
      const expected = [
        FB(startLine: 0, endLine: 6, type: FBT.parentheses),
      ];
      _Tester.parseAndCheck(mode: scala, code: code, expected: expected);
    });

    test('Match functions form block.', () {
      const code = '''
def matchTest(x: Int): String = x match {
  case 1 => "one"
  case 2 => "two"
  case _ => "other"
}''';
      const expected = [
        FB(startLine: 0, endLine: 4, type: FBT.braces),
      ];
      _Tester.parseAndCheck(mode: scala, code: code, expected: expected);
    });
  });
}
