import 'package:flutter_code_editor/src/code/code.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_range.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_ranges.dart';
import 'package:flutter_code_editor/src/named_sections/parsers/brackets_start_end.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/java.dart';

void main() {
  group('Code. HiddenRanges.', () {
    test('Section comments and readonly are parsed to hidden ranges', () {
      const text = '''
public class MyClass { // comment
  public void main() { // [START section1]
  } // comment readonly
}
''';

      final highlighted = highlight.parse(text, language: 'java');
      final code = Code(
        text: text,
        highlighted: highlighted,
        namedSectionParser: const BracketsStartEndNamedSectionParser(),
        readOnlySectionNames: {'section1', 'nonexistent'},
        language: java,
      );

      expect(
        code.hiddenRanges,
        HiddenRanges(
          ranges: const [
            HiddenRange(start: 57, end: 76, text: '// [START section1]'),
            HiddenRange(start: 81, end: 100, text: '// comment readonly'),
          ],
          textLength: text.length,
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
  });
}
