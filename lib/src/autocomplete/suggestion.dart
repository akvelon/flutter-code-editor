class Suggestion {
  late String word;
  late SuggestionType type;

  Suggestion(this.word, this.type);
}

enum SuggestionType { local, language, snippet }
