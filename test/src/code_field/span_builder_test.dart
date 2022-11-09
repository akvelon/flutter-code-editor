// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/code_field/span_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart';

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

void main() {
  group('SpanBuilder', () {
    test('builds highlighted', () {
      final examples = [
        //
        _Example(
          'Ordinary comments are visible',
          text: '''
public class MyClass {
  public void main() { // comment
  }
}
''',
          mode: java,
          expected: const TextSpan(
            children: [
              TextSpan(text: ''),
              TextSpan(
                style: _keyword,
                children: [TextSpan(text: 'public')],
              ),
              TextSpan(text: ' '),
              TextSpan(
                style: _class,
                children: [
                  TextSpan(text: ''),
                  TextSpan(
                    style: _keyword,
                    children: [TextSpan(text: 'class')],
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    style: _title,
                    children: [TextSpan(text: 'MyClass')],
                  ),
                  TextSpan(text: ' '),
                ],
              ),
              TextSpan(text: '{\n'),
              TextSpan(text: '  '),
              TextSpan(
                style: _function,
                children: [
                  TextSpan(text: ''),
                  TextSpan(
                    style: _keyword,
                    children: [TextSpan(text: 'public')],
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    style: _keyword,
                    children: [TextSpan(text: 'void')],
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    style: _title,
                    children: [TextSpan(text: 'main')],
                  ),
                  TextSpan(text: ''),
                  TextSpan(
                    style: _params,
                    children: [TextSpan(text: '()')],
                  ),
                  TextSpan(text: ' '),
                ],
              ),
              TextSpan(text: '{ '),
              TextSpan(
                style: _comment,
                children: [TextSpan(text: '// comment')],
              ),
              TextSpan(text: '\n'),
              TextSpan(text: '  }\n'),
              TextSpan(text: '}\n'),
              TextSpan(text: ''),
            ],
          ),
        ),

        _Example(
          'Service comments are hidden',
          text: '''
public class MyClass {
  public void main() { // readonly
  }
}
''',
          mode: java,
          expected: TextSpan(
            children: [
              TextSpan(text: ''),
              TextSpan(
                style: _keyword,
                children: [TextSpan(text: 'public')],
              ),
              TextSpan(text: ' '),
              TextSpan(
                style: _class,
                children: [
                  TextSpan(text: ''),
                  TextSpan(
                    style: _keyword,
                    children: [TextSpan(text: 'class')],
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    style: _title,
                    children: [TextSpan(text: 'MyClass')],
                  ),
                  TextSpan(text: ' '),
                ],
              ),
              TextSpan(text: '{\n'),
              TextSpan(text: '  '),
              TextSpan(
                style: _function.paled(),
                children: [
                  TextSpan(text: ''),
                  TextSpan(
                    style: _keyword.paled(),
                    children: [TextSpan(text: 'public')],
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    style: _keyword.paled(),
                    children: [TextSpan(text: 'void')],
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    style: _title.paled(),
                    children: [TextSpan(text: 'main')],
                  ),
                  TextSpan(text: ''),
                  TextSpan(
                    style: _params.paled(),
                    children: [TextSpan(text: '()')],
                  ),
                  TextSpan(text: ' '),
                ],
              ),
              TextSpan(text: '{ '),
              TextSpan(
                style: _comment.paled(),
                children: [TextSpan(text: '')],
              ),
              TextSpan(text: '\n'),
              TextSpan(text: '  }\n'),
              TextSpan(text: '}\n'),
              TextSpan(text: ''),
            ],
          ),
        ),
      ];

      for (final example in examples) {
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
        );

        final builder = SpanBuilder(code: code, theme: _themeData);
        final result = builder.build();

        expect(
          result,
          example.expected,
          reason: example.name,
        );
      }
    });
  });
}

class _Example {
  final String name;
  final String text;
  final Mode? mode;
  final TextSpan expected;

  _Example(
    this.name, {
    required this.text,
    required this.mode,
    required this.expected,
  });
}
