# flutter-code-editor

A multi-platform code editor supporting
syntax highlighting,
code folding,
autocompletion,
and partial locking.

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

See the full runnable example [here](https://raw.githubusercontent.com/akvelon/flutter-code-editor/main/example/lib/02.code_field.dart).

## Languages

### Highlighting

This package relies on the [highlight](https://pub.dev/packages/highlight) package for parsing code.
That package supports
[over a hundred languages](https://github.com/git-touch/highlight.dart/tree/master/highlight/lib/languages)
and has a pre-defined variable to refer to each one.
To use another language:

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

### Folding

Of all languages that are supported for highlighting only some are tested with code folding:

- Dart
- Go
- Java
- Python
- Scala

This is because the folding engine relies on some additional parsing to group imports and comments.
The engine is likely to work with some other languages but in edge cases bugs may show.
Please [report them here](https://github.com/akvelon/flutter-code-editor/issues).

## Themes

### Pre-defined

The themes from the [highlight](https://pub.dev/packages/flutter_highlight) package are used,
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

### Custom

To use custom theme, create a map of styles under the pre-defined class names.
See [this](https://github.com/git-touch/highlight.dart/blob/master/flutter_highlight/lib/themes/monokai-sublime.dart) for example.

## Accessing the Text

`CodeController` extends the Flutter's built-in `TextEditingController` and is immediately
usable as one. However, code folding and other features have impact on built-in properties:

- `text` returns and sets the visible text. If any code is folded, it will not be returned.
- `value` returns and sets the `TextEditingValue` with the visible text and selection.
  If any code is folded, it will not be returned.
- `fullText` returns and sets the entire text including any folded blocks and hidden
  service comments (see below).

## Named Sections

Many features rely on so-called named sections in the code.
You define named sections with service comments like this:

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

Then pass the section parser to the controller:

```dart
final controller = CodeController(
  text: text,
  language: java,
  namedSectionParser: const BracketsStartEndNamedSectionParser(), // NEW
);
```

This creates a section named `section1`.
The built-in `BracketsStartEndNamedSectionParser` class is designed to parse sections
from the code comments using the above syntax.
It also hides the given comments although they are still present in the editor
and will be revealed when copying the text.

If you need to parse sections using any other syntax, subclass `AbstractNamedSectionParser`.

## Partial Locking

This is how you make parts of the code read-only:

```dart
controller.readOnlySectionNames = {'section1'};
```

This locks the given sections. Any non-existent section names in this set are ignored.
To make the code editable again, pass an updated set.

When using this feature, `text` and `value` properties cannot be used to change the text
programmatically because they have the same effect as the user input,
and so locking affects them as well.

To change a partially locked controller, use `fullText` property.

## Advanced Folding

### First Comment

Many code snippets contain license as their first comment. You can fold that:

```dart
controller.foldCommentAtLineZero();
```

This method has no effect if there is no comment starting at the first line.

### Imports

In many languages, editor recognizes sequential import lines
and an optional package line as one foldable block.
To fold such blocks:

```dart
controller.foldImports();
```

### Named Sections

You can fold all blocks except those overlapping with given named sections:

```dart
controller.foldOutsideSections(['section1']);
```

This way your users can be focused on the most important lines of a snippet.

### Folding Specific Blocks

You can fold and unfold blocks at a given line number:

```dart
controller.foldAt(3);
controller.unfoldAt(3);
```

If there is no block at a given line, this has no effect.

**Note:** For the controller, line numbers start at `0` although
the widget displays them starting at `1`.

### Accessing Folded Blocks

To get the currently folded blocks, read: `controller.code.foldedBlocks`

## Hiding Text

You can hide all the code except a given named section:

```dart
controller.visibleSectionNames = {'section1'};
```

This way the full text is still preserved and is available via `fullText` property.

This is good for giving your user even more focus than with folding.
It preserves line numbering which you cannot achieve by just showing a cropped snippet.

This is also useful if you later need to send the code for further processing but still want to hide
non-informative parts.

Hiding text like that also makes the entire editor read-only.
This is because otherwise users get confused and may try fixing the syntax by adding some imports
which will conflict with the hidden parts.

Only one visible section at a time is currently supported. The behavior of passing more than
one section is undefined.

## Migration Guide

This code editor was forked from [code_text_field](https://pub.dev/packages/code_text_field)
by BertrandBev, and then many features were added to it.

The first versions preserve much of compatibility for your convenience.

### Migrating from code_text_field

1. Replace `code_text_field` package with this one.
2. Do not use `CodeField.expands` because otherwise the code scrolls but line numbers freeze.
   Instead put the entire widget to `Expnaded`.
3. Use `CodeTheme` widget instead of passing a theme to `CodeController`.

## Contribution Guide

We appreciate your help and PRs.
If you have an idea, please file an issue
[here](https://github.com/akvelon/flutter-code-editor/issues). And we will get in touch.
