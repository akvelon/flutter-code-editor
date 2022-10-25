import 'package:equatable/equatable.dart';

/// Describes a break in continuous line numbers.
class LineNumberingBreakpoint with EquatableMixin {
  /// The full line index.
  final int full;

  /// The index of a visible line to which [full] maps.
  final int visible;

  /// The spread between visible and full numbers that was before this.
  final int spreadBefore;

  const LineNumberingBreakpoint({
    required this.full,
    required this.visible,
    required this.spreadBefore,
  })  : assert(
          full >= visible,
          'fullLineIndex must be >= visibleLineIndex, '
          'given $full and $visible',
        ),
        assert(
          spreadBefore < full - visible,
          'A breakpoint must increase the previous spread. '
          'Old=$spreadBefore, New=($full - $visible)',
        );

  int get spread => full - visible;

  int get addedSpread => spread - spreadBefore;

  /// The full line index of the visible line immediately before this.
  int get fullBefore => full - addedSpread;

  /// Returns the visible line index to which the full [lineIndex] maps
  /// as if this was the only breakpoint.
  ///
  /// If the line is invisible, returns the first visible line before it.
  int cutLineIndex(int lineIndex) {
    if (lineIndex >= full) {
      return lineIndex - spread;
    }

    if (lineIndex < full - addedSpread) {
      return lineIndex - spreadBefore;
    }

    return visible - 1;
  }

  /// Returns the visible line index to which the full [lineIndex] maps
  /// as if this was the only breakpoint.
  ///
  /// If the line is not visible, returns null.
  int? cutLineIndexIfVisible(int lineIndex) {
    if (lineIndex >= full) {
      return lineIndex - spread;
    }

    if (lineIndex < full - addedSpread) {
      return lineIndex - spreadBefore;
    }

    return null;
  }

  @override
  String toString() => 'LineNumberingBreakpoint: $full -> $visible '
      '(spreadBefore = $spreadBefore)';

  @override
  List<Object> get props => [
        full,
        visible,
        spreadBefore,
      ];
}
