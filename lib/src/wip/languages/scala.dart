import 'package:highlight/highlight_core.dart';
import '../LanguagesModes/common_modes.dart';
import 'main_mode.dart';

const KEYWORD = "type yield lazy override def with val var sealed abstract"
    " private trait object if forSome for while throw finally protected"
    " extends import final return else break new catch super class case"
    " package default try this match continue throws implicit";

final scala = MainMode(
  nameOfLanguage: "scala",
  refs: {
    'titleMode': Mode(
      className: "title",
      begin:
          "[^0-9\\n\\t \"'(),.`{}\\[\\]:;][^\\n\\t \"'(),.`{}\\[\\]:;]+|[^0-9\\n\\t \"'(),.`{}\\[\\]:;=]",
      relevance: 0,
    ),
    'typeMode': Mode(
      className: "type",
      begin: "\\b[A-Z][A-Za-z0-9_]*",
      relevance: 0,
    ),
    'substringMode': Mode(
      className: "subst",
      variants: [
        Mode(begin: "\\\$[A-Za-z0-9_]+"),
        Mode(begin: "\\\${", end: "}"),
      ],
    ),
    'stringsMode': Mode(
      className: "string",
      variants: [
        Mode(begin: "\"\"\"", end: "\"\"\"", relevance: 10),
        Mode(
          begin: "[a-z]+\"\"\"",
          end: "\"\"\"",
          contains: [BACKSLASH_ESCAPE, Mode(ref: 'substringMode')],
          relevance: 10,
        ),
        Mode(begin: "\"", end: "\\n|\"", contains: [BACKSLASH_ESCAPE]),
        Mode(
          begin: "[a-z]+\"",
          end: "\\n|\"",
          contains: [BACKSLASH_ESCAPE, Mode(ref: 'substringMode')],
        ),
      ],
    ),
    'methodsMode': Mode(
      className: "bullet",
      begin: "\\.",
      end: "[^_A-Za-z0-9_-]",
      excludeBegin: true,
      excludeEnd: true,
    ),
  },
  keywords: {
    "literal": "true false null",
    "keyword": KEYWORD,
  },
  contains: [
    C_LINE_COMMENT_MODE,
    C_BLOCK_COMMENT_MODE,
    Mode(ref: "stringsMode"),
    Mode(ref: "methodsMode"),
    Mode(className: "symbol", begin: "'\\w[\\w\\d_]*(?!')"),
    Mode(ref: 'typeMode'),
    Mode(
      className: "function",
      beginKeywords: "def",
      end: "[:={\\[(\\n;]",
      excludeEnd: true,
      contains: [Mode(ref: 'titleMode')],
    ),
    Mode(
      className: "class",
      beginKeywords: "class object trait type",
      end: "[:={\\[\\n;]",
      excludeEnd: true,
      contains: [
        Mode(beginKeywords: "extends with", relevance: 10),
        Mode(
          begin: "\\[",
          end: "\\]",
          excludeBegin: true,
          excludeEnd: true,
          relevance: 0,
          contains: [Mode(ref: 'typeMode')],
        ),
        Mode(
          className: "params",
          begin: "\\(",
          end: "\\)",
          excludeBegin: true,
          excludeEnd: true,
          relevance: 0,
          contains: [
            Mode(ref: 'typeMode'),
            Mode(ref: 'stringsMode'),
            Mode(ref: 'methodsMode'),
          ],
        ),
        Mode(ref: 'titleMode'),
      ],
    ),
    C_NUMBER_MODE,
    Mode(className: "meta", begin: "@[A-Za-z]+"),
  ],
);
