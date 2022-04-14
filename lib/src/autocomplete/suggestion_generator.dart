import 'dart:convert';

import 'package:autotrie/autotrie.dart';
import 'package:code_text_field/src/autocomplete/suggestion.dart';
import 'package:flutter/services.dart';

class SuggestionGenerator {
  RegExp identifierRegex = RegExp(r'^[_a-zA-Z0-9]+$');
  RegExp splitRegex = RegExp(r'[^_a-zA-Z0-9]+');
  String? languageID;
  final AutoComplete autoCompleteLanguage = AutoComplete(engine: SortEngine.entriesOnly());
  final AutoComplete autoCompleteUser = AutoComplete(engine: SortEngine.entriesOnly());
  final AutoComplete autoCompleteSnipplets = AutoComplete(engine: SortEngine.entriesOnly());
  late int cursorPosition;
  late String text;

  SuggestionGenerator(this.languageID) {
    this.cursorPosition = 0;
    this.text = '';
    initDictionary();
  }

  Future<Map<String, dynamic>> getConfig() async {
    String config = await rootBundle
        .loadString('packages/code_text_field/assets/keywords/dart.json');
    Map<String, dynamic> jsonConfig = jsonDecode(config);
    return jsonConfig;
  }

  List<String> getKeywords(Map<String, dynamic> config) {
    return config['keywords'].toString().split(' ');
  }

  List<String> getSnipplets(Map<String, dynamic> config) {
    return <String>[...config['snipplets']];
  }

  /// Placeholder for dictionary initialization using json resource files for the given language
  void initDictionary() async {
    Map<String, dynamic> jsonConfig = await getConfig();

    List<String> keywords = getKeywords(jsonConfig);
    List<String> snipplets = getSnipplets(jsonConfig);

    keywords.forEach((String element) {
      autoCompleteLanguage.enter(element);
    });

    snipplets.forEach((String element) {
      autoCompleteSnipplets.enter(element);
    });
  }

  List<Suggestion> getSuggestions(String text, int cursorPosition) {
    this.cursorPosition = cursorPosition;
    this.text = text;
    String prefix = getCurrentWordPrefix();
    if (prefix.isEmpty) {
      return <Suggestion>[];
    }
    _parseText();
    List<Suggestion> suggestions = <Suggestion>[];
    suggestions += autoCompleteUser
        .suggest(prefix)
        .map((String word) => Suggestion(word, SuggestionType.local))
        .toList();
    suggestions += autoCompleteLanguage
        .suggest(prefix)
        .map((String word) => Suggestion(word, SuggestionType.language))
        .toList();
    suggestions += autoCompleteSnipplets
        .suggest(prefix)
        .map((String word) => Suggestion(word, SuggestionType.snippet))
        .toList();
    return suggestions;
  }

  /// Returns the prefix of an identifier or a keyword that is pointed to by the cursor
  String getCurrentWordPrefix() {
    String prefix = '';
    int characterPosition = cursorPosition - 1;
    while (characterPosition >= 0 &&
        identifierRegex.hasMatch(text[characterPosition] + prefix)) {
      prefix = text[characterPosition] + prefix;
      characterPosition--;
    }
    return prefix;
  }

  /// Returns the suffix of an identifier or a keyword that is pointed to by the cursor
  String _getCurrentWordSuffix() {
    String suffix = '';
    int characterPosition = cursorPosition;
    while (characterPosition < text.length &&
        identifierRegex.hasMatch(suffix + text[characterPosition])) {
      suffix = suffix + text[characterPosition];
      characterPosition++;
    }
    return suffix;
  }

  /// Parses text - gets user keywords and adds them into user trie
  void _parseText() {
    List<String> list = _getTextKeywords();
    list.forEach((String element) {
      autoCompleteUser.enter(element);
    });
    _filterTextKeywords();
  }

  /// Delete from trie keywords that are not currently in editor text
  void _filterTextKeywords() {
    List<String> keywords = _getTextKeywords();
    final List<String> userKeyWords = autoCompleteUser.allEntries.toList();
    final List<String> notInText =
        userKeyWords.where((String element) => !keywords.contains(element)).toList();
    notInText.forEach((String element) {
      autoCompleteUser.delete(element);
    });
  }

  /// Returns keywords from text
  List<String> _getTextKeywords() {
    String processedText = _excludeCurrentWord();
    List<String> keywords = processedText.split(splitRegex);
    keywords.removeWhere((String el) => el.isEmpty == true);
    keywords.removeWhere(
        (String el) => autoCompleteLanguage.allEntries.toList().contains(el));
    keywords
        .removeWhere((String element) => !element.startsWith(RegExp(r'[a-zA-Z_]')));
    keywords = keywords.toSet().toList();
    return keywords;
  }

  /// Returns text without the word pointed to by the cursor
  String _excludeCurrentWord() {
    return text.replaceRange(cursorPosition - getCurrentWordPrefix().length,
        cursorPosition + _getCurrentWordSuffix().length, '');
  }
}
