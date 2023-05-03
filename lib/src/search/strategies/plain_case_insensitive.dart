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
        .where((match) => match.start != match.end)
        .map((match) => SearchMatch(start: match.start, end: match.end))
        .toList(growable: false);

    return SearchResult(matches: matches);
  }
}
