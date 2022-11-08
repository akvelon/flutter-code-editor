import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/snippets.dart';

void main() {
  group('CodeController Read-only Sections', () {
    test('No sections -> All editable', () {
      final sectionGroups = <Set<String>>[
        {},
        {'nonexistent'},
      ];

      for (final sections in sectionGroups) {
        final controller = CodeController(
          text: TwoMethodsSnippet.full,
          language: TwoMethodsSnippet.mode,
          namedSectionParser: const BracketsStartEndNamedSectionParser(),
          readOnlySectionNames: sections,
        );

        final readonly = controller.code.lines.lines.map((l) => l.isReadOnly);
        expect(
          readonly,
          List<bool>.filled(controller.code.lines.lines.length, false),
          reason: '$sections',
        );
      }
    });

    test('Initial, changing', () {
      int notifiedCount = 0;
      final controller = CodeController(
        text: TwoMethodsSnippet.full,
        language: TwoMethodsSnippet.mode,
        namedSectionParser: const BracketsStartEndNamedSectionParser(),
        readOnlySectionNames: {'section1'},
      );
      controller.addListener(() {
        notifiedCount++;
      });

      final readonly1 = controller.code.lines.lines.map((l) => l.isReadOnly);
      expect(
        readonly1,
        [
          false,
          false,
          true,
          true,
          true,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
        ],
      );
      expect(
        controller.readOnlySectionNames,
        {'section1'},
      );

      controller.readOnlySectionNames = {'section2', 'nonexistent2'};

      final readonly2 = controller.code.lines.lines.map((l) => l.isReadOnly);
      expect(
        readonly2,
        [
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          true,
          true,
          true,
          false,
          false,
        ],
      );

      expect(notifiedCount, 1);

      expect(
        controller.readOnlySectionNames,
        {'section2', 'nonexistent2'},
      );
    });
  });
}
