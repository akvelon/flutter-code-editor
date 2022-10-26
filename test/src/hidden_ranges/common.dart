import 'package:flutter_code_editor/src/hidden_ranges/hidden_range.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_ranges.dart';

final hiddenRanges = HiddenRanges(
  ranges: const [
    //            How many characters are hidden by the beginning of this range:
    HiddenRange(20, 23, firstLine: 0, lastLine: 0, wholeFirstLine: true), //   0
    HiddenRange(31, 42, firstLine: 0, lastLine: 0, wholeFirstLine: true), //   3
    HiddenRange(67, 91, firstLine: 0, lastLine: 0, wholeFirstLine: true), //  14
    HiddenRange(100, 101, firstLine: 0, lastLine: 0, wholeFirstLine: true), //38
    HiddenRange(102, 103, firstLine: 0, lastLine: 0, wholeFirstLine: true), //39
    HiddenRange(104, 105, firstLine: 0, lastLine: 0, wholeFirstLine: true), //40
    HiddenRange(106, 107, firstLine: 0, lastLine: 0, wholeFirstLine: true), //41
    HiddenRange(108, 109, firstLine: 0, lastLine: 0, wholeFirstLine: true), //42
    HiddenRange(110, 111, firstLine: 0, lastLine: 0, wholeFirstLine: true), //43
    HiddenRange(113, 123, firstLine: 0, lastLine: 0, wholeFirstLine: true), //44
    //                                                                        54
  ],
  textLength: 140,
);
