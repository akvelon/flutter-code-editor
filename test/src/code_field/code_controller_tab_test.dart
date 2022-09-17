import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/go.dart';

void main() {
  const snippetWithTabs = '''
public class MyClass {
\tpublic void main() {
\t}
}
''';
  const snippetWithDoubleSpaces = '''
public class MyClass {
  public void main() {
  }
}
''';
  const snippetWithTripleSpaces = '''
public class MyClass {
   public void main() {
   }
}
''';

  bool _areIdenticalTexts(String text1, String text2) {
    return text1.compareTo(text2) == 0;
  }

  group('Tab replacement', () {
    test(
      'applied if TabModifier is present',
      () {
        final controller = CodeController(
          text: snippetWithTabs,
          language: go,
          modifiers: [const TabModifier()],
        );
        expect(
          _areIdenticalTexts(controller.text, snippetWithDoubleSpaces),
          true,
        );
      },
    );

    test(
      'not applied if TabModifier is not present',
      () {
        final controller = CodeController(
          text: snippetWithTabs,
          language: go,
          modifiers: [],
        );
        expect(
          _areIdenticalTexts(controller.text, snippetWithDoubleSpaces),
          false,
        );
      },
    );

    test(
      'works with custom tabSpaces',
      () {
        const tabSpaces = 3;
        final controller = CodeController(
          params: const EditorParams(tabSpaces: tabSpaces),
          text: snippetWithTabs,
          language: go,
          modifiers: [const TabModifier()],
        );
        expect(
          _areIdenticalTexts(controller.text, snippetWithTripleSpaces),
          true,
        );
      },
    );
  });
}
