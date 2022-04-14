// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:highlight/highlight_core.dart';
import '../LanguagesModes/common_modes.dart';
import 'main_mode.dart';

const String KEYWORD = 'abstract as assert async await break case catch class'
    ' const continue covariant default deferred do dynamic else enum'
    ' export extends extension external factory false final finally'
    ' for function get hide if implements import in interface'
    ' is library mixin new null on operator part rethrow return'
    ' set show static super switch sync this throw true try'
    ' typedef var void while with yield';

const String BUILT_IN = 'Comparable DateTime Duration Function Iterable'
    ' Iterator List Map Match Null Object Pattern RegExp Set'
    ' Stopwatch StringBuffer StringSink Type'
    ' Uri dynamic num print Element ElementList'
    ' document querySelector querySelectorAll window';

const String Type = 'bool double int String Symbol Runes';

final MainMode dart = MainMode(nameOfLanguage: 'dart', refs: <String, Mode>{
  'substringMode': Mode(
    className: 'subst',
    variants: <Mode?>[
      Mode(
        begin: '\\\${', 
        end: '}'
      )
    ],
    keywords: 'true false null this is new super',
    contains: <Mode?>[
      C_NUMBER_MODE, 
      Mode(ref: 'stringMode')
    ]
  ),
  'substringMode2': Mode(
    className: 'subst', 
    variants: <Mode?>[
      Mode(begin: '\\\$[A-Za-z0-9_]+')
    ]
  ),
  'stringMode': Mode(
    className: 'string', 
    variants: <Mode?>[
      Mode(begin: "r'''", end: "'''"),
      Mode(begin: 'r\"\"\"', end: '\"\"\"'),
      Mode(begin: "r'", end: "'|\\n"),
      Mode(begin: 'r\"', end: '\"|\\n'),
      Mode(
        begin: "'''",
        end: "'''",
        contains: <Mode?>[
          BACKSLASH_ESCAPE, 
          Mode(ref: 'substringMode2'), 
          Mode(ref: 'substringMode')
        ]
      ),
      Mode(
        begin: '\"\"\"',
        end: '\"\"\"',
        contains: <Mode?>[
          BACKSLASH_ESCAPE, 
          Mode(ref: 'substringMode2'), 
          Mode(ref: 'substringMode')
        ]
      ),
      Mode(
        begin: "'",
        end: "'|\\n",
        contains: <Mode?>[
          BACKSLASH_ESCAPE, 
          Mode(ref: 'substringMode2'), 
          Mode(ref: 'substringMode')
        ]
      ),
      Mode(
        begin: '\"',
        end: '\"|\\n',
        contains: <Mode?>[
          BACKSLASH_ESCAPE, 
          Mode(ref: 'substringMode2'), 
          Mode(ref: 'substringMode')
        ]
      )
  ]),
  'methodsMode': Mode(
    className: 'bullet',
    begin: '\\.',
    end: '[^_A-Za-z0-9_-]',
    excludeBegin: true,
    excludeEnd: true,
  ),
}, 
keywords: {
  'keyword': KEYWORD,
  'built_in': BUILT_IN,
  'type': Type,
}, 
contains: <Mode?>[
  Mode(ref: 'stringMode'),
  Mode(ref: 'methodsMode'),
  Mode(
    className: 'comment', 
    begin: '/\\*\\*', 
    end: '\\*/', 
    contains: <Mode?>[
      PHRASAL_WORDS_MODE,
      Mode(
        className: 'doctag', 
        begin: '(?:TODO|FIXME|NOTE|BUG|XXX):', 
        relevance: 0
      )
    ], 
    subLanguage: <String>['markdown']
  ),
  Mode(
    className: 'comment', 
    begin: '///+\\s*', 
    end: '\$', 
    contains: <Mode?>[
      Mode(
        subLanguage: <String>['markdown'], 
        begin: '.', 
        end: '\$'
      ),
      PHRASAL_WORDS_MODE,
      Mode(
        className: 'doctag', 
        begin: '(?:TODO|FIXME|NOTE|BUG|XXX):', 
        relevance: 0
      )
    ]
  ),
  C_LINE_COMMENT_MODE,
  C_BLOCK_COMMENT_MODE,
  Mode(
    className: 'class', 
    beginKeywords: 'class interface', 
    end: '{', 
    excludeEnd: true, 
    contains: <Mode?>[
      Mode(beginKeywords: 'extends implements'),
      UNDERSCORE_TITLE_MODE,
    ]
  ),
  C_NUMBER_MODE,
  Mode(
    className: 'meta', 
    begin: '@[A-Za-z]+'
  ),
  Mode(begin: '=>')
]);
