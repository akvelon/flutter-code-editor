import 'package:highlight/highlight_core.dart';
import '../LanguagesModes/common_modes.dart';
import 'main_mode.dart';

const String KEYWORD = 'break default func interface select case map struct chan'
    ' else goto package switch const fallthrough if range type continue for'
    ' import return var go defer';

const String TYPE = 'var int8 int16 int32 int64 uint8 uint16 uint32 uint64 uintptr'
    ' byte rune int uint float32 float64 complex64 complex128 bool string';

const String BUILT_IN = 'append cap close complex copy imag len make new'
    ' panic print println real recover delete';

final MainMode go = MainMode(
  nameOfLanguage: 'go',
  refs: <String, Mode>{
    'stringsMode': Mode(
      className: 'string',
      variants: <Mode?>[
        QUOTE_STRING_MODE,
        APOS_STRING_MODE,
        Mode(
          begin: '`', 
          end: '`'
        ),
      ],
    ),
    'methodsMode': Mode(
      className: 'bullet',
      begin: '\\.',
      end: '[^_A-Za-z0-9_-]',
      excludeBegin: true,
      excludeEnd: true,
    ),
    'numbersMode': Mode(
      className: 'number', 
      variants: <Mode?>[
        Mode(
          begin: '(-?)(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)[i]',
          relevance: 1
        ),
        C_NUMBER_MODE
      ]
    ),
  },
  aliases: <String>['golang'],
  keywords: {
    'keyword': KEYWORD,
    'literal': 'true false iota nil',
    'built_in': BUILT_IN,
    'type': TYPE
  },
  illegal: '</',
  contains: <Mode?>[
    C_LINE_COMMENT_MODE,
    C_BLOCK_COMMENT_MODE,
    Mode(ref: 'stringsMode'),
    Mode(ref: 'methodsMode'),
    Mode(ref: 'numbersMode'),
    Mode(begin: ':='),
    Mode(
      className: 'function',
      beginKeywords: 'func',
      end: '\\s*(\\{|\$)',
      excludeEnd: true,
      contains: <Mode?>[
        TITLE_MODE,
        Mode(
          className: 'params', 
          begin: '\\(', 
          end: '\\)', 
          keywords: {
          'keyword': KEYWORD,
          'literal': 'true false iota nil',
          'built_in': BUILT_IN,
          'type': TYPE,
          }, 
          contains: <Mode?>[
            Mode(ref: 'numbersMode'),
            Mode(ref: 'stringsMode'),
            Mode(ref: 'methodsMode'),
          ]
        )
      ]
    )
  ]
);
