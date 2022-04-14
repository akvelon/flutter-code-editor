import 'package:highlight/highlight_core.dart';
import '../LanguagesModes/common_modes.dart';
import 'main_mode.dart';

const String KEYWORD = 'false synchronized abstract private static null if const'
    ' for true while strictfp finally protected import native final void enum'
    ' else break transient catch instanceof super volatile case assert short'
    ' package default public try this switch continue throws protected'
    ' public private module requires exports do';

const String TYPE = 'int boolean String float char var long byte double'
    'short Short Byte Integer Long Float Double Character Boolean';

final MainMode java = MainMode(
  nameOfLanguage: 'java',
  refs: <String, Mode>{},
  aliases: <String>['jsp'],
  keywords: {
    'keyword': KEYWORD, 
    'type': TYPE
  },
  illegal: '<\\/|#',
  contains: <Mode?>[
    Mode(
      className: 'comment',
      begin: '/\\*\\*',
      end: '\\*/',
      contains: <Mode?>[
        Mode(
          begin: '\\w+@', 
          relevance: 0
        ),
        Mode(
          className: 'doctag', 
          begin: '@[A-Za-z]+'
        ),
        PHRASAL_WORDS_MODE,
        Mode(
          className: 'doctag', 
          begin: '(?:TODO|FIXME|NOTE|BUG|XXX):', 
          relevance: 0
        )
      ],
      relevance: 0
    ),
    C_LINE_COMMENT_MODE,
    C_BLOCK_COMMENT_MODE,
    APOS_STRING_MODE,
    QUOTE_STRING_MODE,
    Mode(
      className: 'class',
      beginKeywords: 'class interface',
      end: '[{;=]',
      excludeEnd: true,
      keywords: 'class interface',
      illegal: '[:\"\\[\\]]',
      contains: <Mode?>[
        Mode(beginKeywords: 'extends implements'), 
        UNDERSCORE_TITLE_MODE
      ]
    ),
    Mode(beginKeywords: 'new throw return else', relevance: 0),
    Mode(
      className: 'bullet',
      begin: '\\.',
      end: '[^A-Za-z0-9_-]',
      excludeBegin: true,
      excludeEnd: true,
    ),
    Mode(
      className: 'function',
      begin:
          '([À-ʸa-zA-Z_\$][À-ʸa-zA-Z_\$0-9]*(<[À-ʸa-zA-Z_\$][À-ʸa-zA-Z_\$0-9]*(\\s*,\\s*[À-ʸa-zA-Z_\$][À-ʸa-zA-Z_\$0-9]*)*>)?\\s+)+[a-zA-Z_]\\w*\\s*\\(',
      returnBegin: true,
      end: '[{;=]',
      excludeEnd: true,
      keywords: {
        'keyword': KEYWORD,
        'type': TYPE,
      },
      contains: <Mode?>[
        Mode(
          begin: '[a-zA-Z_]\\w*\\s*\\(',
          returnBegin: true,
          relevance: 0,
          contains: <Mode?>[UNDERSCORE_TITLE_MODE]
        ),
        Mode(
          className: 'params',
          begin: '\\(',
          end: '\\)',
          keywords: {
            'keyword': KEYWORD,
            'type': TYPE,
          },
          relevance: 0,
          contains: <Mode?>[
            APOS_STRING_MODE,
            QUOTE_STRING_MODE,
            C_NUMBER_MODE,
            C_BLOCK_COMMENT_MODE
          ]
        ),
        C_LINE_COMMENT_MODE,
        C_BLOCK_COMMENT_MODE
      ]
    ),
    Mode(
      className: 'number',
      begin:
          '\\b(0[bB]([01]+[01_]+[01]+|[01]+)|0[xX]([a-fA-F0-9]+[a-fA-F0-9_]+[a-fA-F0-9]+|[a-fA-F0-9]+)|(([\\d]+[\\d_]+[\\d]+|[\\d]+)(\\.([\\d]+[\\d_]+[\\d]+|[\\d]+))?|\\.([\\d]+[\\d_]+[\\d]+|[\\d]+))([eE][-+]?\\d+)?)[lLfF]?',
      relevance: 0
    ),
    Mode(
      className: 'meta', 
      begin: '@[A-Za-z]+'
    )
  ]);
