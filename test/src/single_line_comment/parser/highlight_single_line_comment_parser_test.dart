import 'package:code_text_field/src/single_line_comments/parser/highlight_single_line_comment_parser.dart';
import 'package:code_text_field/src/single_line_comments/parser/single_line_comments.dart';
import 'package:code_text_field/src/single_line_comments/single_line_comment.dart';
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
        language: java,
        name: 'Java. Parses unquoted sequences',
        text: '''
// slashed comment1 
/* multi
line */
public class MyClass {
  text // slashed comment2 // still comment2
}
''',
        comments: const [
          SingleLineComment(
            lineIndex: 0,
            innerContent: ' slashed comment1 ',
            outerContent: '// slashed comment1 ', // note the trailing space.
          ),
          SingleLineComment(
            lineIndex: 4,
            innerContent: ' slashed comment2 // still comment2',
            outerContent: '// slashed comment2 // still comment2',
          ),
        ],
      ),

      _Example(
        language: java,
        name: 'Java. Ignores quoted sequences',
        text: '''
/*
 // not a comment
  */
public class MyClass { // comment
  private string str1 = '// not a comment';
  private string str3 = "// not a comment";
}
''',
        comments: const [
          SingleLineComment(
            lineIndex: 3,
            innerContent: ' comment',
            outerContent: '// comment',
          ),
        ],
      ),

      _Example(
        language: java,
        name: 'Java. Breaks on single-quote multiline strings',
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
        language: java,
        name: 'Java. Breaks on double-quote multiline strings',
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
        language: java,
        name: 'Java. Breaks on number sign',
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
        language: go,
        name: 'Go. Parses unquoted sequences',
        text: '''
// slashed comment1 
/* multi
line */
public class MyClass {
  text // slashed comment2 // still comment2
}
''',
        comments: const [
          SingleLineComment(
            lineIndex: 0,
            innerContent: ' slashed comment1 ',
            outerContent: '// slashed comment1 ', // note the trailing space.
          ),
          SingleLineComment(
            lineIndex: 4,
            innerContent: ' slashed comment2 // still comment2',
            outerContent: '// slashed comment2 // still comment2',
          ),
        ],
      ),

      _Example(
        language: go,
        name: 'Go. Ignores quoted sequences',
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
        comments: const [
          SingleLineComment(
            lineIndex: 3,
            innerContent: ' comment',
            outerContent: '// comment',
          ),
        ],
      ),

      // ==================================
      //                Python
      // ==================================

      _Example(
        language: python,
        name: 'Python. Parses unquoted sequences',
        text: '''
# hash comment1 
def fn():
  text # hash comment2 # still comment2
''',
        comments: const [
          SingleLineComment(
            lineIndex: 0,
            innerContent: ' hash comment1 ',
            outerContent: '# hash comment1 ', // note the trailing space.
          ),
          SingleLineComment(
            lineIndex: 2,
            innerContent: ' hash comment2 # still comment2',
            outerContent: '# hash comment2 # still comment2',
          ),
        ],
      ),

      _Example(
        language: python,
        name: 'Python. Ignores quoted sequences',
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
        comments: const [
          SingleLineComment(
            lineIndex: 0,
            innerContent: ' comment',
            outerContent: '# comment',
          ),
        ],
      ),

      _Example(
        language: python,
        name: 'Python. Breaks on missing colon',
        text: '''
def fn() # comment
''',
        isLanguageLost: true,
      ),

      // ==================================
      //                Scala
      // ==================================

      _Example(
        language: scala,
        name: 'Scala. Parses unquoted sequences',
        text: '''
// slashed comment1 
/* multi
line */
public class MyClass {
  text // slashed comment2 // still comment2
}
''',
        comments: const [
          SingleLineComment(
            lineIndex: 0,
            innerContent: ' slashed comment1 ',
            outerContent: '// slashed comment1 ', // note the trailing space.
          ),
          SingleLineComment(
            lineIndex: 4,
            innerContent: ' slashed comment2 // still comment2',
            outerContent: '// slashed comment2 // still comment2',
          ),
        ],
      ),

      _Example(
        language: scala,
        name: 'Scala. Ignores quoted sequences',
        text: '''
/*
 // not a comment
  */
public class MyClass { // comment
  val str3 = "// not a comment";
}
''',
        comments: const [
          SingleLineComment(
            lineIndex: 3,
            innerContent: ' comment',
            outerContent: '// comment',
          ),
        ],
      ),

      _Example(
        language: scala,
        name: 'Scala. Breaks on multiline strings',
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

  _Example({
    required this.name,
    required this.text,
    required this.language,
    this.comments = const [],
    this.isLanguageLost = false,
  });
}
