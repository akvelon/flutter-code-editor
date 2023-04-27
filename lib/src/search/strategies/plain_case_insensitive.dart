import '../match.dart';
import '../result.dart';
import '../settings.dart';
import 'abstract.dart';

class PlainCaseInsensitiveSearchStrategy extends SearchStrategy {
  @override
  SearchResult searchPlain(String text, {required SearchSettings settings}) {
    final lowerCaseText = text.toLowerCase();
    final lowerCasePattern = settings.pattern.toLowerCase();
    final matches = lowerCasePattern
        .allMatches(
          lowerCaseText,
        )
        .map((e) => SearchMatch(start: e.start, end: e.end))
        .toList(growable: false);

    return SearchResult(matches: matches);
  }
}
