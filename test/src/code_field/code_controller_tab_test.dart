import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/java.dart';

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

  group('Tab replacement', () {
    test(
      'applied if TabModifier is present',
      () {
        final controller = CodeController(
          text: snippetWithTabs,
          language: go,
          modifiers: [const TabModifier()],
        );
        expect(controller.text, snippetWithDoubleSpaces);
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
        expect(controller.text, snippetWithTabs);
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
        expect(controller.text, snippetWithTripleSpaces);
      },
    );

    test('works with several tab insertion', () {
      final controller = CodeController(
        text: snippetWithTabs,
        language: java,
        modifiers: [const TabModifier()],
      );
      const tabCount = 2;

      controller.value = TextEditingValue(
        text: snippetWithTabs + '\t' * tabCount,
        selection: const TextSelection.collapsed(offset: 0),
      );

      expect(
        controller.text,
        snippetWithDoubleSpaces + ' ' * controller.params.tabSpaces * tabCount,
      );
    });
  });
}
