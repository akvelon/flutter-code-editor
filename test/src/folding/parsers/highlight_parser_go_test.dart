// ignore_for_file: avoid_private_typedef_functions

import 'package:flutter_code_editor/src/folding/invalid_foldable_block.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/go.dart';

import 'test_executor.dart';

typedef _Tester = HighlightParserTestExecutor;

void main() {
  group('HighlightFoldableBlockParser for Go.', () {
    test('Empty string.', () {
      _Tester.parseAndCheck(mode: go, code: '', expected: []);
    });

    test('Multiline pair-character blocks', () {
      const code = '''
func (
	f *Field) Alive(
	x,
	y int) bool {

}''';
      const expectedBlocks = [
        FB(firstLine: 0, lastLine: 5, type: FBT.union),
      ];
      _Tester.parseAndCheck(mode: go, code: code, expected: expectedBlocks);
    });

    test('Single-line pair-character blocks are ignored.', () {
      const code = '''
func main() {
	type Life struct { a, b *Field;w, h int;}
}''';
      const expectedBlocks = [
        FB(firstLine: 0, lastLine: 2, type: FBT.braces),
      ];
      _Tester.parseAndCheck(mode: go, code: code, expected: expectedBlocks);
    });

    test('Blocks with missing pair characters.', () {
      const code = '''
func main() }
{

func (
	f *Field Alive(
	x,
	y int( bool }}

}''';
      final expectedInvalid = [
        InvalidFoldableBlock(endLine: 0, type: FBT.braces),
        InvalidFoldableBlock(startLine: 1, type: FBT.braces),
        InvalidFoldableBlock(startLine: 3, type: FBT.parentheses),
        InvalidFoldableBlock(startLine: 4, type: FBT.parentheses),
        InvalidFoldableBlock(endLine: 6, type: FBT.braces),
        InvalidFoldableBlock(endLine: 6, type: FBT.braces),
        InvalidFoldableBlock(startLine: 6, type: FBT.parentheses),
        InvalidFoldableBlock(endLine: 8, type: FBT.braces),
      ];
      _Tester.parseAndCheck(
        mode: go,
        code: code,
        expected: [],
        invalid: expectedInvalid,
      );
    });

    test('Pair characters in literals are ignored.', () {
      const code = '''
func main() {
	a := "{[("
	b := `)]}`
}''';
      const expectedBlocks = [
        FB(firstLine: 0, lastLine: 3, type: FBT.braces),
      ];
      _Tester.parseAndCheck(mode: go, code: code, expected: expectedBlocks);
    });

    test('Single line comments in a row.', () {
      const code = '''
// You can edit this code!              0
// Click here and start typing.         1

/*                                      3
some multiline comment                  4
*/
package main
import "fmt"

func main() {
	//here is                            10
	//defined a                          11
	a := "{[("
	/*                                   13
		here is                            14
		defined a                          15
		b                                  16
	*/
	b := ")]}"
	//it's the best Println ever         19
	fmt.Println("Hello, 世界" + a + b)
}''';
      const expectedBlocks = [
        FB(firstLine: 0, lastLine: 1, type: FBT.singleLineComment),
        FB(firstLine: 3, lastLine: 5, type: FBT.multilineComment),
        FB(firstLine: 6, lastLine: 7, type: FBT.imports),
        FB(firstLine: 9, lastLine: 21, type: FBT.braces),
        FB(firstLine: 10, lastLine: 11, type: FBT.singleLineComment),
        FB(firstLine: 13, lastLine: 17, type: FBT.multilineComment),
      ];
      _Tester.parseAndCheck(mode: go, code: code, expected: expectedBlocks);
    });

    test('Imports at beginning.', () {
      const code = '''
package main //      0

import "time" //     2
/* */

import "fmt" //      5

/* */

import "strings" //  9


func main() {}''';
      const expectedBlocks = [
        FB(firstLine: 0, lastLine: 9, type: FBT.imports),
      ];
      _Tester.parseAndCheck(mode: go, code: code, expected: expectedBlocks);
    });

    test('Multiline imports', () {
      const code = '''
package main

import (
	"fmt"
	"strings"
	"time"
)

func main() {}''';
      const expectedBlocks = [
        FB(firstLine: 0, lastLine: 6, type: FBT.imports),
      ];
      _Tester.parseAndCheck(mode: go, code: code, expected: expectedBlocks);
    });

    test('Comments inside multiline imports', () {
      const code = '''
package main
//
//
import (
	"fmt"
	"strings"
)''';
      const expectedBlocks = [
        FB(firstLine: 0, lastLine: 6, type: FBT.imports),
        FB(firstLine: 1, lastLine: 2, type: FBT.singleLineComment),
      ];
      _Tester.parseAndCheck(mode: go, code: code, expected: expectedBlocks);
    });

    test('Imports at mid and the end, no newline in the end.', () {
      const code = '''
package main
import "time"
func foo() {}
import "fmt"
import "strings"
func main() {}''';
      const expectedBlocks = [
        FB(firstLine: 0, lastLine: 1, type: FBT.imports),
        FB(firstLine: 3, lastLine: 4, type: FBT.imports),
      ];
      _Tester.parseAndCheck(mode: go, code: code, expected: expectedBlocks);
    });

    test('Comment after a closing brace.', () {
      const code = '''
func main() {
}//comment
//comment''';
      const expectedBlocks = [
        FB(firstLine: 0, lastLine: 1, type: FBT.braces),
      ];
      _Tester.parseAndCheck(mode: go, code: code, expected: expectedBlocks);
    });

    test('Service comment sequences do not form a foldable block.', () {
      const code = '''
func main() {
// [START section1]
// [END section2]
}''';
      const expectedBlocks = [
        FB(firstLine: 0, lastLine: 3, type: FBT.braces),
      ];
      _Tester.parseAndCheck(mode: go, code: code, expected: expectedBlocks);
    });
  });
}
