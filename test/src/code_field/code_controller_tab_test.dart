import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/symbols.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/go.dart';

void main() {
  const textWithTabs = '''
public class MyClass {
\tpublic void main() {\t\t
\t}\t
}\t
\t
''';

  group('Tab replacement', () {
    test(
      'applied if TabModifier is present',
      () {
        final controller = CodeController(
          text: textWithTabs,
          language: go,
          modifiers: [const TabModifier()],
        );
        expect(controller.fullText.contains(Symbols.tab), false);
      },
    );

    test(
      'not applied if TabModifier is not present',
      () {
        final controller = CodeController(
          text: textWithTabs,
          language: go,
          modifiers: [],
        );
        expect(controller.fullText.contains(Symbols.tab), true);
      },
    );
  });
}
