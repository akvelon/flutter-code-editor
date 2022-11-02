import '../../flutter_code_editor.dart';
import '../folding/parsers/indent.dart';

class VisibleSection extends NamedSection {
  final int characterIndex;
  final int? lastCharacterIndex;
  
  const VisibleSection({
    required super.startLine,
    required super.endLine,
    required super.name,
    required this.characterIndex,
    required this.lastCharacterIndex,
  });

  VisibleSection.fromLineAndNamedSection({
    required int startCharacterIndex,
    required int? endCharacterIndex,
    required NamedSection namedSection,
  }) : this(
          startLine: namedSection.startLine,
          endLine: namedSection.endLine,
          name: namedSection.name,
          characterIndex: startCharacterIndex,
          lastCharacterIndex: endCharacterIndex,
        );
}

extension VisibleSectionListFromNamed on Map<String, NamedSection> {
  Iterable<VisibleSection> toVisibleSections({
    required List<CodeLine> lines,
    required Set<String> visibleSectionsNames,
  }) {
    return getByKeys(visibleSectionsNames).map(
      (section) {
        final startLine = lines[section.startLine];
        final endLine =
            section.endLine != null ? lines[section.endLine!] : null;
        return VisibleSection.fromLineAndNamedSection(
          namedSection: section,
          startCharacterIndex: startLine.textRange.start,
          endCharacterIndex: endLine?.textRange.end,
        );
      },
    );
  }
}
