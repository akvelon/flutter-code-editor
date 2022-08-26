import 'package:autotrie/autotrie.dart';
import 'package:highlight/highlight_core.dart';

import '../code/reg_exp.dart';

/// Accumulates textual data and suggests autocompletion based on it.
class Autocompleter {
  Mode? _mode;
  final _customAutocomplete = AutoComplete(engine: SortEngine.entriesOnly());
  final _keywordsAutocomplete = AutoComplete(engine: SortEngine.entriesOnly());
  final _textAutocompletes = <Object, AutoComplete>{};
  final _lastTexts = <Object, String>{};
  Set<String> _blacklistSet = const {};

  static final _whitespacesRe = RegExp(r'\s+');

  /// The language to automatically extract keywords from.
  Mode? get mode => _mode;

  set mode(Mode? value) {
    _mode = value;
    _parseKeywords();
  }

  void _parseKeywords() {
    _keywordsAutocomplete.clearEntries();

    final keywords = mode?.keywords;
    if (keywords == null) {
      return;
    }

    if (keywords is String) {
      _parseStringKeywords(keywords);
    } else if (keywords is Map<String, String>) {
      _parseStringStringKeywords(keywords);
    } else {
      throw Exception(
        'Unknown keywords type: ${keywords.runtimeType}, $keywords',
      );
    }
  }

  void _parseStringKeywords(String keywords) {
    _keywordsAutocomplete.enterList(
      [...keywords.split(_whitespacesRe).where((k) => k.isNotEmpty)],
    );
  }

  void _parseStringStringKeywords(Map<String, String> map) {
    map.values.forEach(_parseStringKeywords);
  }

  /// The words to exclude from suggestions if they are otherwise present.
  List<String> get blacklist => _blacklistSet.toList(growable: false);

  set blacklist(List<String> value) {
    _blacklistSet = {...value};
  }

  /// Sets the [text] to parse all words from.
  /// Multiple texts are supported, each with its own [key].
  /// Use this to set current texts from multiple controllers.
  void setText(Object key, String? text) {
    if (text == null) {
      _textAutocompletes.remove(key);
      _lastTexts.remove(key);
      return;
    }

    if (text == _lastTexts[key]) {
      return;
    }

    final ac = _getOrCreateTextAutoComplete(key);
    _updateText(ac, text);
    _lastTexts[key] = text;
  }

  AutoComplete _getOrCreateTextAutoComplete(Object key) {
    return _textAutocompletes[key] ?? _createTextAutoComplete(key);
  }

  AutoComplete _createTextAutoComplete(Object key) {
    final result = AutoComplete(engine: SortEngine.entriesOnly());
    _textAutocompletes[key] = result;
    return result;
  }

  void _updateText(AutoComplete ac, String text) {
    ac.clearEntries();
    ac.enterList(
      text
          .split(RegExps.wordSplit)
          .where((t) => t.isNotEmpty)
          .toList(growable: false),
    );
  }

  /// Sets additional words to suggest.
  /// Fill this with your library's symbols.
  void setCustomWords(List<String> words) {
    _customAutocomplete.clearEntries();
    _customAutocomplete.enterList(words);
  }

  Future<List<String>> getSuggestions(String prefix) async {
    final result = {
      ..._customAutocomplete.suggest(prefix),
      ..._keywordsAutocomplete.suggest(prefix),
      ..._textAutocompletes.values
          .map((ac) => ac.suggest(prefix))
          .expand((e) => e),
    }.where((e) => !_blacklistSet.contains(e)).toList(growable: false);

    result.sort();
    return result;
  }
}
