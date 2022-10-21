import 'dart:math';

import 'hidden_range.dart';
import 'hidden_ranges.dart';

/// Merges multiple sets of hidden ranges.
///
/// Input hidden ranges come in [sourceMap]. Each hidden range has a key
/// that later allows to remove it with [copyWithoutRange].
///
/// Hidden ranges in [sourceMap] are grouped in 2 levels:
///  1. Level 1 is the key's `runtimeType`.
///  2. Level 2 is the key itself.
///
/// For instance, hidden ranges derived from service comments may use
/// integer offsets as their keys. They may come like `sourceMap[int][7]`
///
/// Hidden ranges derived from folded blocks may have their block as the key
/// and come like `sourceMap[FoldableBlock][<block object>]`
///
/// This grouping allows to quickly remove all ranges of a particular origin
/// with [copyMergingSourceMap], e.g. to strip everything coming from
/// any foldable blocks.
class HiddenRangesBuilder {
  final HiddenRanges ranges;
  final Map<Type, Map<Object, HiddenRange>> sourceMap;

  static const empty = HiddenRangesBuilder._(
    ranges: HiddenRanges.empty,
    sourceMap: {},
  );

  const HiddenRangesBuilder._({
    required this.ranges,
    required this.sourceMap,
  });

  HiddenRangesBuilder.fromMaps(
    this.sourceMap, {
    required int textLength,
  }) : ranges = HiddenRanges(
          ranges: _merge(sourceMap.values.expand((map) => map.values)),
          textLength: textLength,
        );

  static List<HiddenRange> _merge(Iterable<HiddenRange> ranges) {
    final result = [...ranges]..sort(HiddenRange.sort);

    for (int i = 1; i < result.length; i++) {
      final current = result[i];
      final previous = result[i - 1];

      if (previous.end >= current.start) {
        final end = max(current.end, previous.end);

        result[i - 1] = HiddenRange(
          previous.start,
          end,
          firstLine: previous.firstLine,
          lastLine: end == current.end ? current.lastLine : previous.lastLine,
          wholeFirstLine: previous.wholeFirstLine,
        );

        result.removeAt(i);
        i--;
      }
    }

    return result;
  }

  HiddenRangesBuilder copyWithRange(Object key, HiddenRange range) {
    final newRanges = _copySourceMap();

    if (!newRanges.containsKey(key.runtimeType)) {
      newRanges[key.runtimeType] = {};
    }

    newRanges[key.runtimeType]![key] = range;

    return HiddenRangesBuilder.fromMaps(
      newRanges,
      textLength: ranges.textLength,
    );
  }

  HiddenRangesBuilder copyWithoutRange(Object key) {
    final newRanges = _copySourceMap();

    newRanges[key.runtimeType]?.remove(key);

    return HiddenRangesBuilder.fromMaps(
      newRanges,
      textLength: ranges.textLength,
    );
  }

  /// Shallow-merges a map by the 1st level (keys' `runtimeType`s).
  ///
  /// For each [newSourceMap]'s entry, the new ranges of its key
  /// fully replace the old ranges in the new object.
  HiddenRangesBuilder copyMergingSourceMap(
    Map<Type, Map<Object, HiddenRange>> newSourceMap,
  ) {
    final newRanges = _copySourceMap();

    newRanges.addAll(newSourceMap);

    return HiddenRangesBuilder.fromMaps(
      newRanges,
      textLength: ranges.textLength,
    );
  }

  // Clones the 2-level [sourceMap], deep copy by 1st level and shallow copy
  // after that.
  Map<Type, Map<Object, HiddenRange>> _copySourceMap() {
    final result = <Type, Map<Object, HiddenRange>>{};

    for (final entry in sourceMap.entries) {
      result[entry.key] = Map<Object, HiddenRange>.from(entry.value);
    }

    return result;
  }
}
