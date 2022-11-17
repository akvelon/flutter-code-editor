// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/code/text_style.dart';
import 'package:flutter_code_editor/src/code_field/span_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/java.dart';

const _default = TextStyle(color: Color(0xFF000000));
const _comment = TextStyle(color: Color(0xFF000001));
const _keyword = TextStyle(color: Color(0xFF000002));
const _class = TextStyle(color: Color(0xFF000003));
const _title = TextStyle(color: Color(0xFF000004));
const _function = TextStyle(color: Color(0xFF000005));
const _params = TextStyle(color: Color(0xFF000006));

final _themeData = CodeThemeData(
  classStyle: _class,
  commentStyle: _comment,
  functionStyle: _function,
  keywordStyle: _keyword,
  titleStyle: _title,
  paramsStyle: _params,
);

final _examples = {
  //
  'Ordinary comments are visible': _Example(
    text: '''
public class MyClass {
  public void main() { // comment
  }
}
''',
    mode: java,
    expected: const TextSpan(
      style: _default,
      children: [
        TextSpan(text: '', style: _default),
        TextSpan(
          style: _keyword,
          children: [TextSpan(text: 'public', style: _keyword)],
        ),
        TextSpan(text: ' ', style: _default),
        TextSpan(
          style: _class,
          children: [
            TextSpan(text: '', style: _class),
            TextSpan(
              style: _keyword,
              children: [TextSpan(text: 'class', style: _keyword)],
            ),
            TextSpan(text: ' ', style: _class),
            TextSpan(
              style: _title,
              children: [TextSpan(text: 'MyClass', style: _title)],
            ),
            TextSpan(text: ' ', style: _class),
          ],
        ),
        TextSpan(text: '{\n', style: _default),
        TextSpan(text: '  ', style: _default),
        TextSpan(
          style: _function,
          children: [
            TextSpan(text: '', style: _function),
            TextSpan(
              style: _keyword,
              children: [TextSpan(text: 'public', style: _keyword)],
            ),
            TextSpan(text: ' ', style: _function),
            TextSpan(
              style: _keyword,
              children: [TextSpan(text: 'void', style: _keyword)],
            ),
            TextSpan(text: ' ', style: _function),
            TextSpan(
              style: _title,
              children: [TextSpan(text: 'main', style: _title)],
            ),
            TextSpan(text: '', style: _function),
            TextSpan(
              style: _params,
              children: [TextSpan(text: '()', style: _params)],
            ),
            TextSpan(text: ' ', style: _function),
          ],
        ),
        TextSpan(text: '{ ', style: _default),
        TextSpan(
          style: _comment,
          children: [TextSpan(text: '// comment', style: _comment)],
        ),
        TextSpan(text: '\n', style: _default),
        TextSpan(text: '  }\n', style: _default),
        TextSpan(text: '}\n', style: _default),
        TextSpan(text: '', style: _default),
      ],
    ),
  ),

  'Service comments are hidden': _Example(
    text: '''
public class MyClass {
  public void main() { // readonly
  }
}
''',
    mode: java,
    expected: TextSpan(
      style: _default,
      children: [
        TextSpan(text: '', style: _default),
        TextSpan(
          style: _keyword,
          children: [TextSpan(text: 'public', style: _keyword)],
        ),
        TextSpan(text: ' ', style: _default),
        TextSpan(
          style: _class,
          children: [
            TextSpan(text: '', style: _class),
            TextSpan(
              style: _keyword,
              children: [TextSpan(text: 'class', style: _keyword)],
            ),
            TextSpan(text: ' ', style: _class),
            TextSpan(
              style: _title,
              children: [TextSpan(text: 'MyClass', style: _title)],
            ),
            TextSpan(text: ' ', style: _class),
          ],
        ),
        TextSpan(text: '{\n', style: _default),
        TextSpan(text: '  ', style: _default.paled()),
        TextSpan(
          style: _function.paled(),
          children: [
            TextSpan(text: '', style: _function.paled()),
            TextSpan(
              style: _keyword.paled(),
              children: [TextSpan(text: 'public', style: _keyword.paled())],
            ),
            TextSpan(text: ' ', style: _function.paled()),
            TextSpan(
              style: _keyword.paled(),
              children: [TextSpan(text: 'void', style: _keyword.paled())],
            ),
            TextSpan(text: ' ', style: _function.paled()),
            TextSpan(
              style: _title.paled(),
              children: [TextSpan(text: 'main', style: _title.paled())],
            ),
            TextSpan(text: '', style: _function.paled()),
            TextSpan(
              style: _params.paled(),
              children: [TextSpan(text: '()', style: _params.paled())],
            ),
            TextSpan(text: ' ', style: _function.paled()),
          ],
        ),
        TextSpan(text: '{ ', style: _default.paled()),
        TextSpan(
          style: _comment.paled(),
          children: [TextSpan(text: '', style: _comment.paled())],
        ),
        TextSpan(text: '\n', style: _default.paled()),
        TextSpan(text: '  }\n', style: _default),
        TextSpan(text: '}\n', style: _default),
        TextSpan(text: '', style: _default),
      ],
    ),
  ),

  'Contains newlines at leaf of node tree': _Example(
    mode: dart,
    text: '''
void method1() 
  if (false) {// [START section1]
    return;
  }// [END section1]
}''',
    readonlySectionNames: {'section1'},
    expected: TextSpan(
      style: _default,
      children: [
        TextSpan(text: '', style: _default),
        TextSpan(
          style: _keyword,
          children: [TextSpan(text: 'void', style: _keyword)],
        ),
        TextSpan(text: ' method1() \n', style: _default),
        TextSpan(text: '  ', style: _default.paled()),
        TextSpan(
          style: _keyword.paled(),
          children: [TextSpan(text: 'if', style: _keyword.paled())],
        ),
        TextSpan(text: ' (', style: _default.paled()),
        TextSpan(
          style: _keyword.paled(),
          children: [TextSpan(text: 'false', style: _keyword.paled())],
        ),
        TextSpan(text: ') {', style: _default.paled()),
        TextSpan(
          style: _comment.paled(),
          children: [TextSpan(text: '', style: _comment.paled())],
        ),
        TextSpan(text: '\n', style: _default.paled()),
        TextSpan(text: '    ', style: _default.paled()),
        TextSpan(
          style: _keyword.paled(),
          children: [TextSpan(text: 'return', style: _keyword.paled())],
        ),
        TextSpan(text: ';\n', style: _default.paled()),
        TextSpan(text: '  }', style: _default.paled()),
        TextSpan(
          style: _comment.paled(),
          children: [TextSpan(text: '', style: _comment.paled())],
        ),
        TextSpan(text: '\n', style: _default.paled()),
        TextSpan(text: '}', style: _default),
      ],
    ),
  ),
};

void main() {
  group('SpanBuilder. Builds highlighted. ', () {
    _examples.forEach((name, example) {
      test(name, () {
        Result? highlighted;

        final mode = example.mode;
        if (mode != null) {
          highlight.registerLanguage('language', mode);
          highlighted = highlight.parse(example.text, language: 'language');
        }

        final code = Code(
          text: example.text,
          highlighted: highlighted,
          language: mode,
          namedSectionParser: BracketsStartEndNamedSectionParser(),
          readOnlySectionNames: example.readonlySectionNames,
        );

        final builder = SpanBuilder(
          code: code,
          theme: _themeData,
          rootStyle: _default,
        );
        final result = builder.build();

        //Uncomment to see result in the console.
        //print(result.toStringRecursive());

        expect(
          result,
          example.expected,
          reason: name,
        );
      });
    });
  });
}

class _Example {
  final String text;
  final Mode? mode;
  final TextSpan expected;
  final Set<String> readonlySectionNames;

  _Example({
    required this.text,
    required this.mode,
    required this.expected,
    this.readonlySectionNames = const {},
  });
}
