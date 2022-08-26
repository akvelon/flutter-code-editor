// ignore_for_file: avoid_redundant_argument_values

import 'package:code_text_field/src/single_line_comments/parser/text_single_line_comment_parser.dart';
import 'package:code_text_field/src/single_line_comments/single_line_comment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextSingleLineCommentParser', () {
    test('grabs everything at the sequence and on', () {
      const sequences = ['//', '~'];
      const text = '''
// slashed comment1 
  text // slashed comment2 // still comment2
text
text # not a comment
text ~ tilde comment3
'single // quotes ~ line'
"double ~ quotes // line"
/* multi //line comment */''';
      const expected = [
        SingleLineComment(
          lineIndex: 0,
          characterIndex: 0,
          innerContent: ' slashed comment1 ',
          outerContent: '// slashed comment1 ',
        ),
        SingleLineComment(
          lineIndex: 1,
          characterIndex: 28,
          innerContent: ' slashed comment2 // still comment2',
          outerContent: '// slashed comment2 // still comment2',
        ),
        SingleLineComment(
          lineIndex: 4,
          characterIndex: 97,
          innerContent: ' tilde comment3',
          outerContent: '~ tilde comment3',
        ),
        SingleLineComment(
          lineIndex: 5,
          characterIndex: 122,
          innerContent: ' quotes ~ line\'',
          outerContent: '// quotes ~ line\'',
        ),
        SingleLineComment(
          lineIndex: 6,
          characterIndex: 148,
          innerContent: ' quotes // line"',
          outerContent: '~ quotes // line"',
        ),
        SingleLineComment(
          lineIndex: 7,
          characterIndex: 175,
          innerContent: 'line comment */',
          outerContent: '//line comment */',
        ),
      ];

      final result = TextSingleLineCommentParser(
        text: text,
        singleLineCommentSequences: sequences,
      );

      expect(result.comments, expected);
    });
  });
}
