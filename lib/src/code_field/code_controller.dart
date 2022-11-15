// ignore_for_file: parameter_assignments

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlight/highlight_core.dart';

import '../autocomplete/autocompleter.dart';
import '../code/code.dart';
import '../code/code_edit_result.dart';
import '../code_field/text_editing_value.dart';
import '../code_modifiers/close_block_code_modifier.dart';
import '../code_modifiers/code_modifier.dart';
import '../code_modifiers/indent_code_modifier.dart';
import '../code_modifiers/tab_code_modifier.dart';
import '../code_theme/code_theme.dart';
import '../code_theme/code_theme_data.dart';
import '../history/code_history_controller.dart';
import '../history/code_history_record.dart';
import '../named_sections/parsers/abstract.dart';
import '../wip/autocomplete/popup_controller.dart';
import 'actions/copy.dart';
import 'actions/redo.dart';
import 'actions/undo.dart';
import 'editor_params.dart';
import 'span_builder.dart';

const _middleDot = '·';

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
    autocompleter.mode = language;
    notifyListeners();
  }

  final AbstractNamedSectionParser? namedSectionParser;
  Set<String> _readOnlySectionNames;

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

  final bool _isTabReplacementEnabled;

  /// On web, replace spaces with invisible dots “·” to fix the current issue with spaces
  ///
  /// https://github.com/flutter/flutter/issues/77929
  final bool webSpaceFix;

  /// onChange callback, called whenever the content is changed
  final void Function(String)? onChange;

  /* Computed members */
  String _languageId = _genId();

  ///Contains names of named sections, those will be visible for user.
  ///If it is not empty, all another code except specified will be hidden.
  Set<String> _visibleSectionNames = {};

  String get languageId => _languageId;

  Code _code;

  final styleList = <TextStyle>[];
  final modifierMap = <String, CodeModifier>{};
  bool isPopupShown = false;
  RegExp? styleRegExp;
  late PopupController popupController;
  final autocompleter = Autocompleter();
  late final historyController = CodeHistoryController(codeController: this);

  late final actions = <Type, Action<Intent>>{
    CopySelectionTextIntent: CopyAction(controller: this),
    RedoTextIntent: RedoAction(controller: this),
    UndoTextIntent: UndoAction(controller: this),
  };

  CodeController({
    String? text,
    Mode? language,
    this.namedSectionParser,
    Set<String> readOnlySectionNames = const {},
    Set<String> visibleSectionNames = const {},
    @Deprecated('Use CodeTheme widget to provide theme to CodeField.')
        Map<String, TextStyle>? theme,
    this.patternMap,
    this.stringMap,
    this.params = const EditorParams(),
    this.modifiers = const [
      IntendModifier(),
      CloseBlockModifier(),
      TabModifier(),
    ],
    this.webSpaceFix = true,
    this.onChange,
  })  : _theme = theme,
        _readOnlySectionNames = readOnlySectionNames,
        _code = Code.empty,
        _isTabReplacementEnabled = modifiers.any((e) => e is TabModifier) {
    this.language = language;
    this.visibleSectionNames = visibleSectionNames;
    _code = _createCode(text ?? '');
    fullText = text ?? '';

    // Create modifier map
    for (final el in modifiers) {
      modifierMap[el.char] = el;
    }

    popupController = PopupController(onCompletionSelected: insertSelectedWord);
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
    text = text.replaceRange(selection.start - 1, selection.start, '');

    selection = sel.copyWith(
      baseOffset: sel.start - 1,
      extentOffset: sel.start - 1,
    );
  }

  /// Remove the selected text
  void removeSelection() {
    final sel = selection;
    text = text.replaceRange(selection.start, selection.end, '');

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

  KeyEventResult onKey(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      return _onKeyDownRepeat(event);
    }

    return KeyEventResult.ignored; // The framework will handle.
  }

  KeyEventResult _onKeyDownRepeat(KeyEvent event) {
    // TODO(alexeyinkin): Use a shortcut, https://github.com/akvelon/flutter-code-editor/issues/21
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      text = text.replaceRange(selection.start, selection.end, '\t');
      return KeyEventResult.handled;
    }

    if (popupController.isPopupShown) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        popupController.scrollByArrow(ScrollDirection.up);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        popupController.scrollByArrow(ScrollDirection.down);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        insertSelectedWord();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored; // The framework will handle.
  }

  /// Inserts the word selected from the list of completions
  void insertSelectedWord() {
    final previousSelection = selection;
    String selectedWord = popupController.getSelectedWord();
    final startPosition = value.wordAtCursorStart;

    if (startPosition != null) {
      text = text.replaceRange(
        startPosition,
        selection.baseOffset,
        selectedWord,
      );

      selection = previousSelection.copyWith(
        baseOffset: startPosition + selectedWord.length,
        extentOffset: startPosition + selectedWord.length,
      );
    }

    popupController.hide();
  }

  /// See webSpaceFix
  static String _middleDotsToSpaces(String str) {
    return str.replaceAll(_middleDot, ' ');
  }

  /// Get untransformed text
  /// See webSpaceFix
  String get rawText {
    if (!_webSpaceFix) {
      return super.text;
    }

    return _middleDotsToSpaces(super.text);
  }

  String get fullText => _code.text;

  set fullText(String fullText) {
    _updateCodeIfChanged(_replaceTabsWithSpacesIfNeeded(fullText));
    super.value = TextEditingValue(text: _code.visibleText);
  }

  // Private methods
  bool get _webSpaceFix => kIsWeb && webSpaceFix;

  static String _genId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz1234567890';
    final rnd = Random();

    return String.fromCharCodes(
      Iterable.generate(
        10,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }

  int? _insertedLoc(String a, String b) {
    final sel = selection;

    if (a.length + 1 != b.length || sel.start != sel.end || sel.start == -1) {
      return null;
    }

    return sel.start;
  }

  @override
  set value(TextEditingValue newValue) {
    final hasTextChanged = newValue.text != super.value.text;
    final hasSelectionChanged = newValue.selection != super.value.selection;

    if (!hasTextChanged && !hasSelectionChanged) {
      return;
    }

    if (hasTextChanged) {
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

      if (_isTabReplacementEnabled) {
        newValue = newValue.tabsToSpaces(params.tabSpaces);
      }
      final editResult = _getEditResultNotBreakingReadOnly(newValue);

      if (editResult == null) {
        return;
      }

      _updateCodeIfChanged(editResult.fullTextAfter);

      if (newValue.text != _code.visibleText) {
        // Manually typed in a text that has become a hidden range.
        newValue = newValue.replacedText(_code.visibleText);
      }

      // Uncomment this to see the hidden text in the console
      // as you change the visible text.
      //print('\n\n${_code.text}');
    }

    //Because of this part of code ctrl + z dont't work. But maybe it's important, so please don't delete.
    // Now fix the textfield for web
    // if (_webSpaceFix) {
    //   newValue = newValue.copyWith(text: _spacesToMiddleDots(newValue.text));
    // }

    onChange?.call(
      _webSpaceFix ? _middleDotsToSpaces(newValue.text) : newValue.text,
    );

    historyController.beforeChanged(_code, newValue.selection);
    super.value = newValue;

    if (hasTextChanged) {
      autocompleter.blacklist = [newValue.wordAtCursor ?? ''];
      autocompleter.setText(this, text);
      generateSuggestions();
    } else if (hasSelectionChanged) {
      popupController.hide();
    }
  }

  void applyHistoryRecord(CodeHistoryRecord record) {
    _code = record.code;

    super.value = TextEditingValue(
      text: code.visibleText,
      selection: record.selection,
    );
  }

  Code get code => _code;

  CodeEditResult? _getEditResultNotBreakingReadOnly(TextEditingValue newValue) {
    final editResult = _code.getEditResult(value.selection, newValue);
    if (!_code.isReadOnlyInLineRange(editResult.linesChanged)) {
      return editResult;
    }

    return null;
  }

  void _updateCodeIfChanged(String text) {
    if (text != _code.text) {
      _updateCode(text);
    }
  }

  void _updateCode(String text) {
    final newCode = _createCode(text);
    _code = newCode.foldedAs(_code);
  }

  Code _createCode(String text) {
    final rawText = _webSpaceFix ? _middleDotsToSpaces(text) : text;

    return Code(
      text: rawText,
      language: language,
      highlighted: highlight.parse(rawText, language: _languageId),
      namedSectionParser: namedSectionParser,
      readOnlySectionNames: _readOnlySectionNames,
      visibleSectionNames: _visibleSectionNames,
    );
  }

  String _replaceTabsWithSpacesIfNeeded(String text) {
    if (modifiers.contains(const TabModifier())) {
      return text.replaceAll('\t', ' ' * params.tabSpaces);
    }
    return text;
  }

  Future<void> generateSuggestions() async {
    final prefix = value.wordToCursor;
    if (prefix == null) {
      popupController.hide();
      return;
    }

    final suggestions =
        (await autocompleter.getSuggestions(prefix)).toList(growable: false);

    if (suggestions.isNotEmpty) {
      popupController.show(suggestions);
    } else {
      popupController.hide();
    }
  }

  void foldAt(int line) {
    final newCode = _code.foldedAt(line);
    super.value = _getValueWithCode(newCode);

    _code = newCode;
  }

  void unfoldAt(int line) {
    final newCode = _code.unfoldedAt(line);
    super.value = _getValueWithCode(newCode);

    _code = newCode;
  }

  Set<String> get readOnlySectionNames => _readOnlySectionNames;

  set readOnlySectionNames(Set<String> newValue) {
    _readOnlySectionNames = newValue;
    _updateCode(_code.text);

    notifyListeners();
  }

  Set<String> get visibleSectionNames => _visibleSectionNames;

  set visibleSectionNames(Set<String> sectionNames) {
    _visibleSectionNames = sectionNames;
    _updateCode(_code.text);

    super.value = _getValueWithCode(_code);
  }

  /// The value with [newCode] preserving the current selection.
  TextEditingValue _getValueWithCode(Code newCode) {
    return TextEditingValue(
      text: newCode.visibleText,
      selection: newCode.hiddenRanges.cutSelection(
        _code.hiddenRanges.recoverSelection(value.selection),
      ),
    );
  }

  void foldCommentAtLineZero() {
    final block = _code.foldableBlocks.firstOrNull;

    if (block == null || !block.isComment || block.firstLine != 0) {
      return;
    }

    foldAt(0);
  }

  void foldImports() {
    // TODO(alexeyinkin): An optimized method to fold multiple blocks, https://github.com/akvelon/flutter-code-editor/issues/106
    for (final block in _code.foldableBlocks) {
      if (block.isImports) {
        foldAt(block.firstLine);
      }
    }
  }

  /// Folds blocks that are outside all of the [names] sections.
  ///
  /// For a block to be not folded, it must overlap any of the given sections
  /// in any way.
  void foldOutsideSections(Iterable<String> names) {
    final foldLines = {..._code.foldableBlocks.map((b) => b.firstLine)};
    final sections = names.map((s) => _code.namedSections[s]).whereNotNull();

    for (final block in _code.foldableBlocks) {
      for (final section in sections) {
        if (block.overlaps(section)) {
          foldLines.remove(block.firstLine);
          break;
        }
      }
    }

    // TODO(alexeyinkin): An optimized method to fold multiple blocks, https://github.com/akvelon/flutter-code-editor/issues/106
    foldLines.forEach(foldAt);
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
      patternList.add('($_middleDot)');
      styleList.add(const TextStyle(color: Colors.transparent));
    }

    if (stringMap != null) {
      patternList.addAll(stringMap!.keys.map((e) => r'(\b' + e + r'\b)'));
      styleList.addAll(stringMap!.values);
    }

    if (patternMap != null) {
      patternList.addAll(patternMap!.keys.map((e) => '($e)'));
      styleList.addAll(patternMap!.values);
    }

    styleRegExp = RegExp(patternList.join('|'), multiLine: true);

    // Return parsing
    if (_language != null) {
      return SpanBuilder(
        code: _code,
        theme: _getTheme(context),
        textStyle: style,
      ).build();
    }

    if (styleRegExp != null) {
      return _processPatterns(text, style);
    }

    return TextSpan(text: text, style: style);
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

  CodeThemeData _getTheme(BuildContext context) {
    return CodeTheme.of(context) ?? CodeThemeData(styles: _theme ?? {});
  }
}
