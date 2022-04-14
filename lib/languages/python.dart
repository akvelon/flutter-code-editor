import 'package:highlight/highlight_core.dart';
import '../LanguagesModes/common_modes.dart';
import 'main_mode.dart';

const String KEYWORD = 'and elif is global as in if'
    ' from raise for except finally print import pass return'
    ' exec else break not with class assert yield try while continue'
    ' del or def lambda async await nonlocal|10';

final MainMode python = MainMode(
  nameOfLanguage: 'python',
  refs: <String, Mode>{
    'substringMode': Mode(
      className: 'subst',
      begin: '\\{',
      end: '\\}',
      keywords: {
        'keyword': KEYWORD,
        'built_in': 'Ellipsis NotImplemented',
        'literal': 'False None True',
      },
      illegal: '#',
      contains: <Mode?>[
        Mode(ref: 'stringMode'), 
        Mode(ref: 'numberMode'), 
        Mode(ref: 'metaMode')
      ]
    ),
    'simpleMode': Mode(
      begin: '\\{\\{', 
      relevance: 0
    ),
    'stringMode': Mode(
      className: 'string', 
      contains: <Mode?>[
        BACKSLASH_ESCAPE
      ], 
      variants: <Mode?>[
        Mode(
          begin: "(u|b)?r?'''",
          end: "'''",
          contains: <Mode?>[
            BACKSLASH_ESCAPE, 
            Mode(ref: 'metaMode')
          ],
          relevance: 10
        ),
        Mode(
          begin: '(u|b)?r?\"\"\"',
          end: '\"\"\"',
          contains: <Mode?>[
            BACKSLASH_ESCAPE, 
            Mode(ref: 'metaMode')
          ],
          relevance: 10
        ),
        Mode(
          begin: "(fr|rf|f)'''", 
          end: "'''", 
          contains: <Mode?>[
            BACKSLASH_ESCAPE,
            Mode(ref: 'metaMode'),
            Mode(ref: 'simpleMode'),
            Mode(ref: 'substringMode')
          ]
        ),
        Mode(
          begin: '(fr|rf|f)\"\"\"', 
          end: '\"\"\"', 
          contains: <Mode?>[
            BACKSLASH_ESCAPE,
            Mode(ref: 'metaMode'),
            Mode(ref: 'simpleMode'),
            Mode(ref: 'substringMode')
          ]
        ),
        Mode(
          begin: "(u|r|ur)'", 
          end: "\\n|'", 
          relevance: 10
        ),
        Mode(
          begin: '(u|r|ur)\"', 
          end: '\\n|\"', 
          relevance: 10
        ),
        Mode(
          begin: "(b|br)'", 
          end: "\\n|'"
        ),
        Mode(
          begin: '(b|br)\"', 
          end: '\\n|\"'
        ),
        Mode(
          begin: "(fr|rf|f)'",
          end: "\\n|'",
          contains: <Mode?>[
            BACKSLASH_ESCAPE, 
            Mode(ref: 'simpleMode'), 
            Mode(ref: 'substringMode')
          ]
        ),
        Mode(
          begin: '(fr|rf|f)\"',
          end: '\\n|\"',
          contains: <Mode?>[
            BACKSLASH_ESCAPE, 
            Mode(ref: 'simpleMode'), 
            Mode(ref: 'substringMode')
          ]
        ),
        APOS_STRING_MODE,
        QUOTE_STRING_MODE
      ]
    ),
    'numberMode': Mode(
      className: 'number', 
      relevance: 0, 
      variants: <Mode?>[
        Mode(begin: '\\b(0b[01]+)[lLjJ]?'),
        Mode(begin: '\\b(0o[0-7]+)[lLjJ]?'),
        Mode(begin: '(-?)(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)[lLjJ]?')
      ]
    ),
    'metaMode': Mode(
      className: 'meta', 
      begin: '^(>>>|\\.\\.\\.) '
    ),
  },
  aliases: <String>['py', 'gyp', 'ipython'],
  keywords: {
    'keyword': KEYWORD,
    'built_in': 'Ellipsis NotImplemented',
    'literal': 'False None True',
    'type': 'int str float list dict tup set bool',
  },
  illegal: '(<\\/|->|\\?)|=>',
  contains: <Mode?>[
    Mode(
      className: 'bullet',
      begin: '\\.',
      end: '[^_A-Za-z0-9_-]',
      excludeBegin: true,
      excludeEnd: true,
    ),
    Mode(ref: 'metaMode'),
    Mode(ref: 'numberMode'),
    Mode(
      beginKeywords: 'if', 
      relevance: 0
    ),
    Mode(ref: 'stringMode'),
    HASH_COMMENT_MODE,
    Mode(
      variants: <Mode?>[
        Mode(
          className: 'function', 
          beginKeywords: 'def'
        ),
        Mode(
          className: 'class', 
          beginKeywords: 'class'
        )
      ],
      end: ':',
      illegal: '[\${=;\\n,]',
      contains: <Mode?>[
        UNDERSCORE_TITLE_MODE,
        Mode(
          className: 'params', 
          begin: '\\(', 
          end: '\\)', 
          keywords: {
          'keyword': KEYWORD,
          'built_in': 'Ellipsis NotImplemented',
          'literal': 'False None True',
          'type': 'int str float list dict tup set bool',
          }, 
          contains: <Mode?>[
            Mode(self: true),
            Mode(ref: 'metaMode'),
            Mode(ref: 'numberMode'),
            Mode(ref: 'stringMode'),
            HASH_COMMENT_MODE
          ]
        ),
        Mode(
          begin: '->', 
          endsWithParent: true, 
          keywords: 'None'
        )
      ]
    ),
    Mode(
      className: 'meta', 
      begin: '^[\\t ]*@', 
      end: '\$', 
      contains: <Mode?>[
        Mode(ref: 'stringMode'),
      ]
    ),
    Mode(begin: '\\b(print|exec)\\(')
  ]
);
