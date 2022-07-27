import 'dart:ui';

extension Normalized on TextRange {
  TextRange get normalized {
    return isNormalized ? this : TextRange(start: end, end: start);
  }
}
