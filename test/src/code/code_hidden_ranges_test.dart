import 'package:flutter_code_editor/src/code/code.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_range.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_ranges.dart';
import 'package:flutter_code_editor/src/named_sections/parsers/brackets_start_end.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart';

final _language = java;
const _text = '''
public class MyClass { // comment
  public void main() { // [START section1]
  } // comment readonly
}
''';

void main() {
  late Code code;

  setUp(() {
    final highlighted = highlight.parse(_text, language: 'java');
    code = Code(
      text: _text,
      highlighted: highlighted,
      namedSectionParser: const BracketsStartEndNamedSectionParser(),
      readOnlySectionNames: {'section1', 'nonexistent'},
      language: _language,
    );
  });

  group('Code. Hidden ranges.', () {
    test('Section comments and readonly are parsed to hidden ranges', () {
      expect(
        code.hiddenRanges,
        HiddenRanges(
          ranges: const [
            // '// [START section1]'
            HiddenRange(
              57,
              76,
              firstLine: 1,
              lastLine: 1,
              wholeFirstLine: false,
            ),

            // '// comment readonly'
            HiddenRange(
              81,
              100,
              firstLine: 2,
              lastLine: 2,
              wholeFirstLine: false,
            ),
          ],
          textLength: _text.length,
        ),
      );

      expect(
        code.visibleHighlighted!.toHtml(),
        '''
<span class="hljs-keyword">public</span> <span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">MyClass</span> </span>{ <span class="hljs-comment">// comment</span>
  <span class="hljs-function"><span class="hljs-keyword">public</span> <span class="hljs-keyword">void</span> <span class="hljs-title">main</span><span class="hljs-params">()</span> </span>{ <span class="hljs-comment"></span>
  } <span class="hljs-comment"></span>
}
''',
      );
    });

    test('foldableBlockToHiddenRange', () {
      final hiddenRange = code.foldableBlockToHiddenRange(
        code.foldableBlocks[1],
      );

      // '\n} // comment readonly'
      expect(
        hiddenRange,
        const HiddenRange(
          76,
          100,
          firstLine: 1,
          lastLine: 2,
          wholeFirstLine: false,
        ),
      );
    });
  });
}
