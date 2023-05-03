import '../match.dart';
import '../result.dart';
import '../settings.dart';
import 'abstract.dart';

class RegExpSearchStrategy extends SearchStrategy {
  @override
  SearchResult searchPlain(String text, {required SearchSettings settings}) {
    try {
      final regex = RegExp(
        settings.pattern,
        multiLine: true,
        caseSensitive: settings.isCaseSensitive,
      );

      final matches = regex
          .allMatches(text)
          .where((match) => match.start != match.end)
          .map((match) => SearchMatch(start: match.start, end: match.end));
      final searchMatches = matches.toList(growable: false);
      return SearchResult(matches: searchMatches);
    } on Exception {
      return SearchResult.empty;
    }
  }
}
