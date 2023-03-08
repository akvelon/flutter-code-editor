import 'package:flutter_code_editor/src/hidden_ranges/hidden_range.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_ranges.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight_core.dart';

const _text = '''
public class MyClass {
  public void main() { // comment
  }
}
''';

final _hiddenRanges = HiddenRanges(
  ranges: const [
    // 'as'
    HiddenRange(9, 11, firstLine: 0, lastLine: 0, wholeFirstLine: false),

    // 'n() { // comment\n  }\n'
    HiddenRange(40, 61, firstLine: 1, lastLine: 1, wholeFirstLine: false),
  ],
  textLength: _text.length,
);

const _cut = '''
public cls MyClass {
  public void mai}
''';

void main() {
  group('HiddenRanges.', () {
    test('Ranges cannot overlap', () {
      expect(
        () => HiddenRanges(
          ranges: const [
            HiddenRange(0, 3, firstLine: 0, lastLine: 0, wholeFirstLine: false),
            HiddenRange(1, 4, firstLine: 0, lastLine: 0, wholeFirstLine: false),
          ],
          textLength: _text.length,
        ),
        throwsAssertionError,
      );
    });

    group('hiddenCharactersBeforeRanges', () {
      test('0-array if no ranges', () {
        expect(
          HiddenRanges(
            ranges: const [],
            textLength: 5,
          ).hiddenCharactersBeforeRanges,
          const [0],
        );
        expect(
          HiddenRanges.empty.hiddenCharactersBeforeRanges,
          const [0],
        );
      });

      test('Valid array if has ranges', () {
        final ranges = HiddenRanges(
          ranges: const [
            HiddenRange(2, 4, firstLine: 0, lastLine: 0, wholeFirstLine: true),
            HiddenRange(6, 8, firstLine: 0, lastLine: 0, wholeFirstLine: true),
            HiddenRange(9, 12, firstLine: 0, lastLine: 0, wholeFirstLine: true),
          ],
          textLength: 777,
        );

        expect(ranges.hiddenCharactersBeforeRanges, [0, 2, 4, 7]);
      });
    });

    test('cutString', () {
      final examples = [
        _CutStringExample(
          'Empty changes nothing (shortcut return)',
          hiddenTexts: HiddenRanges.empty,
          text: _text,
          start: 123,
          result: _text,
        ),
        _CutStringExample(
          'Cuts full string (break with "rangeIndex < ranges.length" == false)',
          hiddenTexts: _hiddenRanges,
          text: _text,
          start: 0,
          result: _cut,
        ),
        _CutStringExample(
          'Cuts a substring starting before and ending in a hidden range',
          hiddenTexts: _hiddenRanges,
          text: 'la',
          start: 8,
          result: 'l',
        ),
        _CutStringExample(
          'Cuts a substring starting in and ending after a hidden range',
          hiddenTexts: _hiddenRanges,
          text: 'ss',
          start: 10,
          result: 's',
        ),
        _CutStringExample(
          'Cuts a substring not starting or ending in hidden range '
          '(break with "substringStart < end" == false',
          hiddenTexts: _hiddenRanges,
          text: 'class MyClass {',
          start: 7,
          result: 'cls MyClass {',
        ),
        _CutStringExample(
          'Cuts a substring starting and ending in 2 hidden ranges '
          '(break with "substringStart < end" == false',
          hiddenTexts: _hiddenRanges,
          text: 'ss MyClass {\n  public void main() { // com',
          start: 10,
          result: 's MyClass {\n  public void mai',
        ),
      ];

      for (final example in examples) {
        final result = example.hiddenTexts.cutString(
          example.text,
          start: example.start,
        );

        expect(result, example.result, reason: example.name);
      }
    });

    group('cutHighlighted.', () {
      test('null -> null', () {
        final result = _hiddenRanges.cutHighlighted(null);

        expect(result, null);
      });

      test('Cuts inner text for hidden parts, keeps the tags', () {
        final highlighted = highlight.parse(_text, language: 'java');

        final result = _hiddenRanges.cutHighlighted(highlighted);
        final html = result?.toHtml();

        expect(
          html,
          '<span class="hljs-keyword">public</span> <span class="hljs-class"><span class="hljs-keyword">cls</span> <span class="hljs-title">MyClass</span> </span>{\n'
          '  <span class="hljs-function"><span class="hljs-keyword">public</span> <span class="hljs-keyword">void</span> <span class="hljs-title">mai</span><span class="hljs-params"></span></span><span class="hljs-comment"></span>}\n',
        );
      });
    });
  });
}

class _CutStringExample {
  final String name;
  final HiddenRanges hiddenTexts;
  final String text;
  final int start;
  final String result;

  _CutStringExample(
    this.name, {
    required this.hiddenTexts,
    required this.text,
    required this.start,
    required this.result,
  });
}
