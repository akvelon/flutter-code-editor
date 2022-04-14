import 'package:flutter/material.dart';

class MultilineController {
  List<int> carets = [];
  late int currentSelection = 0;
  bool isCaret = false;
  bool isMutli = false;

  MultilineController() : super();

  TextEditingValue updateMultiline(
      TextEditingValue value, TextEditingValue newValue) {
    bool isDeleting = newValue.text.length < value.text.length;
    bool isInserting = newValue.text.length > value.text.length;
    if (this.isMutli) {
      if (isDeleting || (isInserting && !isCaret)) {
        int diff = newValue.text.length - value.text.length;
        String newText = newValue.text;
        int start = newValue.selection.start - diff;

        String insertedValue =
            diff > 0 ? newText.substring(start, start + diff) : "";

        for (int i = 0; i < carets.length; i++) {
          if (carets[i] >= currentSelection) {
            carets[i] += diff;
          }
        }

        carets.sort();

        for (int i = 0; i < carets.length; i++) {
          newText = newText.replaceRange(
              carets[i] - (diff > 0 ? 0 : 1), carets[i], insertedValue);

          carets[i] += diff;

          if (isDeleting) {
            bool isThisCaretCollide = carets.any((caret) =>
                    (carets[i] == caret && i != carets.indexOf(caret))) ||
                carets[i] == newValue.selection.start ||
                carets[i] == newValue.selection.start - 1;

            if (isThisCaretCollide) {
              newText = newText.replaceRange(carets[i] - 2, carets[i] - 1, "");
              carets[i] = -1;
            }
          }

          if (i + 1 != carets.length) {
            carets[i + 1] += diff * (i + 1);
          }
        }

        carets = carets.where((i) => i != -1).toList();

        int newOffSet =
            carets.where((pos) => pos <= currentSelection).length * diff;

        newValue = newValue.copyWith(
            selection: newValue.selection.copyWith(
                baseOffset: newValue.selection.start + newOffSet,
                extentOffset: newValue.selection.start + newOffSet),
            text: newText.toString());
      }
      this.isCaret = false;
    }
    return newValue;
  }

  TextEditingValue clearCarets(TextEditingValue value) {
    if (carets.isEmpty) {
      return value;
    }

    this.isMutli = false;
    String clearedText = value.text;
    carets.sort();

    for (int i = 0; i < carets.length; i++) {
      clearedText = clearedText.replaceRange(carets[i], carets[i] + 1, "");
      if (i + 1 != carets.length) {
        carets[i + 1] -= i + 1;
      }
    }

    value = value.copyWith(
        text: clearedText,
        selection: value.selection.copyWith(
            baseOffset: value.selection.start - carets.length,
            extentOffset: value.selection.start - carets.length));
    carets.clear();

    return value;
  }

  TextEditingValue insertCaret(TextEditingValue value) {
    final sel = value.selection;
    if (this.carets.contains(sel.start) ||
        this.carets.contains(sel.start - 1) ||
        value.selection.start == currentSelection) {
      return value;
    }

    if (value.text.length == 0) {
      currentSelection = 0;
    }

    int isAbove = currentSelection < value.selection.start ? 1 : 0;

    for (int i = 0; i < carets.length; i++) {
      if (carets[i] >= currentSelection) {
        carets[i] += 1;
      }
    }

    carets.add(currentSelection);

    value = value.copyWith(
        text: value.text.replaceRange(currentSelection, currentSelection, "|"),
        selection: sel.copyWith(
          baseOffset: sel.start + isAbove,
          extentOffset: sel.start + isAbove,
        ));
    currentSelection = value.selection.start;

    return value;
  }

  void updateCurrentSelection(int newSelection, int selection) {
    if (newSelection != selection || currentSelection == -1) {
      currentSelection = selection;
    }
  }
}
