import '../result.dart';
import '../search_algorithm.dart';
import '../settings.dart';
import 'abstract.dart';

class PlainCaseSensitiveSearchStrategy extends SearchStrategy {
  @override
  SearchResult searchPlain(String text, {required SearchSettings settings}) {
    return text.kmpSearch(
      settings.pattern,
      isCaseSensitive: true,
    );
  }
}
