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
        .map((e) => SearchMatch(start: e.start, end: e.end))
        .toList(growable: false);

    return SearchResult(matches: matches);
  }
}
