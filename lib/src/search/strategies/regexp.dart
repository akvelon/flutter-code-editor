import '../../../flutter_code_editor.dart';
import 'abstract.dart';

class RegExpSearchStrategy extends SearchStrategy {
  @override
  SearchResult searchPlain(String text, {required SearchSettings settings}) {
    final regex = RegExp(settings.pattern);
    final matches = regex.allMatches(text);
    final searchMatches = matches
        .map<SearchMatch>(
          (e) => SearchMatch(
            start: e.start,
            end: e.end,
          ),
        )
        .toList(growable: false);
    return SearchResult(matches: searchMatches);
  }
}
