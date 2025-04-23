import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart';

abstract class Autocompleter {
  Mode? mode;
  List<String> blacklist = [];

  Autocompleter();

  void setText(Object key, String? text);

  Future<List<SuggestionItem>> getSuggestionItems(TextEditingValue value);

  TextEditingValue? replaceText(
    TextSelection selection, TextEditingValue value, SuggestionItem item,
  );
}

class SuggestionItem {
  final String text;
  final String displayText;
  final dynamic data;

  SuggestionItem({
    required this.text,
    required this.displayText,
    this.data,
  });
}
