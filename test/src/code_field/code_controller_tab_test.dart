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

  const namedSectionsWithTabs = '''
class MyClass {
	void readOnlyMethod() {// [START section1]
	}// [END section1]
	// [START section2]
	void method() {
	}// [END section2]
}
''';

  const namedSectionsWithDoubleSpaces = '''
class MyClass {
  void readOnlyMethod() {// [START section1]
  }// [END section1]
  // [START section2]
  void method() {
  }// [END section2]
}
''';

  bool areIdenticalTexts(String text1, String text2) {
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
          areIdenticalTexts(controller.text, snippetWithDoubleSpaces),
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
          areIdenticalTexts(controller.text, snippetWithDoubleSpaces),
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
          areIdenticalTexts(controller.text, snippetWithTripleSpaces),
          true,
        );
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
        areIdenticalTexts(
          controller.text,
          snippetWithDoubleSpaces +
              ' ' * controller.params.tabSpaces * tabCount,
        ),
        true,
      );
    });

    test('works with insertion code containing named blocks', () {
      final controller = CodeController(
        text: snippetWithTabs,
        language: java,
        modifiers: [const TabModifier()],
      );
      controller.value = const TextEditingValue(
        text: '$snippetWithDoubleSpaces\n$namedSectionsWithTabs',
        selection: TextSelection.collapsed(offset: 0),
      );
      expect(
        areIdenticalTexts(
          controller.text,
          '$snippetWithDoubleSpaces\n$namedSectionsWithDoubleSpaces',
        ),
        true,
      );
    });
  });
}
