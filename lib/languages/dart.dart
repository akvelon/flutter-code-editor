// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:highlight/highlight_core.dart';
import '../LanguagesModes/common_modes.dart';
import 'main_mode.dart';

const KEYWORD = "abstract as assert async await break case catch class"
    " const continue covariant default deferred do dynamic else enum"
    " export extends extension external factory false final finally"
    " for function get hide if implements import in interface"
    " is library mixin new null on operator part rethrow return"
    " set show static super switch sync this throw true try"
    " typedef var void while with yield";

const BUILT_IN = "Comparable DateTime Duration Function Iterable"
    " Iterator List Map Match Null Object Pattern RegExp Set"
    " Stopwatch StringBuffer StringSink Type"
    " Uri dynamic num print Element ElementList"
    " document querySelector querySelectorAll window";

const Type = "bool double int String Symbol Runes";

final dart = MainMode(
  nameOfLanguage: "dart",
  refs: {
    'substringMode': Mode(
      className: "subst",
      variants: [Mode(begin: "\\\${", end: "}")],
      keywords: "true false null this is new super",
      contains: [C_NUMBER_MODE, Mode(ref: 'stringMode')],
    ),
    'substringMode2': Mode(
      className: "subst",
      variants: [Mode(begin: "\\\$[A-Za-z0-9_]+")],
    ),
    'stringMode': Mode(
      className: "string",
      variants: [
        Mode(begin: "r'''", end: "'''"),
        Mode(begin: "r\"\"\"", end: "\"\"\""),
        Mode(begin: "r'", end: "'|\\n"),
        Mode(begin: "r\"", end: "\"|\\n"),
        Mode(
          begin: "'''",
          end: "'''",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: 'substringMode2'),
            Mode(ref: 'substringMode'),
          ],
        ),
        Mode(
          begin: "\"\"\"",
          end: "\"\"\"",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: 'substringMode2'),
            Mode(ref: 'substringMode'),
          ],
        ),
        Mode(
          begin: "'",
          end: "'|\\n",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: 'substringMode2'),
            Mode(ref: 'substringMode'),
          ],
        ),
        Mode(
          begin: "\"",
          end: "\"|\\n",
          contains: [
            BACKSLASH_ESCAPE,
            Mode(ref: 'substringMode2'),
            Mode(ref: 'substringMode'),
          ],
        ),
      ],
    ),
    "methodsMode": Mode(
      className: "bullet",
      begin: "\\.",
      end: "[^_A-Za-z0-9_-]",
      excludeBegin: true,
      excludeEnd: true,
    ),
  },
  keywords: {
    "keyword": KEYWORD,
    "built_in": BUILT_IN,
    "type": Type,
  },
  contains: [
    Mode(ref: 'stringMode'),
    Mode(ref: 'methodsMode'),
    Mode(
      className: "comment",
      begin: "/\\*\\*",
      end: "\\*/",
      contains: [
        PHRASAL_WORDS_MODE,
        Mode(
          className: "doctag",
          begin: "(?:TODO|FIXME|NOTE|BUG|XXX):",
          relevance: 0,
        ),
      ],
      subLanguage: ["markdown"],
    ),
    Mode(
      className: "comment",
      begin: "///+\\s*",
      end: "\$",
      contains: [
        Mode(subLanguage: ["markdown"], begin: ".", end: "\$"),
        PHRASAL_WORDS_MODE,
        Mode(
          className: "doctag",
          begin: "(?:TODO|FIXME|NOTE|BUG|XXX):",
          relevance: 0,
        ),
      ],
    ),
    C_LINE_COMMENT_MODE,
    C_BLOCK_COMMENT_MODE,
    Mode(
      className: "class",
      beginKeywords: "class interface",
      end: "{",
      excludeEnd: true,
      contains: [
        Mode(beginKeywords: "extends implements"),
        UNDERSCORE_TITLE_MODE,
      ],
    ),
    C_NUMBER_MODE,
    Mode(className: "meta", begin: "@[A-Za-z]+"),
    Mode(begin: "=>"),
  ],
);
