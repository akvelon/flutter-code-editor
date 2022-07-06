import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlight/highlight_core.dart';

import '../code_modifiers/close_block_code_modifier.dart';
import '../code_modifiers/code_modifier.dart';
import '../code_modifiers/indent_code_modifier.dart';
import '../code_modifiers/tab_code_modifier.dart';
import '../code_theme/code_theme.dart';
import '../code_theme/code_theme_data.dart';
import '../wip/autocomplete/popup_controller.dart';
import '../wip/autocomplete/suggestion.dart';
import '../wip/autocomplete/suggestion_generator.dart';
import 'editor_params.dart';

const _MIDDLE_DOT = '·';

class CodeController extends TextEditingController {
  Mode? _language;

  /// A highlight language to parse the text with
  Mode? get language => _language;

  set language(Mode? language) {
    if (language == _language) {
      return;
    }

    if (language != null) {
      _languageId = _genId();
      highlight.registerLanguage(_languageId, language);
    }

    _language = language;
    notifyListeners();
  }

  Map<String, TextStyle>? _theme;

  /// The theme to apply to the [language] parsing result
  @Deprecated('Use CodeTheme widget to provide theme to CodeField.')
  Map<String, TextStyle>? get theme => _theme;

  @Deprecated('Use CodeTheme widget to provide theme to CodeField.')
  set theme(Map<String, TextStyle>? theme) {
    if (theme == _theme) {
      return;
    }

    _theme = theme;
    notifyListeners();
  }

  /// A map of specific regexes to style
  final Map<String, TextStyle>? patternMap;

  /// A map of specific keywords to style
  final Map<String, TextStyle>? stringMap;

  /// Common editor params such as the size of a tab in spaces
  ///
  /// Will be exposed to all [modifiers]
  final EditorParams params;

  /// A list of code modifiers to dynamically update the code upon certain keystrokes
  final List<CodeModifier> modifiers;

  /// On web, replace spaces with invisible dots “·” to fix the current issue with spaces
  ///
  /// https://github.com/flutter/flutter/issues/77929
  final bool webSpaceFix;

  /// onChange callback, called whenever the content is changed
  final void Function(String)? onChange;

  /* Computed members */
  String _languageId = _genId();

  String get languageId => _languageId;

  final styleList = <TextStyle>[];
  final modifierMap = <String, CodeModifier>{};
  bool isPopupShown = false;
  RegExp? styleRegExp;
  late PopupController popupController;
  SuggestionGenerator? suggestionGenerator;

  CodeController({
    String? text,
    Mode? language,
    @Deprecated('Use CodeTheme widget to provide theme to CodeField.')
        Map<String, TextStyle>? theme,
    this.patternMap,
    this.stringMap,
    this.params = const EditorParams(),
    this.modifiers = const <CodeModifier>[
      const IntendModifier(),
      const CloseBlockModifier(),
      const TabModifier(),
    ],
    this.webSpaceFix = true,
    this.onChange,
  })  : _theme = theme,
        super(text: text) {
    this.language = language;

    // Create modifier map
    modifiers.forEach((el) {
      modifierMap[el.char] = el;
    });
    suggestionGenerator = SuggestionGenerator(
        'language_id'); // TODO: replace string with some generated value for current language id
    this.popupController =
        PopupController(onCompletionSelected: this.insertSelectedWord);
  }

  /// Sets a specific cursor position in the text
  void setCursor(int offset) {
    selection = TextSelection.collapsed(offset: offset);
  }

  /// Replaces the current [selection] by [str]
  void insertStr(String str) {
    final sel = selection;
    text = text.replaceRange(selection.start, selection.end, str);
    final len = str.length;

    selection = sel.copyWith(
      baseOffset: sel.start + len,
      extentOffset: sel.start + len,
    );
  }

  /// Remove the char just before the cursor or the selection
  void removeChar() {
    if (selection.start < 1) {
      return;
    }

    final sel = selection;
    text = text.replaceRange(selection.start - 1, selection.start, "");

    selection = sel.copyWith(
      baseOffset: sel.start - 1,
      extentOffset: sel.start - 1,
    );
  }

  /// Remove the selected text
  void removeSelection() {
    final sel = selection;
    text = text.replaceRange(selection.start, selection.end, "");

    selection = sel.copyWith(
      baseOffset: sel.start,
      extentOffset: sel.start,
    );
  }

  /// Remove the selection or last char if the selection is empty
  void backspace() {
    if (selection.start < selection.end) {
      removeSelection();
    } else {
      removeChar();
    }
  }

  KeyEventResult onKey(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.tab)) {
      text = text.replaceRange(selection.start, selection.end, "\t");
      return KeyEventResult.handled;
    }

    if (popupController.isPopupShown) {
      if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
        popupController.scrollByArrow(ScrollDirection.up);
        return KeyEventResult.handled;
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
        popupController.scrollByArrow(ScrollDirection.down);
        return KeyEventResult.handled;
      }
      if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
        insertSelectedWord();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// Inserts the word selected from the list of completions
  void insertSelectedWord() {
    final previousSelection = selection;
    String selectedWord = popupController.getSelectedWord();
    int startPosition = selection.baseOffset -
        suggestionGenerator!.getCurrentWordPrefix().length;
    text = text.replaceRange(startPosition, selection.baseOffset, selectedWord);
    selection = previousSelection.copyWith(
      baseOffset: startPosition + selectedWord.length,
      extentOffset: startPosition + selectedWord.length,
    );
    popupController.hide();
  }

  /// See webSpaceFix
  static String _spacesToMiddleDots(String str) {
    return str.replaceAll(" ", _MIDDLE_DOT);
  }

  /// See webSpaceFix
  static String _middleDotsToSpaces(String str) {
    return str.replaceAll(_MIDDLE_DOT, " ");
  }

  /// Get untransformed text
  /// See webSpaceFix
  String get rawText {
    if (!_webSpaceFix) {
      return super.text;
    }

    return _middleDotsToSpaces(super.text);
  }

  // Private methods
  bool get _webSpaceFix => kIsWeb && webSpaceFix;

  static String _genId() {
    const _chars = 'abcdefghijklmnopqrstuvwxyz1234567890';
    final _rnd = Random();

    return String.fromCharCodes(
      Iterable.generate(
        10,
        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
      ),
    );
  }

  int? _insertedLoc(String a, String b) {
    final sel = selection;

    if (a.length + 1 != b.length || sel.start != sel.end) {
      return null;
    }

    return sel.start;
  }

  @override
  set value(TextEditingValue newValue) {
    final loc = _insertedLoc(text, newValue.text);

    if (loc != null) {
      final char = newValue.text[loc];
      final modifier = modifierMap[char];
      final val = modifier?.updateString(rawText, selection, params);

      if (val != null) {
        // Update newValue
        newValue = newValue.copyWith(
          text: val.text,
          selection: val.selection,
        );
      }
    }

    bool hasTextChanged = newValue.text != super.value.text;
    bool hasSelectionChanged = (newValue.selection != super.value.selection);

    //Because of this part of code ctrl + z dont't work. But maybe it's important, so please don't delete.
    // Now fix the textfield for web
    // if (_webSpaceFix) {
    //   newValue = newValue.copyWith(text: _spacesToMiddleDots(newValue.text));
    // }

    if (onChange != null) {
      onChange!(
        _webSpaceFix ? _middleDotsToSpaces(newValue.text) : newValue.text,
      );
    }

    super.value = newValue;
    if (hasTextChanged) {
      generateSuggestions();
    } else if (hasSelectionChanged) {
      popupController.hide();
    }
  }

  TextSpan _processPatterns(String text, TextStyle? style) {
    final children = <TextSpan>[];

    text.splitMapJoin(
      styleRegExp!,
      onMatch: (Match m) {
        if (styleList.isEmpty) {
          return '';
        }

        int idx;
        for (idx = 1;
            idx < m.groupCount &&
                idx <= styleList.length &&
                m.group(idx) == null;
            idx++) {}

        children.add(TextSpan(
          text: m[0],
          style: styleList[idx - 1],
        ));
        return '';
      },
      onNonMatch: (String span) {
        children.add(TextSpan(text: span, style: style));
        return '';
      },
    );

    return TextSpan(style: style, children: children);
  }

  TextSpan _processLanguage(
    String text,
    CodeThemeData? widgetTheme,
    TextStyle? style,
  ) {
    final rawText = _webSpaceFix ? _middleDotsToSpaces(text) : text;
    final result = highlight.parse(rawText, language: _languageId);

    final nodes = result.nodes;

    final children = <TextSpan>[];
    var currentSpans = children;
    final stack = <List<TextSpan>>[];

    void _traverse(Node node) {
      var val = node.value;
      final nodeChildren = node.children;
      final nodeStyle =
          widgetTheme?.styles[node.className] ?? _theme?[node.className];

      if (val != null) {
        if (_webSpaceFix) {
          val = _spacesToMiddleDots(val);
        }

        var child = TextSpan(text: val, style: nodeStyle);

        if (styleRegExp != null) {
          child = _processPatterns(val, nodeStyle);
        }

        currentSpans.add(child);
      } else if (nodeChildren != null) {
        List<TextSpan> tmp = [];

        currentSpans.add(TextSpan(
          children: tmp,
          style: nodeStyle,
        ));

        stack.add(currentSpans);
        currentSpans = tmp;

        nodeChildren.forEach((n) {
          _traverse(n);
          if (n == nodeChildren.last) {
            currentSpans = stack.isEmpty ? children : stack.removeLast();
          }
        });
      }
    }

    if (nodes != null) {
      for (var node in nodes) {
        _traverse(node);
      }
    }

    return TextSpan(style: style, children: children);
  }

  void generateSuggestions() {
    List<Suggestion> suggestions = suggestionGenerator!.getSuggestions(
      text,
      selection.start,
    );

    if (suggestions.isNotEmpty) {
      popupController.show(suggestions);
    } else {
      popupController.hide();
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    // Retrieve pattern regexp
    final patternList = <String>[];

    if (_webSpaceFix) {
      patternList.add("(" + _MIDDLE_DOT + ")");
      styleList.add(TextStyle(color: Colors.transparent));
    }

    if (stringMap != null) {
      patternList.addAll(stringMap!.keys.map((e) => r'(\b' + e + r'\b)'));
      styleList.addAll(stringMap!.values);
    }

    if (patternMap != null) {
      patternList.addAll(patternMap!.keys.map((e) => "(" + e + ")"));
      styleList.addAll(patternMap!.values);
    }

    styleRegExp = RegExp(patternList.join('|'), multiLine: true);

    // Return parsing
    if (_language != null) {
      return _processLanguage(text, CodeTheme.of(context), style);
    }

    if (styleRegExp != null) {
      return _processPatterns(text, style);
    }

    return TextSpan(text: text, style: style);
  }
}
