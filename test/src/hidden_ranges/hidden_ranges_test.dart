import 'package:code_text_field/src/hidden_ranges/hidden_range.dart';
import 'package:code_text_field/src/hidden_ranges/hidden_ranges.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight.dart';

const _text = '''
public class MyClass {
  public void main() { // comment
  }
}
''';

final _hiddenRanges = HiddenRanges(
  ranges: const [
    HiddenRange(start: 1, end: 1, text: ''),
    HiddenRange(start: 9, end: 11, text: 'as'),
    HiddenRange(start: 40, end: 61, text: 'n() { // comment\n  }\n'),
  ],
  textLength: _text.length,
);

const _cut = '''
public cls MyClass {
  public void mai}
''';

void main() {
  group('HiddenRanges.', () {
    test('Empty ranges are not stored', () {
      expect(
        HiddenRanges(
          ranges: const [
            HiddenRange(start: 1, end: 4, text: '123'),
            HiddenRange(start: 7, end: 7, text: ''),
          ],
          textLength: _text.length,
        ),
        HiddenRanges(
          ranges: const [
            HiddenRange(start: 1, end: 4, text: '123'),
          ],
          textLength: _text.length,
        ),
      );
    });

    test('Ranges cannot overlap', () {
      expect(
        () => HiddenRanges(
          ranges: const [
            HiddenRange(start: 0, end: 3, text: '012'),
            HiddenRange(start: 1, end: 4, text: '123'),
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
            HiddenRange(start: 2, end: 4, text: '23'),
            HiddenRange(start: 7, end: 9, text: '78'),
            HiddenRange(start: 10, end: 13, text: 'ABC'),
          ],
          textLength: 777,
        );

        expect(ranges.hiddenCharactersBeforeRanges, [0, 2, 4, 7]);
      });
    });

    test('cutString', () {
      final examples = [
        _CutStringExample(
          name: 'Empty changes nothing (shortcut return)',
          hiddenTexts: HiddenRanges.empty,
          text: _text,
          start: 123,
          result: _text,
        ),
        _CutStringExample(
          name: 'Cuts full string '
              '(break with "rangeIndex < ranges.length" == false)',
          hiddenTexts: _hiddenRanges,
          text: _text,
          start: 0,
          result: _cut,
        ),
        _CutStringExample(
          name: 'Cuts a substring starting before and ending in a hidden range',
          hiddenTexts: _hiddenRanges,
          text: 'la',
          start: 8,
          result: 'l',
        ),
        _CutStringExample(
          name: 'Cuts a substring starting in and ending after a hidden range',
          hiddenTexts: _hiddenRanges,
          text: 'ss',
          start: 10,
          result: 's',
        ),
        _CutStringExample(
          name: 'Cuts a substring not starting or ending in hidden range '
              '(break with "substringStart < end" == false',
          hiddenTexts: _hiddenRanges,
          text: 'class MyClass {',
          start: 7,
          result: 'cls MyClass {',
        ),
        _CutStringExample(
          name: 'Cuts a substring starting and ending in 2 hidden ranges '
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
      test('Cuts inner text for hidden parts, keeps the tags', () {
        final highlighted = highlight.parse(_text, language: 'java');

        final result = _hiddenRanges.cutHighlighted(highlighted);
        final html = result.toHtml();

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

  _CutStringExample({
    required this.name,
    required this.hiddenTexts,
    required this.text,
    required this.start,
    required this.result,
  });
}
