// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_code_editor/src/single_line_comments/parser/highlight_single_line_comment_parser.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comments.dart';
import 'package:flutter_code_editor/src/single_line_comments/single_line_comment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/scala.dart';

void main() {
  test('HighlightSingleLineCommentParser', () {
    final examples = [
      // ==================================
      //                Java
      // ==================================

      _Example(
        'Java. Parses unquoted sequences',
        language: java,
        text: '''
// slashed comment1 
/* multi
line */
public class MyClass {
  text // slashed comment2 // still comment2
}
''',
        comments: [
          SingleLineComment(
            lineIndex: 0,
            characterIndex: 0,
            innerContent: ' slashed comment1 ',
            outerContent: '// slashed comment1 ', // note the trailing space.
          ),
          SingleLineComment(
            lineIndex: 4,
            characterIndex: 68,
            innerContent: ' slashed comment2 // still comment2',
            outerContent: '// slashed comment2 // still comment2',
          ),
        ],
      ),

      _Example(
        'Java. Ignores quoted sequences',
        language: java,
        text: '''
/*
 // not a comment
  */
public class MyClass { // comment
  private string str1 = '// not a comment';
  private string str3 = "// not a comment";
}
''',
        comments: [
          SingleLineComment(
            lineIndex: 3,
            characterIndex: 49,
            innerContent: ' comment',
            outerContent: '// comment',
          ),
        ],
      ),

      _Example(
        'Java. Breaks on single-quote multiline strings',
        language: java,
        text: '''
public class MyClass { // comment
  private string str2 = \'''
                           // not a comment
                        \''';
}
''',
        isLanguageLost: true,
      ),

      _Example(
        'Java. Breaks on double-quote multiline strings',
        language: java,
        text: '''
public class MyClass { // comment
  private string str4 = """
                           // not a comment
                        """;
}
''',
        isLanguageLost: true,
      ),

      _Example(
        'Java. Breaks on number sign',
        language: java,
        // https://github.com/git-touch/highlight.dart/issues/36
        text: '''
// slashed comment1
text
  text // slashed comment2 // still comment2
text # not a comment
''',
        isLanguageLost: true,
      ),

      // ==================================
      //                Go
      // ==================================

      _Example(
        'Go. Parses unquoted sequences',
        language: go,
        text: '''
// slashed comment1 
/* multi
line */
public class MyClass {
  text // slashed comment2 // still comment2
}
''',
        comments: [
          SingleLineComment(
            lineIndex: 0,
            characterIndex: 0,
            innerContent: ' slashed comment1 ',
            outerContent: '// slashed comment1 ', // note the trailing space.
          ),
          SingleLineComment(
            lineIndex: 4,
            characterIndex: 68,
            innerContent: ' slashed comment2 // still comment2',
            outerContent: '// slashed comment2 // still comment2',
          ),
        ],
      ),

      _Example(
        'Go. Ignores quoted sequences',
        language: go,
        text: '''
/*
 // not a comment
  */
public class MyClass { // comment
  private string str1 = `// not a comment`;
  private string str2 = `
  // not a comment
  `;
  private string str3 = "// not a comment";
  #
}
''',
        comments: [
          SingleLineComment(
            lineIndex: 3,
            characterIndex: 49,
            innerContent: ' comment',
            outerContent: '// comment',
          ),
        ],
      ),

      // ==================================
      //                Python
      // ==================================

      _Example(
        'Python. Parses unquoted sequences',
        language: python,
        text: '''
# hash comment1 
def fn():
  text # hash comment2 # still comment2
''',
        comments: [
          SingleLineComment(
            lineIndex: 0,
            characterIndex: 0,
            innerContent: ' hash comment1 ',
            outerContent: '# hash comment1 ', // note the trailing space.
          ),
          SingleLineComment(
            lineIndex: 2,
            characterIndex: 34,
            innerContent: ' hash comment2 # still comment2',
            outerContent: '# hash comment2 # still comment2',
          ),
        ],
      ),

      _Example(
        'Python. Ignores quoted sequences',
        language: python,
        text: '''
def fn(): # comment
  str1 = '# not a comment';
  str2 = \'''
  # not a comment
  \'''
  str3 = "# not a comment";
  str4 = """
  # not a comment
  """
''',
        comments: [
          SingleLineComment(
            lineIndex: 0,
            characterIndex: 10,
            innerContent: ' comment',
            outerContent: '# comment',
          ),
        ],
      ),

      _Example(
        'Python. Breaks on missing colon',
        language: python,
        text: '''
def fn() # comment
''',
        isLanguageLost: true,
      ),

      // ==================================
      //                Scala
      // ==================================

      _Example(
        'Scala. Parses unquoted sequences',
        language: scala,
        text: '''
// slashed comment1 
/* multi
line */
public class MyClass {
  text // slashed comment2 // still comment2
}
''',
        comments: [
          SingleLineComment(
            lineIndex: 0,
            characterIndex: 0,
            innerContent: ' slashed comment1 ',
            outerContent: '// slashed comment1 ', // note the trailing space.
          ),
          SingleLineComment(
            lineIndex: 4,
            characterIndex: 68,
            innerContent: ' slashed comment2 // still comment2',
            outerContent: '// slashed comment2 // still comment2',
          ),
        ],
      ),

      _Example(
        'Scala. Ignores quoted sequences',
        language: scala,
        text: '''
/*
 // not a comment
  */
public class MyClass { // comment
  val str3 = "// not a comment";
}
''',
        comments: [
          SingleLineComment(
            lineIndex: 3,
            characterIndex: 49,
            innerContent: ' comment',
            outerContent: '// comment',
          ),
        ],
      ),

      _Example(
        'Scala. Breaks on multiline strings',
        language: scala,
        text: '''
val str4 = """
           // not a comment
           """;
''',
        isLanguageLost: true,
      ),
    ];

    for (final example in examples) {
      highlight.registerLanguage('language', example.language);
      final highlighted = highlight.parse(example.text, language: 'language');

      final result = HighlightSingleLineCommentParser(
        text: example.text,
        highlighted: highlighted,
        singleLineCommentSequences:
            SingleLineComments.byMode[example.language] ?? [],
      );

      expect(result.comments, example.comments, reason: example.name);
      expect(
        highlighted.language,
        example.isLanguageLost ? null : 'language',
        reason: example.name,
      );
    }
  });
}

class _Example {
  final String name;
  final String text;
  final Mode language;
  final List<SingleLineComment> comments;
  final bool isLanguageLost;

  _Example(
    this.name, {
    required this.text,
    required this.language,
    this.comments = const [],
    this.isLanguageLost = false,
  });
}
