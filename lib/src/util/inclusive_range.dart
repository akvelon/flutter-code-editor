/// A range with both [first] and [last] considered included.
///
/// This is different from a common 'start-end' model where the end
/// is not included.
abstract class InclusiveRange {
  const InclusiveRange();

  int get first;

  /// The last included index, considered infinite if `null`.
  int? get last;

  bool overlaps(InclusiveRange other) {
    final thisLast = last;
    final otherLast = other.last;

    if (thisLast == null) {
      if (otherLast == null) {
        return true;
      }

      return otherLast >= first;
    }

    if (otherLast == null) {
      return thisLast >= other.first;
    }

    if (thisLast < other.first || otherLast < first) {
      return false;
    }

    return true;
  }
}
