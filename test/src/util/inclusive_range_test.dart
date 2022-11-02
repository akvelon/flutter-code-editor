import 'package:flutter_code_editor/src/util/inclusive_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InclusiveRange', () {
    test('overlaps', () {
      const examples = [
        //
        _OverlapsExample(
          'Finite. Finite. Overlap',
          first: _InclusiveRange(1, 5),
          second: _InclusiveRange(5, 10),
          expected: true,
        ),

        _OverlapsExample(
          'Finite. Finite. Separate',
          first: _InclusiveRange(1, 5),
          second: _InclusiveRange(6, 10),
          expected: false,
        ),

        _OverlapsExample(
          'Finite. Finite. Nested',
          first: _InclusiveRange(6, 9),
          second: _InclusiveRange(1, 10),
          expected: true,
        ),

        _OverlapsExample(
          'Finite. Infinite. Overlap',
          first: _InclusiveRange(1, 5),
          second: _InclusiveRange(5, null),
          expected: true,
        ),

        _OverlapsExample(
          'Finite. Infinite. Separate',
          first: _InclusiveRange(1, 5),
          second: _InclusiveRange(6, null),
          expected: false,
        ),

        _OverlapsExample(
          'Finite. Infinite. Nested',
          first: _InclusiveRange(6, 9),
          second: _InclusiveRange(1, null),
          expected: true,
        ),
      ];

      for (final example in examples) {
        expect(
          example.first.overlaps(example.second),
          example.expected,
          reason: example.name,
        );
        expect(
          example.second.overlaps(example.first),
          example.expected,
          reason: '${example.name} inverted',
        );
      }
    });
  });
}

class _InclusiveRange extends InclusiveRange {
  @override
  final int first;

  @override
  final int? last;

  const _InclusiveRange(this.first, this.last);
}

class _OverlapsExample {
  final String name;
  final _InclusiveRange first;
  final _InclusiveRange second;
  final bool expected;

  const _OverlapsExample(
    this.name, {
    required this.first,
    required this.second,
    required this.expected,
  });
}
