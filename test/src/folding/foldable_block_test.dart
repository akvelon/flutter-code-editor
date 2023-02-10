import 'package:flutter_code_editor/src/folding/foldable_block.dart';
import 'package:flutter_test/flutter_test.dart';

import 'parsers/test_executor.dart';

void main() {
  group('FoldableBlock.join', () {
    test('Lines', () {
      const block14 = FB(firstLine: 1, lastLine: 4, type: FBT.union);
      const block12 = FB(firstLine: 1, lastLine: 2, type: FBT.union);
      const block13 = FB(firstLine: 1, lastLine: 3, type: FBT.union);
      const block23 = FB(firstLine: 2, lastLine: 3, type: FBT.union);

      expect(block14.join(block14), block14);

      expect(block14.join(block23), block14);
      expect(block23.join(block14), block14);

      expect(block12.join(block23), block13);
      expect(block23.join(block12), block13);
    });

    test('Anything + Imports = Imports', () {
      const imports = FB(firstLine: 0, lastLine: 0, type: FBT.imports);

      for (final type in FBT.values) {
        final block = FB(firstLine: 0, lastLine: 0, type: type);
        expect(block.join(imports), imports, reason: type.name);
        expect(imports.join(block), imports, reason: type.name);
      }
    });

    test('Anything else + Anything else = Union', () {
      const expected = FB(firstLine: 0, lastLine: 0, type: FBT.union);

      for (final typeA in FBT.values) {
        for (final typeB in FBT.values) {
          if (typeA == FBT.imports || typeB == FBT.imports) {
            continue;
          }

          final a = FB(firstLine: 0, lastLine: 0, type: typeA);
          final b = FB(firstLine: 0, lastLine: 0, type: typeB);
          expect(a.join(b), expected, reason: '$a + $b');
          expect(b.join(a), expected, reason: '$b + $a');
        }
      }
    });
  });

  group('FoldableBlockList.joinIntersecting', () {
    test('Empty -> Empty', () {
      const blocks = <FoldableBlock>[];

      final actual = [...blocks]..joinIntersecting();

      expect(actual, blocks);
    });

    test('Single -> Single', () {
      const blocks = [
        FoldableBlock(firstLine: 0, lastLine: 1, type: FBT.braces),
      ];

      final actual = [...blocks]..joinIntersecting();

      expect(actual, blocks);
    });

    test('Not intersecting blocks', () {
      const blocks = [
        FB(firstLine: 0, lastLine: 3, type: FBT.braces),
        FB(firstLine: 4, lastLine: 5, type: FBT.imports),
      ];

      final actual = [...blocks]..joinIntersecting();

      expect(actual, blocks);
    });

    //    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 -> 0 1 2 3 4 5 6 7 8 9
    //  0 ]                                    ]
    //  1 ]                                    ]
    //  2   }                                    }
    //  3   } )                                  } |
    //  4   } ) ]                                } | |
    //  5   } ) ] }                              } | |
    //  6   } )   }                              } | |
    //  7   } )     )                            } |
    //  8   }       )                            } |
    //  9   }                                    }
    // 10   }         ]                          }     |
    // 11   }         ] } )                      }     | |
    // 12   }         ] } )                      }     | |
    // 13   }         ]     ]                    }     |
    // 14   }               ] }                  }     |   }
    // 15   }               ] }                  }     |   }
    // 16   }               ]   )                }     |
    // 17   }                   )                }     |
    // 18                         ]                          ]
    // 19                         ] } )                      ] |
    // 20                         ] } ) ]                    ] |
    // 21                         ] }   ]                    ] |
    // 22                         ]                          ]
    // 23                                 }                      }
    test('Intersecting blocks', () {
      const blocks = [
        FB(firstLine: 0, lastLine: 1, type: FBT.brackets),
        FB(firstLine: 2, lastLine: 17, type: FBT.braces),
        FB(firstLine: 3, lastLine: 7, type: FBT.parentheses),
        FB(firstLine: 4, lastLine: 5, type: FBT.brackets),
        FB(firstLine: 5, lastLine: 6, type: FBT.braces),
        FB(firstLine: 7, lastLine: 8, type: FBT.parentheses),
        FB(firstLine: 10, lastLine: 13, type: FBT.brackets),
        FB(firstLine: 11, lastLine: 12, type: FBT.braces),
        FB(firstLine: 11, lastLine: 12, type: FBT.parentheses),
        FB(firstLine: 13, lastLine: 16, type: FBT.brackets),
        FB(firstLine: 14, lastLine: 15, type: FBT.braces),
        FB(firstLine: 16, lastLine: 17, type: FBT.parentheses),
        FB(firstLine: 18, lastLine: 22, type: FBT.brackets),
        FB(firstLine: 19, lastLine: 21, type: FBT.braces),
        FB(firstLine: 19, lastLine: 20, type: FBT.parentheses),
        FB(firstLine: 20, lastLine: 21, type: FBT.brackets),
        FB(firstLine: 23, lastLine: 23, type: FBT.braces),
      ];
      const expected = [
        FB(firstLine: 0, lastLine: 1, type: FBT.brackets),
        FB(firstLine: 2, lastLine: 17, type: FBT.braces),
        FB(firstLine: 3, lastLine: 8, type: FBT.union),
        FB(firstLine: 4, lastLine: 6, type: FBT.union),
        FB(firstLine: 10, lastLine: 17, type: FBT.union),
        FB(firstLine: 11, lastLine: 12, type: FBT.union),
        FB(firstLine: 14, lastLine: 15, type: FBT.braces),
        FB(firstLine: 18, lastLine: 22, type: FBT.brackets),
        FB(firstLine: 19, lastLine: 21, type: FBT.union),
        FB(firstLine: 23, lastLine: 23, type: FBT.braces),
      ];

      final actual = [...blocks]..joinIntersecting();

      expect(actual, expected);
    });
  });

  test('Offset method', () {
    const block = FB(firstLine: 5, lastLine: 7, type: FBT.braces);

    final positiveOffset = block.offset(3);
    final negativeOffset = block.offset(-4);

    expect(
      positiveOffset,
      const FB(firstLine: 5 + 3, lastLine: 7 + 3, type: FBT.braces),
    );

    expect(
      negativeOffset,
      const FB(firstLine: 5 - 4, lastLine: 7 - 4, type: FBT.braces),
    );
  });

  test('line count getter test', () {
    const block = FB(firstLine: 5, lastLine: 7, type: FBT.braces);

    final lineCount = block.lineCount;

    expect(lineCount, 7 - (5 - 1));
  });
}
