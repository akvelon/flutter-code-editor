# Flutter Code Editor

Flutter Code Editor is a multi-platform code editor supporting syntax highlighting, code blocks folding, autocompletion, named sections, read-only code blocks, hiding text to create code snippets, themes and many other features.

[![Pub Version](https://img.shields.io/pub/v/flutter_code_editor)](https://pub.dev/packages/flutter_code_editor)

![Basic Example](https://raw.githubusercontent.com/akvelon/flutter-code-editor/main/example/images/factorial.png)

## Basic Usage

```dart
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

Flutter Code Editor supports [over a hundred languages](https://github.com/git-touch/highlight.dart/tree/master/highlight/lib/languages) relying on the [highlight](https://pub.dev/packages/highlight) package for parsing code.

To select a language, use a [corresponding variable](https://github.com/git-touch/highlight.dart/tree/master/highlight/lib/languages):

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
see the full list of pre-defined themes
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

Flutter Code Editor supports `named sections` in the source code. `Named sections` are defined in the souce code by adding a tag that Flutter Code Editor recognizes.

To define a `named section` in your source code file add comments to tag the start and end of the section:
1. Add comment `[START <section_name>]` to tag the beginning of the section
2. Add comment `[END <section_name>]` tag the end of the section.

Here is an example to define a `named section` `section1`:

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

To process `named sections` in the Flutter Code Editor, pass the `named section` parser to the controller:

```dart
final controller = CodeController(
  text: text,
  language: java,
  namedSectionParser: const BracketsStartEndNamedSectionParser(), // NEW
);
```

The example above creates a section named `section1`.
The built-in `BracketsStartEndNamedSectionParser` class is designed to parse sections from the code comments using the above syntax. It also hides any single-line comment that has a section label with the above syntax,
although such comments are still present in the editor's hidden state and will be revealed when copying the text.

To customize parsing sections using any other syntax, subclass `AbstractNamedSectionParser`.

## Read-Only Code Blocks

Flutter Code Editor allows to define read-only code blocks, that might be useful for learning use cases when users are guided to modify certain code blocks, and other code desired to be protected from modification. 

To make a `named section` read-only, pass set of `named sections` to the `controller.readOnlySectionNames`:

```dart
controller.readOnlySectionNames = {'section1'};
```

This locks the given sections from modifications in the Flutter Code Editor. Any non-existent section names in this set are ignored. To make the code editable again, pass an updated set to `controller.readOnlySectionNames`.

When using this feature, `text` and `value` properties cannot be used to change the text programmatically because they have the same effect as the user input, and so locking affects them as well.

To change a partially locked controller, set the `fullText` property.

## Advanced Code Blocks Folding

### Folding The First Comment/License

Many code snippets contain license as their first comment, that might be desired to be folded. To fold the first comment use:

```dart
controller.foldCommentAtLineZero();
```

This method has no effect if there is no comment starting at the first line.

### Folding Imports

In many languages, the editor recognizes sequential import lines and an optional package line as one foldable block. To fold such blocks:

```dart
controller.foldImports();
```

### Named Sections

Folding all blocks except the specific `named sections` is useful to create `code snippets` that help a user focus on the specific sections. The benefit of folding all blocks except the `named sections` is that all source code is still there, can be expanded, copied or downloaded by the user.

To fold all blocks, except blocks overlapping with given `named sections`:
```dart
controller.foldOutsideSections(['section1']);
```
This way your users can be focused on the most important lines of a snippet.

### Folding Specific Blocks

To fold and unfold blocks at a given line number:

```dart
controller.foldAt(3);
controller.unfoldAt(3);
```

If there is no block at a given line, this has no effect.

**Note:** For the controller, line numbers start at `0` although
the widget displays them starting at `1`.

### Accessing Folded Blocks

To get the currently folded blocks, read `controller.code.foldedBlocks`

## Hiding Text

Hiding all blocks except the specific `named sections` is useful to create `code snippets` that help a user focus on the specific code.

Hiding text helps user achieve more focus than folding code blocks.

The benefit of hiding all blocks except the `named sections` is that full text is preserved and available via `fullText` property in the Flutter Code Editor, can be copied or downloaded by the user.

To hide all the code except a given `named section`:

```dart
controller.visibleSectionNames = {'section1'};
```

![visibleSectionNames](https://raw.githubusercontent.com/akvelon/flutter-code-editor/main/example/images/visible-section-names.png)


Hiding text preserves line numbering that's not easy to achieve by just showing a cropped snippet. Preserving line numbering is useful if you later need to send the code for further processing but still want to hide
non-informative parts.

Hiding text also makes the entire editor read-only to prevent users from modifying the code, adding imports etc.
which may conflict with the hidden parts.

Only one visible section at a time is currently supported. The behavior of passing more than
one section is undefined.

## Migration Guides

- [Migrating from code_text_field to 0.1](https://github.com/akvelon/flutter-code-editor/blob/main/docs/migrating/0.1.md)

## Contact Us
* [Get in touch with us](https://akvelon.com/contact-us/).
* [Request a custom feature](https://akvelon.com/contact-us/).
* [Request custom Flutter, Web, Mobile application development](https://akvelon.com/contact-us/).
* [Share about your use case for the Flutter Code Editor](https://akvelon.com/contact-us/).
* [Report an issue](https://github.com/akvelon/flutter-code-editor/issues).


## Contribution Guide
To get involved with Flutter Code Editor, submit your contribution as a PR, [contact us](https://akvelon.com/contact-us/) with a feature request or question, or [report an issue](https://github.com/akvelon/flutter-code-editor/issues).
