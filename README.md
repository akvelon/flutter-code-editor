# Flutter Code Editor

Flutter Code Editor is a multi-platform code editor supporting:

- Syntax highlighting,
- Code blocks folding,
- Autocompletion,
- Read-only code blocks,
- Hiding specific code blocks,
- Themes,
- And many other features.

[![Pub Version](https://img.shields.io/pub/v/flutter_code_editor)](https://pub.dev/packages/flutter_code_editor)
[![CodeFactor](https://img.shields.io/codefactor/grade/github/akvelon/flutter-code-editor?style=flat-square)](https://www.codefactor.io/repository/github/akvelon/flutter-code-editor)

![Basic Example](https://raw.githubusercontent.com/akvelon/flutter-code-editor/main/example/images/factorial.png)


## Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/java.dart';

void main() {
  runApp(const CodeEditor());
}

final controller = CodeController(
  text: '...', // Initial code
  language: java,
);

class CodeEditor extends StatelessWidget {
  const CodeEditor();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CodeTheme(
          data: CodeThemeData(styles: monokaiSublimeTheme),
          child: SingleChildScrollView(
            child: CodeField(
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }
}
```

See the full runnable example [here](https://github.com/akvelon/flutter-code-editor/blob/main/example/lib/02.code_field.dart).


## Languages

### Syntax Highlighting

Flutter Code Editor supports
[over a hundred languages](https://github.com/git-touch/highlight.dart/tree/master/highlight/lib/languages)
relying on the [highlight](https://pub.dev/packages/highlight) package for parsing code.

To select a language, use a
[corresponding variable](https://github.com/git-touch/highlight.dart/tree/master/highlight/lib/languages):

```dart
import 'package:highlight/languages/python.dart'; // Each language is defined in its file.

final controller = CodeController(
  text: '...', // Initial code
  language: python,
);
```

Language can be dynamically changed on a controller:

```dart
controller.language = go;
```


### Code Blocks Folding 

Flutter Code Editor can detect and fold code blocks. Code blocks folding is supported for the following languages:
- Dart
- Go
- Java
- Python
- Scala

Code blocks folding may support other languages in experimental mode.


## Themes

### Pre-defined Themes

Flutter Code Editor supports themes from the [highlight](https://pub.dev/packages/flutter_highlight) package,
see the full list of the pre-defined themes
[here](https://github.com/git-touch/highlight.dart/tree/master/flutter_highlight/lib/themes).

Use `CodeTheme` widget to set the theme for underlying editors:

```dart
return MaterialApp(
  home: Scaffold(
    body: CodeTheme(
      data: CodeThemeData(styles: monokaiSublimeTheme), // <= Pre-defined in flutter_highlight.
      child: SingleChildScrollView(
        child: CodeField(
          controller: controller,
        ),
      ),
    ),
  ),
);
```

### Custom Themes

To use a custom theme, create a map of styles under the pre-defined class names.
See [an example](https://github.com/git-touch/highlight.dart/blob/master/flutter_highlight/lib/themes/monokai-sublime.dart).


## Accessing the Text

`CodeController` extends the Flutter's built-in `TextEditingController` and is immediately
usable as one. However, code folding and other features have impact on built-in properties:

- `text` returns and sets the visible text. If any code is folded, it will not be returned.
- `value` returns and sets the `TextEditingValue` with the visible text and selection.
  If any code is folded, it will not be returned.
- `fullText` returns and sets the entire text including any folded blocks and hidden
  service comments (see below).


## Named Sections

To manipulate parts of the source code, Flutter Code Editor supports *named sections*.
They are defined in the code by adding tags that Flutter Code Editor recognizes.

To define a named section in your source code, add comments to tag the start and the end of the section:
1. Add comment `[START section_name]` to tag the beginning of the section.
2. Add comment `[END section_name]` to tag the end of the section.

Here is an example to define a named section `section1`:

```dart
final text = '''
class MyClass {
    public static void main(String[] args) {// [START section1]
        int num = 5;
        System.out.println("Factorial of " + num + " is " + factorial(5));
    }// [END section1]
}
''';
```

To process named sections in the Flutter Code Editor,
pass the named section parser to the controller:

```dart
final controller = CodeController(
  text: text,
  language: java,
  namedSectionParser: const BracketsStartEndNamedSectionParser(), // NEW
);
```

The example above creates a section named `section1`.
The built-in `BracketsStartEndNamedSectionParser` class is designed to parse sections
from the code comments using the above syntax.
It also hides any single-line comment that has a section tag with the above syntax,
although such comments are still present in the editor's hidden state
and will be revealed when copying the text.

To customize section parsing using any other syntax, subclass `AbstractNamedSectionParser`.


## Read-Only Code Blocks

Flutter Code Editor allows to define read-only code blocks.
This may be useful for learning use cases when users are guided to modify certain code blocks
while other code is meant to be protected from changes. 

To make a named section read-only, pass a set of named sections to the `controller.readOnlySectionNames`:

```dart
controller.readOnlySectionNames = {'section1'};
```

This locks the given sections from modifications in the Flutter Code Editor.
Any non-existent section names in this set are ignored.
To make the code editable again, pass an updated set to `controller.readOnlySectionNames`.

When using this feature, `text` and `value` properties cannot be used to change the text
programmatically because they have the same effect as the user input,
and so locking affects them as well.

To change a partially locked controller, set the `fullText` property.


## Advanced Code Blocks Folding

### Folding The First Comment/License

Many code snippets contain license as their first comment, and it can distract readers.
To fold the first comment, use:

```dart
controller.foldCommentAtLineZero();
```

This method has no effect if there is no comment starting at the first line.

### Folding Imports

In many languages, the editor recognizes sequential import lines
and an optional package line as one foldable block.
To fold such blocks:

```dart
controller.foldImports();
```

### Named Sections

The editor supports folding all blocks except specific named sections.
This helps the user focus on those sections while
all source code is still there, can be expanded and copied by the user.

To fold all blocks except those overlapping with the given named sections:

```dart
controller.foldOutsideSections(['section1']);
```

### Folding Specific Blocks

To fold and unfold blocks at a given line number:

```dart
controller.foldAt(1);
controller.unfoldAt(1);
```

If there is no block at a given line, this has no effect.

**Note:** For the controller, line numbers start at `0` although
the widget displays them starting at `1`.

### Accessing Folded Blocks

To get the currently folded blocks, read `controller.code.foldedBlocks`.


## Hiding Text

The editor allows to completely hide all code except the specific named section.
This is useful for even more focus than with folding.

To hide all the code except the given named section:

```dart
controller.visibleSectionNames = {'section1'};
```

![visibleSectionNames](https://raw.githubusercontent.com/akvelon/flutter-code-editor/main/example/images/visible-section-names.png)

When hiding text, the full text is still preserved
and available via `fullText` property in the Flutter Code Editor.

Hiding text preserves line numbering which is not possible by just showing a cropped snippet.
Preserving hidden text is also useful if you later need to send
the full code for further processing but still want to hide
non-informative parts.

Hiding text also makes the entire editor read-only
to prevent users from modifying the code, adding imports, etc.
which may conflict with the hidden parts.

Only one visible section at a time is currently supported. The behavior of passing more than
one section is undefined.


## Autocompletion

The editor suggests words as they are typed. Suggested words are:

- All keywords of the current language.
- All words already in the text.
- Words set with `controller.autocompleter.setCustomWords(['word1', 'word2'])`

All those words are merged into an unstructured dictionary.
The editor performs no syntax analysis and so cannot tell if a given class really has
the method the user is typing. This feature is meant to simplify typing but not to be relied on
when exploring classes and methods.

Autocompletion currently cannot be disabled.


## Migration Guides

- [Migrating from code_text_field to 0.1](https://github.com/akvelon/flutter-code-editor/blob/main/doc/migrating/0.1.md)


## Contact Us

* [Get in touch with us](https://akvelon.com/contact-us/).
* [Request a custom feature](https://akvelon.com/contact-us/).
* [Request custom Flutter, Web, Mobile application development](https://akvelon.com/contact-us/).
* [Share about your use case for the Flutter Code Editor](https://akvelon.com/contact-us/).
* [Report an issue](https://github.com/akvelon/flutter-code-editor/issues).


## Contribution Guide

To get involved with Flutter Code Editor, submit your contribution as a PR,
[contact us](https://akvelon.com/contact-us/) with a feature request or question,
or [report an issue](https://github.com/akvelon/flutter-code-editor/issues).
