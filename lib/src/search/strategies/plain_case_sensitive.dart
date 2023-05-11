import '../match.dart';
import '../result.dart';
import '../settings.dart';
import 'abstract.dart';

class PlainCaseSensitiveSearchStrategy extends SearchStrategy {
  @override
  SearchResult searchPlain(String text, {required SearchSettings settings}) {
    final matches = settings.pattern
        .allMatches(
          text,
        )
        .map((match) => SearchMatch(start: match.start, end: match.end))
        .toList(growable: false);

    return SearchResult(matches: matches);
  }
}
