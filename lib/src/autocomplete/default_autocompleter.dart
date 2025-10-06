import 'package:autotrie/autotrie.dart';
import 'package:flutter/material.dart';
import 'package:highlight/highlight_core.dart';

import '../code/reg_exp.dart';
import '../code_field/text_editing_value.dart';
import '../util/string_util.dart';
import 'autocompleter.dart';

/// Accumulates textual data and suggests autocompletion based on it.
class DefaultAutocompleter extends Autocompleter {
  Mode? _mode;
  final _customAutocomplete = AutoComplete(engine: SortEngine.entriesOnly());
  final _keywordsAutocomplete = AutoComplete(engine: SortEngine.entriesOnly());
  final _textAutocompletes = <Object, AutoComplete>{};
  final _lastTexts = <Object, String>{};
  Set<String> _blacklistSet = const {};
  String text = '';

  static final _whitespacesRe = RegExp(r'\s+');
  
  DefaultAutocompleter();

  /// The language to automatically extract keywords from.
  @override
  Mode? get mode => _mode;
  @override
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
    } else if (keywords is Map<String, dynamic>) {
      _parseStringDynamicKeywords(keywords);
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

  void _addKeywords(Iterable<String> keywords) {
    _keywordsAutocomplete.enterList(
      keywords.where((k) => k.isNotEmpty).toList(growable: false),
    );
  }

  void _parseStringStringKeywords(Map<String, String> map) {
    map.values.forEach(_parseStringKeywords);
  }

  void _parseStringDynamicKeywords(Map<String, dynamic> map) {
    _addKeywords(map.keys);
  }

  /// The words to exclude from suggestions if they are otherwise present.
  @override
  List<String> get blacklist => _blacklistSet.toList(growable: false);

  @override
  set blacklist(List<String> value) {
    _blacklistSet = {...value};
  }

  /// Sets the [text] to parse all words from.
  /// Multiple texts are supported, each with its own [key].
  /// Use this to set current texts from multiple controllers.
  @override
  void setText(Object key, String? text) {
    this.text = text ?? '';
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
          // https://github.com/akvelon/flutter-code-editor/issues/61
          //.split(RegExps.wordSplit)
          .split(RegExp(RegExps.wordSplit.pattern))
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

  @override
  Future<List<SuggestionItem>> getSuggestionItems(TextEditingValue value) async {
    final prefix = value.wordToCursor;
    if (prefix == null) {
      return [];
    }

    final result = await getSuggestions(prefix);

    return result
      .map((e) => SuggestionItem(text: e, displayText: e))
      .toList();
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


  @override
  TextEditingValue? replaceText(
    TextSelection selection,
    TextEditingValue value,
    SuggestionItem item,
  ) {
    final previousSelection = selection;
    final selectedWord = item.text;
    final startPosition = value.wordAtCursorStart;
    final currentWord = value.wordAtCursor;

    if (startPosition == null || currentWord == null) {
      return null;
    }

    final endReplacingPosition = startPosition + currentWord.length;
    final endSelectionPosition = startPosition + selectedWord.length;

    var additionalSpaceIfEnd = '';
    var offsetIfEndsWithSpace = 1;
    if (text.length < endReplacingPosition + 1) {
      additionalSpaceIfEnd = ' ';
    } else {
      final charAfterText = text[endReplacingPosition];
      if (charAfterText != ' ' &&
          !StringUtil.isDigit(charAfterText) &&
          !StringUtil.isLetterEng(charAfterText)) {
        // ex. case ';' or other finalizer, or symbol
        offsetIfEndsWithSpace = 0;
      }
    }

    final replacedText = text.replaceRange(
      startPosition,
      endReplacingPosition,
      '$selectedWord$additionalSpaceIfEnd',
    );

    final adjustedSelection = previousSelection.copyWith(
      baseOffset: endSelectionPosition + offsetIfEndsWithSpace,
      extentOffset: endSelectionPosition + offsetIfEndsWithSpace,
    );

    return TextEditingValue(
      text: replacedText,
      selection: adjustedSelection,
    );
  }
}
