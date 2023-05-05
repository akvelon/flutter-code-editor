import '../result.dart';
import '../settings.dart';

abstract class SearchStrategy {
  SearchResult searchPlain(String text, {required SearchSettings settings});
}
